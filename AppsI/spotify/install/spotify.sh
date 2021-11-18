#!/bin/bash

APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
export LIBVA_DRIVER_NAME=i965
if [ -e ${APP_STORE_PATH}/spotify/spotify.inc ] ; then
        source ${APP_STORE_PATH}/spotify/spotify.inc
fi
AUDIO=$(grep AUDIO /myHD_temp/info_adm.src | cut -f 2 -d "=")

if [ "${AUDIO}" = "ALSA" ] ; then
        HW=$(grep hw: /etc/pulse/default.pa | grep -v "^#" | cut -f 2 -d "=")
        OPTIONS="--alsa-output-device=${HW} "
fi

CHROME=$(which google-chrome-stable)

${CHROME} ${OPTIONS} https://open.spotify.com/

