#!/bin/sh
NAME=MH%UBU%-%NAME%

XORG_PATH=/usr/local/AppCentral/xorg
PKG_PATH=/usr/local/AppCentral/${NAME}

export DISPLAY=:0
DEBUG="false"

if [ "true" == "$DEBUG" ]; then

echo ">>>KODI env>>>"
echo PKG_PATH: $PKG_PATH
echo ""
echo PATH: $PATH
echo ""
echo LD_LIBRARY_PATH: $LD_LIBRARY_PATH
echo ""
echo LD_PRELOAD: $LD_PRELOAD
echo "<<<KODI env<<<"

fi
