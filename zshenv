# Make a cuppa
export HOMEBREW_INSTALL_BADGE="☕️"

# Set config location to ~/.config where possible
export PARALLEL_HOME=~/.config/parallel
export CHKTEXRC=~/.config

if [[ "$OSTYPE" = msys ]]; then
    # Always use the regular Windows temp directory instead of
    # /tmp. This is mainly for running R from MSYS. Other temp locations
    # are set by MSYS and probably shouldn't be touched (see comments in
    # `/etc/profile` and Cygwin commits
    # https://cygwin.com/git/gitweb.cgi?p=cygwin-apps/base-files.git;a=commitdiff;h=3e54b07
    # and
    # https://cygwin.com/git/gitweb.cgi?p=cygwin-apps/base-files.git;a=commitdiff;h=7f09aef).
    export TMPDIR=$HOME/AppData/Local/Temp

    # I use OpenSSH in Git for Windows by setting this variable to the
    # ssh path in Git for Windows, using Windows-style paths. That
    # obviously won't work here, but we have proper ssh anyway, so use
    # that.
    #
    # However, it only works if MSYS2 and Git for Windows are on the
    # same version of the MSYS runtime, otherwise mixing different
    # Cygwin based programs leads to cygheap errors. MSYS2 is a
    # rolling release, Git for Windows if tied to upstream Git
    # releases but they seem to update the runtime more or less in
    # parallel with MSYS2, so updating requires caution.
    #
    # I don't use git from a Unix shell regularly, especially not for
    # fetching and pushing, so this shouldn't be a problem very often.
    # If I really, really need to to push, or fetch from the shell, I
    # can rewrite remotes to use HTTPS. Alternatively we could use an
    # msys git but that leads to other problems.
    export GIT_SSH_COMMAND=ssh
fi

# Homebrew on Linux
if [[ "$OSTYPE" = linux* ]]; then
   export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
fi
