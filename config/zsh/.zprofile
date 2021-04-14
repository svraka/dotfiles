# On macOS `/etc/zprofile` sets paths and it is sourceed after
# `~/.zshenv `, altering the ordering (see
# https://www.zsh.org/mla/users/2015/msg00727.html). As far as I
# can tell, having a correct "$PATH" only in interactive shells
# should not be a problem for my use cases.
#
# - Shell scripts launched from interactive shells inherit
#   `$PATH`.
# - In Emacs `exec-path-from-shell` is required anyway, and it
#   gets `$PATH` by running an interactive login shell anyway. (At
#   least by defult. This incurs a little bit of overhead but I use
#   Emacs in daemon mode, so this doesn't matter).
# - With `launchd` environment and paths need to be set manually
#   (same with cron for that matter).
#
# Also note that using `PATH=/path/to:$PATH` is not recommended for
# exec-path-from-shell in Emacs because it will can lead to different
# PATH then from a simple shell. In this case, the named directories
# below will be added to the end of PATH in Emacs buy they'll be on
# the top in a shell launched within Emacs. In my case this shouldn't
# be an issue, However, in this case exec-path-from-shell will add
# these named directories to the end of PATH which should not affect
# my setup.


# Set up Homebrew
case $OSTYPE in
    darwin*)
        if [[ $(uname -p) == "arm" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        ;;
    linux*)
        if [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
           eval "$( shellenv)"
        fi
           ;;
esac

# MSYS2 sets its own path, so this cannot be called in `.zshenv` at
# all. We add non-MSYS2 and personal tools to $PATH. We can't use zsh
# array operations because PATH_WIN_CUSTOM is a single string.
if [[ "$OSTYPE" = msys ]]; then
    export PATH="$PATH_WIN_CUSTOM:$PATH"
fi

# Add `$HOME/.local/bin` to the top of `$PATH`. This way personal
# scripts can take precendence over other programs.
typeset -U path
path=($HOME/.local/bin $path)
export PATH
