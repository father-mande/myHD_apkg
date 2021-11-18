#!/bin/sh
NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}
APKG_FOLDER=/usr/local
UBU=%UBU%
APP=%NAME%
APKG_PATH=/usr/local/AppCentral/MH${UBU}-${APP}
SHELL_SCRIPT=${APP}.sh

UVER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
SCRIPTS_PATH=${APKG_FOLDER}/.${NS_HOST}/${NS_HOST}_${UVER}_scripts

exit_pmp(){
	/usr/sbin/apkg --list | grep "MH-pmp"
	if [ $? -eq 0 ] ; then
		/usr/sbin/apkg --remove MH-pmp
	fi
}

install_it(){
	### now install the product in myHD
	cd ${CHROOT_PATH}/opt
	if [ -e ${APP} ] ; then
		if [ -e ${APP}.saved ] ; then
			rm -rf ${APP}.saved
		fi
		mv ${APP} ${APP}.saved
		rm -f Qt
	fi
	/bin/tar --same-owner -xzf ${APKG_PATH}/install/${APP}.tgz
	ln -s pmp/Qt
	/bin/chown -h root:root Qt
	###
	/bin/cp -pPR pmp/mpv/lib/* ${CHROOT_PATH}/usr/local/lib/
	###
	if [ -e ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh ] ; then
		rm -f ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh.prev
		mv ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh.prev
	fi
	cp -p ${APKG_PATH}/install/${SHELL_SCRIPT} ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh
	chmod a+x ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh
}
if [ ! -e ${APKG_PATH}/install/.already_installed ] ; then
	install_it
	exit_pmp
	touch ${APKG_PATH}/install/.already_installed
fi

