#!/usr/bin/env bash

RELASE="$1"
INSTALL_DIR="$2"

URL_STABLE="https://www.rstudio.com/products/rstudio/download/"
URL_PREVIEW="https://www.rstudio.com/products/rstudio/download/preview/"


# Telepitesi hely ellenorzese

if [[ -d $INSTALL_DIR ]]; then
  if [[ ${INSTALL_DIR:(-1)} = "/" ]]; then
    INSTALL_DIR=""${INSTALL_DIR::-1}""
  fi
else
  echo "Hiba: telepitesi helynek egy letezo konyvtarat adj meg!"
  exit 1
fi


# Release kivasztasa

case "$RELASE" in
  "preview" ) URL="$URL_PREVIEW";;
  "stable"  ) URL="$URL_STABLE";;
  *         ) echo "Hibas opcio!  Lehetseges ertekek: preview, stable"; exit 1;;
esac

ZIP=$(curl -s "$URL" | grep -P 'RStudio.+\.zip' | perl -pe 's/.+href="(.+?)">.+/\1/g')


# Verzio ellenorzese

VERSION_INSTALLED=$(cat $INSTALL_DIR/VERSION)
VERSION_AVAILABLE=$(echo $ZIP | perl -pe 's/.+\/RStudio-(.+)\.zip/\1/g')

if [[ "$VERSION_INSTALLED" = "$VERSION_AVAILABLE" ]]; then
  echo "A legfrisebb verzio van telepitve.  Nem csinalok semmit."
  exit 0
fi


# Letoltes, kicsomagolas

INSTALLER="/tmp/RStudio.zip"

echo "Zip letoltese..."
curl -q -o "$INSTALLER" "$ZIP"

mkdir -p /tmp/RStudio
echo "Zip kicsomagolasa..."
unzip -q $INSTALLER -d /tmp/RStudio

echo "Masolas..."
rsync -ah --delete /tmp/RStudio/ "$INSTALL_DIR/"

echo "Letoltott fajlok torlese..."
rm "$INSTALLER"
rm -r /tmp/RStudio
