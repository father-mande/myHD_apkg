#!/bin/bash

# KODI=$(which kodi)
APP="$(which %NAME%)"
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
export LIBVA_DRIVER_NAME=i965

if [ -e ${APP_STORE_PATH}/kodi/kodi.inc ] ; then
        source ${APP_STORE_PATH}/kodi/kodi.inc
fi


${APP}

