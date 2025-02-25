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

import collections
import json
import os
import pyalpm
import re
import shutil
import subprocess
import sys
import warnings

PACMAN_ROOTPATH = "/"
PACMAN_DBPATH = "/var/lib/pacman/"

def get_msys2_root():
    p = subprocess.run(
        ["cygpath", "-m", "/"],
        capture_output=True,
        text=True,
        check=True,
    )
    p = p.stdout.strip()
    p = os.path.join(*re.split(r'[\\/]', p))
    return p

def get_msys2_environments(dbpath=PACMAN_DBPATH):
    dbs = [os.path.splitext(f) for f in os.listdir(os.path.join(dbpath, "sync"))]
    dbs = [f[0] for f in dbs if f[1] == ".db"]
    return dbs

def setup_db_handle(rootpath=PACMAN_ROOTPATH, dbpath=PACMAN_DBPATH):
    handle = pyalpm.Handle(rootpath, dbpath)
    envs = get_msys2_environments()
    # Databases are not signed
    [handle.register_syncdb(e, pyalpm.SIG_DATABASE_OPTIONAL) for e in envs]
    return handle

def get_process_modules():
    # List processes, filter to current user, and construct a dict
    # from the results with process names, PIDs and loaded modules
    # that can be converted to JSON. We use PowerShell because msys
    # Python has only a limited set of packages and does not come with
    # good process query utilities. Specifically, we use PowerShell
    # Core, if available because Windows Powershell (i.e. version 5)
    # doesn't return parent processes. [1] AFAIU, due to the way
    # Cygwin works, `subprocess` "forks" (whatever that actually
    # means, possibly simulates some kind of fork) the current Python
    # process, and that launches the external program. This means not
    # only the current process will included in running processes (and
    # marked as having open handles of upgradeable packages) but this
    # additional process too. To filter both, we can look for PIDs and
    # parent PIDs, hence the need for PowerShell Core.
    #
    # [1]: https://github.com/PowerShell/PowerShell/issues/17541#issuecomment-1159817164
    powershell_exe = find_powershell()
    powershell_cmd = "Get-Process | Where-Object {$_.SessionId -eq (Get-Process -PID $PID).SessionId} | ForEach-Object { $Modules = @(); $_.Modules | ForEach-Object { $Modules += $_.FileName }; @{ process=$_.ProcessName; pid=$_.Id; parent_pid=$_.Parent.Id; module=$Modules } } | ConvertTo-Json"
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
    d = [{'process': p['process'], 'pid': p['pid'], 'module': p['module']} for p in d if p['pid'] != pid and p['parent_pid'] != pid]

    return d

def cygwin_pid_to_winpid(pid):
    proc_file = os.path.join("/proc/", str(pid), "winpid")
    with open(proc_file) as f:
        result = int(f.read().strip())
    return result

def find_powershell():
    pwsh = shutil.which("pwsh")
    if pwsh is not None:
        return pwsh
    else:
        pwsh_warning = "PowerShell Core ('pwsh') not found on on PATH, using Windows PowerShell instead. This will result in false positives for running processes."
        warnings.warn(pwsh_warning, stacklevel=2)
        return shutil.which("powershell")

def filter_processes(process_modules, msys2_root):
    # JSON `none` is parsed as `None`. We don't need them and we drop
    # them early as we cannot convert convert to paths anyway.
    pf = [p for p in process_modules if any(p['module'])]
    for p in pf:
        p['module'] = [os.path.join(*re.split(r'[\\/]', f)).lower() for f in p['module']]
        # Inconsistent casing. We simply lowercase, instead of
        # `os.normcase()` as that changes everything to backslashes.
        p['module'] = [f for f in p['module'] if f.lower().startswith(msys2_root.lower())]
        # For the sake of brevity, don't list *.eln files loaded in
        # Emacs. If Emacs is out-of-date, we will catch it anyway and
        # those *.eln files are not loaded by processes from other
        # packages.
        p['module'] = [f for f in p['module'] if not os.path.splitext(f)[1] == ".eln"]
    pf = [p for p in pf if any(p['module'])]
    return pf

def get_upgradable_files(handle, msys2_root):
    localdb = handle.get_localdb()
    syncdbs = handle.get_syncdbs()

    outdated = [p.name for p in localdb.search(".+")]
    outdated = [pyalpm.sync_newversion(localdb.get_pkg(p), syncdbs) for p in outdated]
    outdated = [p for p in outdated if p is not None]
    # `sync_newversion` returns a package from the sync DBs, for which
    # we don't have a list of files and need to get the currently
    # installed version from the local DB.
    outdated = [localdb.get_pkg(p.name) for p in outdated]

    # Create a simple dict from the pyalpm object with the information
    # we need.
    packages = [p.name for p in outdated]
    files = [p.files for p in outdated]
    files = [[f[0] for f in pkg] for pkg in files]
    result = [{'file': f, 'package': p} for p, files in zip(packages, files) for f in files]
    # Skip directories
    result = [f for f in result if not f['file'].endswith("/")]
    # NTFS is case-insensitive, PowerShell returns paths with mixed
    # cases, while file names in pacman packages are supposed to be
    # case-sensitive. We add a normalized for matching but keep pacman
    # paths for final results.
    result = [{**f, 'file_normalized': os.path.join(msys2_root, f['file']).lower()} for f in result]
    return result

def get_upgradable_package_from_module(module, upgradable_files):
    result = [f for f in upgradable_files if module == f['file_normalized']]
    if len(result) == 0:
        result = []
    elif len(result) == 1:
        result = result[0]
    else:
        raise ValueError("File found in more than one package.")
    return result

def merge_upgradeable_modules(handle, process_modules, msys2_root):
    files = get_upgradable_files(handle, msys2_root)
    processes = filter_processes(process_modules, msys2_root)
    for p in processes:
        p['module'] = [get_upgradable_package_from_module(m, files) for m in p['module']]
        p['module'] = [m for m in p['module'] if any(m)]
    processes = [p for p in processes if any(p['module'])]

    # Merge executables that have multiple processes. We want to
    # collect all PIDs and a deduplicated list of modules.
    grouped_processes = collections.defaultdict(lambda: {'pid': [], 'module': []})
    for item in processes:
        grouped_processes[item['process']]['pid'].append(item['pid'])
        grouped_processes[item['process']]['module'].extend(item['module'])
    # Deduplicate module list of dicts
    for key, values in grouped_processes.items():
        unique_module = []
        seen = set()
        for d in values['module']:
            t = tuple(d.items())
            if t not in seen:
                unique_module.append(d)
                seen.add(t)
                grouped_processes[key]['module'] = unique_module
    # Transform the grouped data into the desired format
    merged_processes = [{'process': key,
                         'pid': values['pid'] if len(set(values['pid'])) > 1 else values['pid'],
                         'module': values['module']}
                        for key, values in grouped_processes.items()]

    return merged_processes

def collect_upgradeable_modules():
    handle = setup_db_handle()
    process_modules = get_process_modules()
    msys2_root = get_msys2_root()
    m = merge_upgradeable_modules(handle, process_modules, msys2_root)
    return m

def print_upgradeable_modules(results):
    print("Upgradable files are loaded by the following processes:")
    for p in results:
        print(f"{p['process']} ({', '.join(map(str, p['pid']))}):")
        for m in p['module']:
            print(f"  - {m['file']} ({m['package']})")

def check_upgradeable_modules(results):
    if len(results) == 0:
        sys.exit(0)
    else:
        print_upgradeable_modules(results)
        sys.exit(1)

if __name__ == "__main__":
    m = collect_upgradeable_modules()
    check_upgradeable_modules(m)
