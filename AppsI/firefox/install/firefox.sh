#!/bin/sh

FIREFOX=$(which firefox)
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
if [ -e ${APP_STORE_PATH}/firefox/firefox.inc ] ; then
        source ${APP_STORE_PATH}/firefox/firefox.inc
fi

${FIREFOX}
