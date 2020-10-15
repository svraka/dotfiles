# Setting history location only makes sense in an interactive shell
export HISTFILE=$XDG_DATA_HOME/zsh/history

# Fix paths
#
# Also note that using `PATH=/path/to:$PATH` is not recommended for
# exec-path-from-shell in Emacs because it will can lead to different
# PATH then from a simple shell. In this case, the named directories
# below will be added to the end of PATH in Emacs buy they'll be on
# the top in a shell launched within Emacs. In my case this shouldn't
# be an issue, However, in this case exec-path-from-shell will add
# these named directories to the end of PATH which should not affect
# my setup.
if [[ "$OSTYPE" = darwin* ]]; then
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
    # Ensure that local bin is added only once
    typeset -U path
    # And prepend
    path=($HOME/.local/bin $path)
    export PATH
elif [[ "$OSTYPE" = msys ]]; then
    # MSYS2 sets its own path, so this cannot be called in `.zshenv`
    # at all. We add non-MSYS2 and personal tools to $PATH. We can't
    # use zsh array operations because PATH_WIN_CUSTOM is a single
    # string.
    export PATH="$HOME/.local/bin:$PATH_WIN_CUSTOM:$PATH"
fi

# Homebrew completion setup. Needs to be done before loading Oh My Zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  # Ensure this uses the same dump file as Oh My Zsh
  compinit -d $ZSH_COMPDUMP
fi

# oh-my-zsh configuration

# Path to oh-my-zsh installation and customisations.
export ZSH="$ZDOTDIR/oh-my-zsh"
export ZSH_CUSTOM="$ZDOTDIR/oh-my-zsh-custom"

# Barebones theme
ZSH_THEME="svraka"

# Use hyphen-insensitive completion. Case-sensitive completion must
# be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# oh-my-zsh is managed via submodule
DISABLE_AUTO_UPDATE="true"

# Change the command execution time stamp shown in the history command
# output.
HIST_STAMPS="yyyy-mm-dd"

# oh-my-zsh plugins
plugins=(
    dotenv
    emacs
    extract
    sudo
    svraka-functions
    zsh-autosuggestions
    zsh-fzy
)

# The following plugins provide completion functions, which are normally
# installed with packages (either distro, or Homebrew). However, these
# tools are not part of MSYS, so completions are not available and we
# need to get them from Oh My Zsh plugins.
if [[ "$OSTYPE" == msys ]]; then
    plugins+=(
        doctl
        fd
        ripgrep
    )
fi

source $ZSH/oh-my-zsh.sh

# User configuration

if [[ "$OSTYPE" != msys ]]; then
    # Setting locales breaks R on Windows but MSYS2 seems to set most
    # of these (except `LC_ALL` but R will complain if that is set to
    # UTF-8 anyway). Printing Unicode to stdout from R is broken but
    # that was the case from bash as well.
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
fi

export EDITOR='emacsclient -c'

HISTSIZE=100000
SAVEHIST=100000

# Report time if combined user and system execution times are longer
# than this many seconds. That is, sleep, caffeinate, etc. don't
# report anything.
REPORTTIME=10

# Use coreutils ls on macOS and set the same options everywhere to
# hide Windows cruft. Also make output simpler and nicer
LS_OPTS='--color=auto --hide="ntuser.*" --hide="NTUSER.*" --hide="Thumbs.db" --group-directories-first -G -v --time-style=long-iso'
if [[ "$OSTYPE" == darwin* ]]; then
    gls --color -d . &>/dev/null && alias ls="gls $LS_OPTS"
else
    ls --color -d . &>/dev/null && alias ls="ls $LS_OPTS"
fi

# Colourise less, ignore case in isearch and only page if more than a
# page. Paging needs recent less which is installed from Homebrew on
# macOS.
if [[ "$OSTYPE" == darwin* && -a $(brew --prefix)/bin/less ]]; then
    alias less="$(brew --prefix)/bin/less"
fi
export LESS="--RAW-CONTROL-CHARS --quit-if-one-screen --ignore-case"

# Colourful diff with shell completion
if type colordiff &>/dev/null; then
    alias diff=colordiff
    compdef _diff colordiff
fi

# tree with all the decorations
if type tree &>/dev/null; then
    alias t='tree -s -h --du -D --timefmt="%Y-%m-%d %H:%M:%S" --dirsfirst -l -C'
fi

# Set Emacs-friendly zsh-fzy keybindings
bindkey '^Xd' fzy-cd-widget
bindkey '^Xf' fzy-file-widget
bindkey '^R'  fzy-history-widget
bindkey '^Xp' fzy-proc-widget

# Use rg and fd with fzy
zstyle :fzy:file command rg --files --type all
zstyle :fzy:cd   command fd --type=directory --follow

# More keybindings
bindkey -r "^K"
bindkey "^kk" kill-whole-line
bindkey "^ka" backward-kill-line
bindkey "^ke" kill-line

# Use option/alt arrow to move between words. This is the natural way
# on macOS and it is easy to set up in iTerm2 but Windows and mintty
# need more prodding. This setup should work everywhere.
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Override ohmyzsh default
bindkey "^[l" down-case-word

# Load zmv for powerful renaming
autoload -U zmv

# doctl aliases
alias dod='doctl compute droplet'
alias dov='doctl compute volume'

# Reload zsh config. Start a new shell if zshenv was also changed but
# that cannot be easily re-sourced.
alias reload='source "${ZDOTDIR:-$HOME}"/.zshrc'

# Windows MSYS2 specific settings
if [[ "$OSTYPE" = msys ]]; then
    # Fix completion for cygdrive-style paths (from
    # https://github.com/msys2/MSYS2-packages/issues/38).
    zstyle ':completion:*' fake-files /: '/:c d e f g h'
fi

# Always attach a tmux session over interactive SSH connections. All
# the condititions are explained here:
# https://stackoverflow.com/a/43819740
if [[ "$TERM" != "dumb" ]] && [ -z "$INSIDE_EMACS" ] && [ -z "$TMUX" ] && [ -n "$SSH_TTY" ] && [[ -o interactive ]]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
    exit
fi
