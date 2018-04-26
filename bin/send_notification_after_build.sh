#!/usr/bin/env bash

if [ -n "$1" ]
then
	MESSAGE=" ($1)"
else
	MESSAGE=""
fi

JOB=${PWD##*/}
DATE=$(date --iso-8601=seconds)
BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')

DESCRIPTION="$JOB$BRANCH completed on $DATE$MESSAGE"

curl \
	-F apikey=b56b4b65b4bf3094f5e5c38debc679ffb12709ee \
	-F application=Make \
	-F event="Build complete" \
	-F description="$DESCRIPTION" \
	https://api.prowlapp.com/publicapi/add
