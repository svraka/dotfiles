#!/usr/bin/env bash

# Unpack office xml files (xlsx, pptx etc)
# Uses xmllint to pretty format any xml files found
# Recursively expands any embeded office documents (e.g. xlsx inside pptx)

fn="$1"
if [ -z "$fn" ]; then
    echo "What is the input file"
    exit 1
fi

if [ ! -f "$fn" ]; then
    echo "File not found: $fn"
    exit 1
fi

dname=$(dirname "$fn")
name=$(basename "$fn")
ext="${name##*.}"
base="${name%.*}"

outdir="$dname/$base"
if [ -n "$2" ]; then
    outdir="$2"
fi

echo "UNPACK $fn -> $outdir"

mkdir -p "$outdir" || exit 1

function pretty-xml {
    echo "  $1"
    xml="$1"
    new="$xml.new"
    xmllint -format $xml > $new || exit 1
    mv $new $xml
}
export -f pretty-xml

unzip -oqd "$outdir" "$fn" || exit 1
find "$outdir" -name '*.xml' -exec bash -c 'pretty-xml "{}"' \;
find "$outdir" \( -name '*.xlsx' -o -name '*.pptx' -o -name '*.docx' \) -exec "$0" "{}" \;
