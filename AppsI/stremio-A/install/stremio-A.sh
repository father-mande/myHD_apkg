#!/bin/bash
NAME=%NAME%
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
export LIBVA_DRIVER_NAME=i965

if [ -e ${APP_STORE_PATH}/${NAME}/${NAME}.inc ] ; then
        source ${APP_STORE_PATH}/${NAME}/${NAME}.inc
fi

	## AUDIO = PULSE
ps -fu astr | grep -v grep | grep -q pulseaudio
if [ $? -ne 0 ] ; then
	/usr/bin/pulseaudio --start --log-target=newfile:/tmp/pulseverbose.log --log-time=1 --disallow-exit &
	sleep 1
fi
################## most important change in shell for AppImage
APPIMAGE=%APPIMAGE%
#OPTIONS_APP=" --no-sandbox --enable-features=VaapiVideoDecoder"
OPTIONS_APP=""
##################

LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss3.so /myHD_scripts/Idesk/App_Store/${NAME}/${APPIMAGE} "${OPTIONS_APP}"


