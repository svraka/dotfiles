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

function optimize_pdf() {
    # Run PDF file through ghostscript to compress size, useful for MS Word
    # created PDFs.

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
      -dNOPAUSE -dBATCH -dQUIET -dSAFER \
      -sOutputFile="$TEMP/optpdf.pdf" "${1}"

    mv "$TEMP/optpdf.pdf" "${1}"
}


# `statab.sh`-hoz a Stata executable helye.  Windowsos pathkent kell megadni!

export STATA_EXEC="C:/Program Files (x86)/Stata15/StataSE-64.exe"


# Path a szukseges utilitykkel es egyebekkel, plusz a
# [sima windowsos gittel](https://gitforwindows.org/) kiegeszitve.  Azert
# kell ide, mert az MSYS-es elavult es kevesbe megbizhato, es ezzel lesz
# wincredhez.

PATH_GIT_FOR_WINDOWS="/d/Git/cmd"
PATH_MIKTEX="/d/MiKTeX/miktex/bin/x64"
PATH_R="/d/R/$(ls -v1 /d/R/ | tail -1)/bin/x64"
PATH_BIN_MISC="/d/bin"

PATH=$PATH_GIT_FOR_WINDOWS:$PATH:$PATH_MIKTEX:$PATH_R:~/bin:$PATH_BIN_MISC

# PATH='$PATH:/c/ProgramData/Oracle/Java/javapath:/c/Program Files (x86)/Java/jre1.8.0_101/bin/client'

# Mivel az MSYS2 a D:-n van helytakarekossagi okokbol, az ottani tempdireket
# hasznalja, de ahhoz meg tul keves hely van, igy athelyezem a standard
# windowsos helyre.

export TEMP="/c/Users/$USER/AppData/Local/Temp"
export TMP="/c/Users/$USER/AppData/Local/Temp"

# A statab.sh hasznal egy ilyet is

export TMPDIR="/c/Users/$USER/AppData/Local/Temp"

# ssh-agent PuTTY-s kulcsokkal

eval $(/usr/bin/ssh-pageant -q -r -a "/c/Users/$USER/.ssh-pageant-$USERNAME")
