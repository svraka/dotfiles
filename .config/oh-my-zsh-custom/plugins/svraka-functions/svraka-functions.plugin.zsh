# Custom shell functions

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

function doip() {
    # Get public IP address of Digitalocean droplet
    IP=$(doctl compute droplet list "$@" --format 'PublicIPv4' --no-header)

    if [ -z "$IP" ]; then
        >&2 echo "droplet not found"
        return 1
    else
        echo $IP
    fi
}

function dossh() {
    # SSH by droplet name
    ssh  $(doip "$@")
}

function duh() {
    # Friendly and informative `du`
    dir="$@"
    if [ -z "$dir" ]; then
        dir="."
    fi

    # `(D)` is a zsh glob operator, that includes hidden files
    du -hcs "$dir"/*(D) | sort -h
}
