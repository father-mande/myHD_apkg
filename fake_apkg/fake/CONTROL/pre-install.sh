#!/bin/sh
NAME="MH%UBU%-%NAME%"
UBU_VER=%UBU%
PKG_PATH=/usr/local/AppCentral/${NAME}
NS_HOST=myHD
ENGINE_PATH=/usr/local/AppCentral/${NS_HOST}

test_ver_ubuntu(){
	UVER=$(/usr/bin/confutil -get ${ENGINE_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
	#if [ ! -z "$UBU_VER" ] ; then
		if [ "${UBU_VER}" != "I" ] ; then
			if [ "${UVER}" != "${UBU_VER}04" ] ; then
				/usr/sbin/syslog -g 0 -l 2 --user admin --event "${NAME} apkg is not for ${UVER} Ubuntu environment "
				exit 1
			fi
		fi
	#fi
}

test_engine_running(){
	#ps -eaf | grep jchroot | grep -q ${NS_HOST}
	#if [ $? -eq 0 ] ; then
	#	echo "Hum! ${NS_HOST} is started "
	#if [ "$(/usr/local/bin/${NS_HOST} is_myHD_running)" = "run" ] ; then
	ps -eaf | grep -v grep | grep -q /lib/systemd/systemd-logind
	if [ $? -eq 0 ] ; then
		echo "==== ${NS_HOST} is running "
	else
		/usr/sbin/syslog -g 0 -l 2 --user admin --event "${NAME} can not be installed if ${NS_HOST} is not running "
		exit 1
	fi
}

test_idesk_is_set(){
	REP=$(/usr/bin/confutil -get ${ENGINE_PATH}/${NS_HOST}.conf idesk IDESK)	
	if [ "${REP}" = "TRUE" ] ; then
	# if [ "$(/usr/local/bin/${NS_HOST} is_idesk_set)" = "set" ] ; then
		echo "==== Idesk in ${NS_HOST} is set"
	else
		/usr/sbin/syslog -g 0 -l 2 --user admin --event "${NAME} can not be installed if Idesk for ${NS_HOST} is not set"
		exit 1
	fi
}

only_for_MHI_apkg(){
	if [ "$(echo ${NAME} | cut -f 1 -d '-')" = "MHI" ] ; then
		test_idesk_is_set
	else
		echo "==== for asportal"
	fi
}

echo "pre-install"

case $APKG_PKG_STATUS in
        install)
                echo " case $APKG_PKG_STATUS "
				test_ver_ubuntu
				test_engine_running
				only_for_MHI_apkg
				rm -f /tmp/${NAME}*.log > /dev/null 2>&1
        ;;
        uninstall)
                echo " case $APKG_PKG_STATUS "
        ;;
        upgrade)
				echo " case $APKG_PKG_STATUS "
				test_ver_ubuntu
				test_engine_running
				only_for_MHI_apkg
		;;
        *)
                /usr/sbin/syslog -g 0 -l 1 --user admin --event "APKG ${NAME} false $APKG_PKG_STATUS status ??? "
        ;;
esac
