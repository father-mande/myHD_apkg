#!/bin/bash
NAME=%NAME%
APP_STORE_PATH=/myHD_scripts/Idesk/App_Store
export DISPLAY=:0
# export LIBVA_DRIVER_NAME=i965

if [ -e ${APP_STORE_PATH}/%NAME%/%NAME%.inc ] ; then
        source ${APP_STORE_PATH}/%NAME%/%NAME%.inc
fi
source /myHD_temp/info_adm.src

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_ADM_PORT} root@localhost "/usr/local/AppCentral/myHD/bin/startapp_asportal.sh %NAME% %GROUP%"
