#!/bin/sh

KODI=$(which kodi)
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
if [ -e ${APP_STORE_PATH}/tkodi/tkodi.inc ] ; then
        source ${APP_STORE_PATH}/tkodi/tkodi.inc
fi

if [ "${AUDIO}" = "ALSA" ] ; then
#	/usr/bin/pasuspender -- env KODI_AE_SINK=ALSA
	export KODI_AE_SINK=ALSA
else
	## AUDIO = PULSE
	ps -fu astr | grep -v grep | grep -q pulseaudio
	if [ $? -ne 0 ] ; then
		/usr/bin/pulseaudio --start --log-target=newfile:/tmp/pulseverbose.log --log-time=1 --disallow-exit &
		sleep 1
	fi
fi
# export LIBVA_DRIVER_NAME=i965
# export KODI_AE_SINK=ALSA
$KODI 

