# Setting history location only makes sense in an interactive shell
export HISTFILE=$XDG_DATA_HOME/zsh/history

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

# Always source .env files
ZSH_DOTENV_PROMPT=false

# oh-my-zsh plugins
plugins=(
    conda-zsh-completion
    dotenv
    emacs
    extract
    sudo
    svraka-functions
    zsh-autosuggestions
    zsh-fzy
)

# The following plugins provide completion functions, which are normally
# installed with packages (either distro, or Homebrew). However, these tools are
# not part of MSYS, so completions are not generally available and we need to
# get them from Oh My Zsh plugins. There's a plugin for doctl as well but that
# sources the completion every time which is very slow on Windows, so we add a
# custom one. It can be updated by
#
#     doctl completion zsh > config/zsh/oh-my-zsh-custom/plugins/doctl-custom/doctl-custom.plugin.zsh
if [[ "$OSTYPE" == msys ]]; then
    plugins+=(
        doctl-custom
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

# Cross-platform conda setup and activating the base environment.
# TODO: doesn't work on Windows yet, see https://github.com/conda/conda/issues/9922
case $OSTYPE in
    msys)
        condabin=Scripts/conda.exe
        ;;
    *)
        condabin=bin/conda
        ;;
esac
__conda_setup="$($CONDA_BASE_DIR/$condabin 'shell.zsh' 'hook')"
if [ $? -eq 0 -a $OSTYPE != msys ]; then
    eval "$__conda_setup"
fi
unset __conda_setup

# Snakemake completion, see https://snakemake.readthedocs.io/en/stable/project_info/faq.html#how-to-enable-autocompletion-for-the-zsh-shell
compdef _gnu_generic snakemake

# Always attach a tmux session over interactive SSH connections. All
# the condititions are explained here:
# https://stackoverflow.com/a/43819740
if [[ "$TERM" != "dumb" ]] && [ -z "$INSIDE_EMACS" ] && [ -z "$TMUX" ] && [ -n "$SSH_TTY" ] && [[ -o interactive ]]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
    exit
fi
