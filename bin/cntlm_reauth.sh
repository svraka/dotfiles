#!/usr/bin/env bash

CNTLM_DIR="$1"

# cntlm lelovese

taskkill () {
	ps -W | grep $1 | awk '{print $1}' | while read line; do echo $line | xargs kill -f; done;
}

taskkill cntlm


# hash keszitese

echo "Add meg a jelszavad:"
HASH=$($CNTLM_DIR/cntlm.exe -H -c $CNTLM_DIR/cntlm.ini | grep 'PassNTLMv2' | perl -pe 's/PassNTLMv2\s+(.+?)\s.*/\1/g')

echo $HASH

# hash beirasa a konfigfajlba

cp $CNTLM_DIR/cntlm.ini.minta $CNTLM_DIR/cntlm.ini
sed -i "s/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/$HASH/g" $CNTLM_DIR/cntlm.ini
