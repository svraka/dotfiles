# Move $HOME/bin to the top of $PATH because I sometimes put stuff
# there that conflicts with other programs.
export PATH="$HOME/bin:$PATH"

# MSYS2 sets its own path, so this cannot be called in `.zshenv`
# either. We add non-MSYS2 tools to $PATH.
if [[ "$OSTYPE" = msys ]]; then
    export PATH="$PATH_WIN_CUSTOM:$PATH"
fi

# Homebrew completion setup. Needs to be done before loading Oh My Zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# oh-my-zsh configuration

# Path to oh-my-zsh installation and customisations.
export ZSH="$HOME/.config/oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/oh-my-zsh-custom"

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
    doctl
    dotenv
    emacs
    extract
    sudo
    svraka-functions
    zsh-autosuggestions
    zsh-fzy
)

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

# Use coreutils ls on macOS and set the same options everywhere to
# hide Windows cruft. Also make output simpler and nicer
LS_OPTS='--color=auto --hide="ntuser.*" --hide="NTUSER.*" --hide="Thumbs.db" --group-directories-first -G -v'
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

# Colourful diff
if [[ $(which -s colordiff) ]]; then
    alias diff=colordiff
fi

# Set Emacs-friendly zsh-fzy keybindings
bindkey '^Xd' fzy-cd-widget
bindkey '^Xf' fzy-file-widget
bindkey '^R'  fzy-history-widget
bindkey '^Xp' fzy-proc-widget

# Use ag with fzy
zstyle :fzy:file command ag --silent -lQa -g ''

# Put latest command on top in fzy history
zstyle :fzy:file command builtin fc -l -n 1

# More keybindings
bindkey -r "^K"
bindkey "^kk" kill-whole-line
bindkey "^ka" backward-kill-line
bindkey "^ke" kill-line

# Override ohmyzsh default
bindkey "^[l" down-case-word

# Load zmv for powerful renaming
autoload -U zmv

# doctl aliases
alias dod='doctl compute droplet'
alias dov='doctl compute volume'
alias dossh='doctl compute ssh'

# Windows MSYS2 specific settings
if [[ "$OSTYPE" = msys ]]; then
    # Fix completion for cygdrive-style paths (from
    # https://github.com/msys2/MSYS2-packages/issues/38).
    zstyle ':completion:*' fake-files /: '/:c d e f g h'
fi

# Always attach a tmux session over interactive SSH connections. All
# the condititions are explained here:
# https://stackoverflow.com/a/43819740
if [[ "$TERM" != "dumb" ]] && [ -z "$TMUX" ] && [ -n "$SSH_TTY" ] && [[ -o interactive ]]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
    exit
fi
