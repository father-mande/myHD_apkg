#!/bin/sh
NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}

APP=test
APKG_PATH=/usr/local/AppCentral/MH-${APP}
SHELL_SCRIPT=${APP}.sh

APKG_FOLDER=/usr/local
UVER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
MYHD_BIN=${APKG_PATH}/bin
CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
SCRIPTS_PATH=${APKG_FOLDER}/.${NS_HOST}/${NS_HOST}_${UVER}_scripts
TEMP_PATH=${MYHD_PATH}/myHD_temp

if [ ! -e ${APKG_PATH}/install/.already_installed ] ; then
	if [ -e ${SCRIPTS_PATH}/Apps/MH_${APP}.sh ] ; then
		rm -f ${SCRIPTS_PATH}/Apps/MH_${APP}.sh.prev
		mv ${SCRIPTS_PATH}/Apps/MH_${APP}.sh ${SCRIPTS_PATH}/Apps/MH_${APP}.sh.prev
	fi
	cp -p ${APKG_PATH}/install/${SHELL_SCRIPT} ${SCRIPTS_PATH}/Apps/MH_${APP}.sh
	chmod a+x ${SCRIPTS_PATH}/Apps/MH_${APP}.sh
	touch ${APKG_PATH}/install/.already_installed
fi

