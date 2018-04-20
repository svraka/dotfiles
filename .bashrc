# Aliases

if [ $(expr index "$-" i) -eq 0 ]; then
    return
fi

if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

# https://unix.stackexchange.com/a/18443

export HISTFILESIZE=-1
export HISTSIZE=-1
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

shopt -s checkwinsize

# man ()
# {
#     run mintty --title="man $*" bash --norc -c "command man $@"
# }

export STATABATCH="$(cygpath -w /d/Apps/Stata13/StataSE-64.exe) -q -e"

RVERSION=$(ls -v1 /d/R/ | tail -1)

PATH=$PATH:/d/MiKTeX/miktex/bin/x64:/d/R/$RVERSION/bin/x64:~/bin

# PATH='$PATH:/c/ProgramData/Oracle/Java/javapath:/c/Program Files (x86)/Java/jre1.8.0_101/bin/client'

# Mivel az MSYS2 a D:-n van helytakarekossagi okokbol, az ottani tempdireket
# hasznalja, de ahhoz meg tul keves hely van, igy athelyezem a standard
# windowsos helyre.

export TEMP="/c/Users/$USER/AppData/Local/Temp"
export TMP="/c/Users/$USER/AppData/Local/Temp"

# A statab.sh hasznal egy ilyet is

export TMPDIR="/c/Users/$USER/AppData/Local/Temp"
