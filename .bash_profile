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

taskkill () {
	ps -W | grep $1 | awk '{print $1}' | while read line; do echo $line | xargs kill -f; done;
}

# man ()
# {
#     run mintty --title="man $*" bash --norc -c "command man $@"
# }

function stata_ekezetek {
    tr "[őű][ŐŰ]" "[õû][ÕÛ]" | iconv -f UTF-8 -t CP1252
}

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



# `statab.sh`-hoz a Stata executable helye.  Windowsos pathkent kell megadni!

export STATA_EXEC="C:/Program Files (x86)/Stata15/StataSE-64.exe"

RVERSION=$(ls -v1 /d/R/ | tail -1)

# Windowsos git. Azert tettem ide, mert az MSYS-es neha binaris fajlokat
# modositottnak gondol akkor is, ha nem valtoztak, es kell a wincredhez is a
# `git_extra`
SOURCETREE_GIT="/c/Users/$USER/AppData/Local/Atlassian/SourceTree"
SOURCETREE_GIT_LOCAL="$SOURCETREE_GIT/git_local/cmd"
SOURCETREE_GIT_EXTRA="$SOURCETREE_GIT/git_extras"

PATH=$SOURCETREE_GIT_LOCAL:$SOURCETREE_GIT_EXTRA:$PATH:/d/MiKTeX/miktex/bin/x64:/d/R/$RVERSION/bin/x64:~/bin:/d/bin

# PATH='$PATH:/c/ProgramData/Oracle/Java/javapath:/c/Program Files (x86)/Java/jre1.8.0_101/bin/client'

# Mivel az MSYS2 a D:-n van helytakarekossagi okokbol, az ottani tempdireket
# hasznalja, de ahhoz meg tul keves hely van, igy athelyezem a standard
# windowsos helyre.

export TEMP="/c/Users/$USER/AppData/Local/Temp"
export TMP="/c/Users/$USER/AppData/Local/Temp"

# A statab.sh hasznal egy ilyet is

export TMPDIR="/c/Users/$USER/AppData/Local/Temp"
