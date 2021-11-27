#!/bin/bash
NAME=%NAME%
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
export LIBVA_DRIVER_NAME=i965

if [ -e ${APP_STORE_PATH}/%NAME%/%NAME%.inc ] ; then
        source ${APP_STORE_PATH}/%NAME%/%NAME%.inc
fi

URL=%URL%
CHROME=$(which google-chrome-stable)

${CHROME} ${OPTIONS} ${URL}

