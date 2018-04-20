#!/bin/bash

# Create zero-byte *.dta files based on similarly named *.dta.gz files with the
# same modicication dates as the zipped files.

function gettime () {
	GZTIME="$(ls -l --time-style=full-iso $1 | awk '{print $7, $8, $9}')"
	DTANAME=${1%.gz}
	touch --date="$GZTIME" $DTANAME
}
export -f gettime

find . -name "*.dta.gz" | xargs -I {} bash -c 'gettime "$@"' _ {}
