#!/usr/bin/python
#
# List running processes potentially affected by package upgrades.
#
# Use this script as a pacman-hook(5) with the following setup in
# `/etc/pacman.d/hooks/check_msys_processes.hook`:
#
#     [Trigger]
#     Operation = Upgrade
#     Type = Package
#     Target = *
#     Target = !bash
#     Target = !filesystem
#     Target = !mintty
#     Target = !msys2-runtime*
#     Target = !pacman
#     Target = !pacman-mirrors
#
#     [Action]
#     Description = Checking for affected running processes...
#     When = PreTransaction
#     Exec = /path/to/check_msys_processes.py
#     AbortOnFail
#     Depends = base
#
# Note that only msys2 Python has ALPM bindings, thus we need to
# specify its path in the shebang.
#
# We run this hook for all packages except for special cases in msys2
# pacman [1], which are already prioritized over other packages, add
# further confirmations and kill the shell after upgrade.
#
# [1]: <https://github.com/msys2/MSYS2-packages/blob/1915a138c0796740f3eec33308d6d34644e78a86/pacman/0011-Core-update.patch#L34-L59>

import collections
import json
import os
import pprint
import pyalpm
import re
import shutil
import subprocess
import sys
import warnings

PACMAN_ROOTPATH = "/"
PACMAN_DBPATH = "/var/lib/pacman/"
# Executables which hide their details
PROCESS_SPECIAL_CASES = [{"process": "keepassxc", "path": "mingw64/bin/keepassxc.exe"}]

def find_msys2_root():
    """
    Find the install directory of MSYS2.
    """
    p = subprocess.run(
        ["cygpath", "-m", "/"],
        capture_output=True,
        text=True,
        check=True,
    )
    p = p.stdout.strip()
    p = os.path.join(*re.split(r'[\\/]', p))
    return p

def list_msys2_environments(dbpath=PACMAN_DBPATH):
    """
    List MSYS2 environments based on Pacman database directory
    structure.
    """
    dbs = [os.path.splitext(f) for f in os.listdir(os.path.join(dbpath, "sync"))]
    dbs = [f[0] for f in dbs if f[1] == ".db"]
    return dbs

def setup_db_handle(rootpath=PACMAN_ROOTPATH, dbpath=PACMAN_DBPATH):
    """
    Setup a PyALPM handle that can be used to query the Pacman database.
    """
    handle = pyalpm.Handle(rootpath, dbpath)
    envs = list_msys2_environments()
    # Databases are not signed
    [handle.register_syncdb(e, pyalpm.SIG_DATABASE_OPTIONAL) for e in envs]
    return handle

def extract_pkg_name(dep):
    """
    Extract the package name from a dependency string. For example,
    "libfoo>=1.0" becomes "libfoo".
    """
    m = re.match(r"^([\w\-\+\.]+)", dep)
    return m.group(1) if m else dep

def get_names_from_dep(dep_str):
    """
    Split a dependency string by '|' to handle alternatives and return
    a list of package names.
    """
    alternatives = dep_str.split('|')
    return [extract_pkg_name(alt.strip()) for alt in alternatives]

def find_pkg(name, handle):
    """
    Search for a package in the sync databases first, then in the
    local database.
    """
    pkgs_syncdbs = []
    for db in handle.get_syncdbs():
        p = [p for p in db.pkgcache if p.name == name]
        if len(p) > 0:
            pkgs_syncdbs.extend(p)
    pkg_localdb = [p for p in handle.get_localdb().pkgcache if p.name == name]
    if len(pkgs_syncdbs) == 0 and len(pkg_localdb) == 0:
        pkg = None
    if len(pkgs_syncdbs) == 0 and len(pkg_localdb) != 0:
        pkg = pkg_localdb[0]
    elif len(pkgs_syncdbs) > 0:
        pkg = pkgs_syncdbs[0]
        if len(pkgs_syncdbs) > 1:
            warnings.warn(f"Package \"{name}\" found in more than one sync DBs, using \"{pkg.db.name}\".", stacklevel=2)
    return pkg

def get_recursive_dependencies(pkg_name, handle,
                               include_optional=False,
                               include_build=False):
    """
    Get all recursive dependencies of a package using pyalpm.

    Parameters:
        pkg_name (str): Name of the package to analyze.
        handle (alpm.Handle): A handle object with local and sync dbs initialized.
        include_optional (bool): If True, include optional dependencies.
        include_build (bool): If True, include build (makedepends) dependencies.

    Returns:
        dict: A dictionary with dependency types as keys ('depends', 'optdepends', 'makedepends')
              and sorted lists of package names as values.
    """

    pkg = find_pkg(pkg_name, handle)
    if pkg is None:
        raise ValueError(f"Package '{pkg_name}' not found in sync or local databases.")

    # Initialize result dictionary.
    results = {"depends": set()}
    if include_optional:
        results["optdepends"] = set()
    if include_build:
        results["makedepends"] = set()

    visited = set()

    def recursive(current_pkg):
        if current_pkg.name in visited:
            return
        visited.add(current_pkg.name)

        # Process hard dependencies.
        for dep in current_pkg.depends:
            for name in get_names_from_dep(dep):
                results["depends"].add(name)
                dep_pkg = find_pkg(name, handle)
                if dep_pkg is not None:
                    recursive(dep_pkg)

        # Process optional dependencies.
        if include_optional:
            for dep in current_pkg.optdepends:
                for name in get_names_from_dep(dep):
                    results["optdepends"].add(name)
                    dep_pkg = find_pkg(name, handle)
                    if dep_pkg is not None:
                        recursive(dep_pkg)

        # Process build dependencies.
        if include_build:
            for dep in current_pkg.makedepends:
                for name in get_names_from_dep(dep):
                    results["makedepends"].add(name)
                    dep_pkg = find_pkg(name, handle)
                    if dep_pkg is not None:
                        recursive(dep_pkg)

    recursive(pkg)
    # Convert each dependency set to a sorted list before returning.
    return {k: sorted(v) for k, v in results.items()}

def list_msys2_processes(msys2_root, special_cases=PROCESS_SPECIAL_CASES):
    """
    List processes of MSYS2 and MINGW binaries, filter to current
    user, and construct a dict from the results with process names,
    paths, and PIDs that can be converted to JSON.

    We use PowerShell because MSYS Python has only a limited set of
    packages and does not come with good process query utilities.
    Specifically, we use PowerShell Core, if available because Windows
    Powershell (i.e. version 5) doesn't return parent processes. [1]
    AFAIU, due to the way Cygwin works, `subprocess` "forks" (whatever
    that actually means, possibly simulates some kind of fork) the
    current Python process, and that launches the external program.
    This means not only the current process will included in running
    processes (and marked as having open handles of upgradable
    packages) but this additional process too. To filter both, we can
    look for PIDs and parent PIDs, hence the need for PowerShell Core.

    [1]: https://github.com/PowerShell/PowerShell/issues/17541#issuecomment-1159817164
    """

    powershell_exe = find_powershell()
    powershell_cmd = "Get-Process | Where-Object {$_.SessionId -eq (Get-Process -PID $PID).SessionId} | ForEach-Object { @{ process=$_.ProcessName; path = $_.Path; pid=$_.Id; parent_pid=$_.Parent.Id } } | ConvertTo-Json"
    p = subprocess.run(
        [powershell_exe, "-C", powershell_cmd],
        capture_output=True,
        check=True,
        text=True
    )
    d = json.loads(p.stdout)

    # Filter current process and its child processes from results.
    # Since we're running in Cygwin, `os.pid()` reports Cygwin PIDs,
    # which we need to transform.
    pid = cygwin_pid_to_winpid(os.getpid())
    d = [{'process': p['process'], 'pid': p['pid'], 'path': p['path']} for p in d if p['pid'] != pid and p['parent_pid'] != pid]

    # Special case for apps hiding their details.
    for app in special_cases:
        for p in d:
            if p['process'] == app['process']:
                p['path'] = os.path.join(msys2_root, app['path'])
    # There also other, mostly system-level but user-owned apps that
    # do it. We don't need them and we drop them early as we cannot
    # convert convert to paths anyway.
    d = [p for p in d if p['path'] is not None]
    # Always skip pacman. MSYS2's pacman has a special case for
    # upgrading core packages but pacman might run as a parent
    # process, which would prevent any upgrades.
    d = [p for p in d if p['process'] != "pacman"]
    # Inconsistent casing. We simply lowercase, instead of
    # `os.normcase()` as that changes everything to backslashes.
    for p in d:
        p['path'] = os.path.join(*re.split(r'[\\/]', p['path'])).lower()

    # Filter MSYS processes
    d = [p for p in d if p['path'].lower().startswith(msys2_root.lower())]

    return d

def cygwin_pid_to_winpid(pid):
    """
    Convert a UNIX-style Cygwin PID to its native Windows PID.
    """
    proc_file = os.path.join("/proc/", str(pid), "winpid")
    with open(proc_file) as f:
        result = int(f.read().strip())
    return result

def find_powershell():
    """
    Find PowerShell Core binary on PATH.
    """
    pwsh = shutil.which("pwsh")
    if pwsh is not None:
        return pwsh
    else:
        pwsh_warning = "PowerShell Core ('pwsh') not found on on PATH, using Windows PowerShell instead. This will result in false positives for running processes."
        warnings.warn(pwsh_warning, stacklevel=2)
        return shutil.which("powershell")

def list_installed_packages(handle):
    """
    List installed packages based on the local Pacman database.
    """
    localdb = handle.get_localdb()
    packages = localdb.search(".+")

    return packages

def list_upgradable_packages(handle):
    """
    List outdated installed packages based on the difference between
    local and sync Pacman databases.
    """
    localdb = handle.get_localdb()
    syncdbs = handle.get_syncdbs()

    outdated = [p.name for p in localdb.search(".+")]
    outdated = [pyalpm.sync_newversion(localdb.get_pkg(p), syncdbs) for p in outdated]
    outdated = [p for p in outdated if p is not None]

    return outdated

def get_package_name_from_file(file, packages, msys2_root):
    """
    Get the name of the packages which owns 'file'.
    """
    file_no_prefix = file.replace(msys2_root.lower(), "")
    package_files = []
    for p in packages:
        package_files.append({'name': p.name, 'files': [f[0] for f in p.files]})
    result = [p['name'] for p in package_files if file_no_prefix in p['files']]
    if len(result) == 0:
        raise ValueError(f"File {file} ({file_no_prefix}) not found in any package.")
        result = None
    elif len(result) == 1:
        result = result[0]
    else:
        raise ValueError(f"File {file} found in more than one package.")
    return result

def list_installed_dependencies(pkg_name, handle):
    """
    List required and optional dependencies of a package if their are
    installed. If a dependency is satisfied by a package which
    provides the dependency, return the provider package.
    """
    installed_packages = list_installed_packages(handle)

    deps = get_recursive_dependencies(pkg_name, handle, include_optional=True)
    deps = set(deps['depends']).union(deps['optdepends'])

    deps_clean = []
    for p in deps:
        for pi in installed_packages:
            if p == pi.name:
                deps_clean.append(p)
            elif p in pi.provides:
                deps_clean.append(pi.name)
    deps_clean = list(set(deps_clean))
    deps_clean.sort()
    deps_clean = [d for d in deps_clean if d != pkg_name]

    return deps_clean

def merge_processes(x):
    """
    Merge executables that have multiple processes.
    """
    groups = collections.defaultdict(list)
    for item in x:
        key = (item["process"], item["path"])
        groups[key].append(item["pid"])

    return [{"process": proc, "pid": pids, "path": path}
        for (proc, path), pids in groups.items()]

def list_affected_processes():
    handle = setup_db_handle()
    msys2_root = find_msys2_root()
    processes = list_msys2_processes(msys2_root)
    processes = merge_processes(processes)
    m = list_affected_processes_inner(handle, processes, msys2_root)
    return m

def list_affected_processes_inner(handle, processes, msys2_root):
    installed_packages = list_installed_packages(handle)
    outdated_packages = list_upgradable_packages(handle)

    for p in processes:
        p['package'] = get_package_name_from_file(p['path'], installed_packages, msys2_root)
        p['upgradable'] = p['package'] in [pp.name for pp in outdated_packages]
        installed_dependencies = list_installed_dependencies(p['package'], handle)
        upgradable_dependencies = [pi for pi in installed_dependencies if pi in [po.name for po in outdated_packages]]
        p['upgradable_dependencies'] = upgradable_dependencies
    processes = [p for p in processes if p['upgradable'] or len(p['upgradable_dependencies']) > 0]

    return processes

if __name__ == "__main__":
    m = list_affected_processes()

    if len(m) == 0:
        sys.exit(0)
    else:
        print("Some running processes are owned by upgradable packages, or have upgradable dependencies.\n")
        pprint.pp(m)
        sys.exit(1)
