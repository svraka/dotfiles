# General path settings
export PATH="$HOME/bin:/usr/local/sbin:$PATH"


# oh-my-zsh configuration

# Path to oh-my-zsh installation and customisations.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
LS_OPTS='--color=auto --hide="ntuser.*" --hide="NTUSER.*" --hide="Thumbs.db" --group-directories-first -G'
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

# Set Emacs-friendly zsh-fzy keybindings
bindkey '^Xd' fzy-cd-widget
bindkey '^Xf' fzy-file-widget
bindkey '^R'  fzy-history-widget
bindkey '^Xp' fzy-proc-widget

# Use ag with fzy
zstyle :fzy:file command ag --silent -lQa -g ''

# More keybindings
bindkey -r "^K"
bindkey "^kk" kill-whole-line
bindkey "^ka" backward-kill-line
bindkey "^ke" kill-line

# Override ohmyzsh default
bindkey "^[l" down-case-word

# Make a cuppa
export HOMEBREW_INSTALL_BADGE="☕️"

# Load zmv for powerful renaming
autoload -U zmv

# Windows MSYS2 specific settings
if [[ "$OSTYPE" = msys ]]; then
  # Fix completion for cygdrive-style paths (from
  # https://github.com/msys2/MSYS2-packages/issues/38).
  zstyle ':completion:*' fake-files /: '/:c d e f g h'

  export PATH="$PATH_GIT_FOR_WINDOWS:$PATH:$PATH_MIKTEX:$PATH_R:~/bin:$PATH_BIN_MISC"

  unset PATH_GIT_FOR_WINDOWS
  unset PATH_MIKTEX
  unset PATH_R
  unset PATH_BIN_MISC

  # Always use the regular Windows temp directory instead of
  # /tmp. This also works with R.
  export TMPDIR=$(cygpath -u "$USERPROFILE/AppData/Local/Temp/")
  export TMP=$TMPDIR
  export TEMP=$TMPDIR
fi

# Always attach a tmux session over interactive SSH connections. All
# the condititions are explained here:
# https://stackoverflow.com/a/43819740
if [ -z "$TMUX" ] && [ -n "$SSH_TTY" ] && [[ -o interactive ]]; then
  tmux attach-session -t ssh || tmux new-session -s ssh
  exit
fi

# Some simple functions to work with PDFs
function pdfpextr() {
    # this function uses 3 arguments:
    #   $1 is the first page of the range to extract
    #   $2 is the last page of the range to extract
    #   $3 is the input file
    #   output file will be named "inputfile_pXX-pYY.pdf" in current directory

    outputfile="`basename -s .pdf $3`_p${1}-p${2}.pdf"

    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage=${1} \
       -dLastPage=${2} \
       -sOutputFile=- \
       ${3} > "$outputfile"
}

function optimize_pdf() {
    # Run PDF file through ghostscript to compress size, useful for MS Word
    # created PDFs.

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
      -dNOPAUSE -dBATCH -dQUIET -dSAFER \
      -sOutputFile="$TEMP/optpdf.pdf" "${1}"

    mv "$TEMP/optpdf.pdf" "${1}"
}
