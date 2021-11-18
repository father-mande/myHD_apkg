#!/bin/sh
NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}
# APPS_PATH=/usr/local/AppCentral
UBU=%UBU%
APP=%NAME%

APKG_PATH=/usr/local/AppCentral/MH${UBU}-${APP}
SHELL_SCRIPT=${APP}.sh

APKG_FOLDER=/usr/local
# UVER MUST BE 2004
UVER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
MYHD_BIN=${MYHD_PATH}/bin
# CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
ASPORTAL_PATH=${APKG_FOLDER}/.${NS_HOST}/${NS_HOST}_scripts/Apps
IDESK_PATH=${APKG_FOLDER}/.${NS_HOST}/${NS_HOST}_scripts/Idesk/App_Store
# TEMP_PATH=${MYHD_PATH}/myHD_temp

asportal_install(){
	echo "==== start asportal install"
	if [ -e ${ASPORTAL_PATH}/MH${UBU}_${APP}.sh ] ; then
		rm -f ${ASPORTAL_PATH}/MH${UBU}_${APP}.sh.prev
		mv ${ASPORTAL_PATH}/MH${UBU}_${APP}.sh ${ASPORTAL_PATH}/Apps/MH${UBU}_${APP}.sh.prev
	fi
	cp -p ${APKG_PATH}/install/${SHELL_SCRIPT} ${ASPORTAL_PATH}/Apps/MH${UBU}_${APP}.sh
	chmod a+x ${ASPORTAL_PATH}/MH${UBU}_${APP}.sh
}

install_package_in_myHD(){
	echo "==== apt-get update / apt-get -y dist-upgrade"
	## change here to install package or appimage or nothing
	/usr/local/bin/myHD apt_upgrade_package
	if [ -e "${APKG_PATH}/install/install.inc" ] ; then
		source "${APKG_PATH}/install/install.inc"
	fi
	#/usr/local/bin/myHD_root "/usr/bin/apt-get -y install firefox"
	#/usr/local/bin/myHD_root "/usr/bin/apt-get -y install firefox-locale*"
	## here the install after an update / dist-upgrade
}

test_2004_for_idesk(){
	if [ "${UVER}" != "2004" ] ; then
		echo "Hum Ubuntu 2004 is require"
		/usr/sbin/syslog --log 0 --level 2 --user admin --event "install of MHI-${APP} is not done myHD Ubuntu is not 2004 ... restart it in the good env."
		${MYHD_BIN}/applog --level 2 --package "${NS_HOST}" --event  "install of MHI-${APP} is not done myHD Ubuntu is not 2004"
		exit 1
	else
		install_package_in_myHD
		# exit 0
	fi
}

fill_idesk_folder(){
	echo "==== fill Idesk folder"
	if [ ! -e ${IDESK_PATH}/${APP} ] ; then
		mkdir ${IDESK_PATH}/${APP}
	fi
	chmod 777 ${IDESK_PATH}/${APP}
	# cp ${APP}.sh .lnk and .inc (if exist)
	cp -pP ${APKG_PATH}/install/${APP}.* ${IDESK_PATH}/${APP}/
	cp -p ${APKG_PATH}/idesk/*-Idesk.png ${IDESK_PATH}/${APP}/
	if [ -e ${APKG_PATH}/install/files ] ; then
		cp ${APKG_PATH}/install/files/* ${IDESK_PATH}/${APP}/
	fi
}

add_launcher_if_idesk_run(){
	echo "==== try to add launcher in desktop"
	REP=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf idesk IDESK)	
	if [ "${REP}" = "TRUE" ] ; then
		IUSER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf idesk IUSER)
		if [ $? -ne 0 ] ; then
			IUSER="astr"
			/usr/bin/confutil -set ${MYHD_PATH}/${NS_HOST}.conf idesk IUSER ${IUSER}
		fi
		echo "==== start idesk_add_launcher.sh"
		# /usr/local/bin/${NS_HOST}_user ${IUSER} /${NS_HOST}_scripts/bin/idesk_add_launcher.sh APKG_IDESK ${APP}
		/usr/local/bin/${NS_HOST}_user ${IUSER} "export DISPLAY=:0 ; /${NS_HOST}_scripts/bin/idesk_add_launcher.sh APKG_IDESK ${APP}"
	else
		echo "Idesk not validated, add launcher manually from idesk interface"
		${MYHD_BIN}/applog --level 2 --package "MHI-${APP}" --event  "install of ${APP} is not done do it manually using Idesk interface"
	fi
}
install_part(){
	echo "==== install (start) require : $(date)"
	if [ ! -e ${APKG_PATH}/install/.already_installed ] ; then
		if [ "${UBU}" = "I" ] ; then
			echo "==== install Idesk App"
			test_2004_for_idesk
			fill_idesk_folder
			add_launcher_if_idesk_run
		else
			echo "==== install Asportal App."
			asportal_install
		fi
		touch ${APKG_PATH}/install/.already_installed
	## restart APKG if install nohup
		#echo "restart $(/usr/bin/basename ${APKG_PATH}) App if install use NOHUP"
		if [ -e ${APKG_PATH}/install/.nohup_install ] ; then
			rm -f ${APKG_PATH}/install/.nohup_install
			${APKG_PATH}/CONTROL/start-stop.sh restart
		fi
	fi
}

clean_idesktop(){
	echo "==== clean idesktop"
	IUSER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf idesk IUSER)
	rm -f /usr/local/.${NS_HOST}/${NS_HOST}_home/${IUSER}/.idesktop*/${APP}.lnk
	/usr/local/bin/${NS_HOST} restart_idesk
}

remove_part(){
	echo "==== now remove ${APP} from myHD Idesk App_Store"
	if [ -e ${IDESK_PATH}/${APP} ] ; then
		rm -rf ${IDESK_PATH}/${APP}
	fi
	clean_idesktop
}

case "${1}" in
	install)
		install_part
	;;
	uninstall)
		remove_part
	;;
	clean)
		clean_idesktop
	;;
	add)
		add_launcher_if_idesk_run
	;;
	*)
		echo "Usage : $0 [start|stop]"
	;;
esac
