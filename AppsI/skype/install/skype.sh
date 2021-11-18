#!/bin/sh

PROG=$(which skypeforlinux)
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
if [ -e ${APP_STORE_PATH}/skype/skype.inc ] ; then
        source ${APP_STORE_PATH}/skype/skype.inc
fi

${PROG}
