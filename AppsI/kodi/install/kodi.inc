#!/bin/bash

# export LANG=fr_FR.utf8
AUDIO=$(grep AUDIO /myHD_temp/info_adm.src | cut -f 2 -d "=")
export AUDIO
export LIBVA_DRIVER_NAME=i965
if [ "${AUDIO}" = "ALSA" ] ; then
#       /usr/bin/pasuspender -- env KODI_AE_SINK=ALSA
        export KODI_AE_SINK=ALSA
else
        ## AUDIO = PULSE
        ps -fu astr | grep -v grep | grep -q pulseaudio
        if [ $? -ne 0 ] ; then
                /usr/bin/pulseaudio --start --log-target=newfile:/tmp/pulseverbose.log --log-time=1 --disallow-exit &
                sleep 1
        fi
fi

