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

    # We have proper ssh here
    export GIT_SSH_COMMAND=ssh
fi

# Homebrew on Linux
if [[ "$OSTYPE" = linux* ]]; then
   export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
fi
