#!/bin/sh

JOB=${PWD##*/}
DATE=$(date --iso-8601=seconds)

curl \
	-F apikey=b56b4b65b4bf3094f5e5c38debc679ffb12709ee \
	-F application=Make \
	-F event="Build complete" \
	-F description="$JOB completed on $DATE" \
	https://api.prowlapp.com/publicapi/add
