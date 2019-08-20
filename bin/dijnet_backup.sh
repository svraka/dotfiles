#! /usr//bin/env bash
#
# Friss számlák letöltése és a dokumentumok alá
# szinkronizálása. Sajnos nem lehet válogatni a számlák között, így
# egyben le kell tölteni az összeset.

user=svraka
dijnet_archivum="/Users/andras/Documents/pénz/dijnet archivum/"
dijnet_dump_data="$TMPDIR/dijnet_dump_data/"

mkdir -p $dijnet_dump_data
pushd "$dijnet_dump_data"

# brew bash, mert a macOS bash elavult
/usr/local/bin/bash dijnet-dump.sh $user

popd

rsync -av --ignore-existing "$dijnet_dump_data" "$dijnet_archivum"

rm -r $dijnet_dump_data
