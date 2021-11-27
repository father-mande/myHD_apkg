#!/bin/bash

# export LANG=fr_FR.utf8
AUDIO=$(grep AUDIO /myHD_temp/info_adm.src | cut -f 2 -d "=")
export AUDIO
export LIBVA_DRIVER_NAME=i965

AUDIO=$(grep AUDIO /myHD_temp/info_adm.src | cut -f 2 -d "=")

if [ "${AUDIO}" = "ALSA" ] ; then
        HW=$(grep hw: /etc/pulse/default.pa | grep -v "^#" | cut -f 2 -d "=")
        OPTIONS="--alsa-output-device=${HW} "
fi

OPTIONS="${OPTIONS} --enable-features=VaapiVideoDecoder"
