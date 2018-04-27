#!/bin/bash

# Create zero-byte *.dta files based on similarly named *.dta.xz, *.dta.gz files
# with the same modicication dates as the zipped files.

EXTENSION="$1"

case "$1" in
 "gz" ) EXTENSION=".gz";;
 "xz" ) EXTENSION=".xz";;
 *    ) echo "Hibas fajlnev"; exit 1;;
esac

function gettime () {
	GZTIME="$(ls -l --time-style=full-iso $1 | awk '{print $7, $8, $9}')"
	DTANAME=${1%.*}
	touch --date="$GZTIME" $DTANAME
}
export -f gettime

find . -name "*.dta$EXTENSION" | xargs -I {} bash -c 'gettime "$@"' _ {}
