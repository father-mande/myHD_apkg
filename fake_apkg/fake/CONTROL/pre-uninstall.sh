#!/bin/sh
UBU=%UBU%
NAME=%NAME%
PKG_NAME=MH${UBU}-${NAME}
PKG_PATH=/usr/local/AppCentral/${PKG_NAME}

NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}
TEMP_PATH=${MYHD_PATH}/${NS_HOST}_temp
SCRIPTS_PATH=${MYHD_PATH}/${NS_HOST}_scripts

echo "pre-uninstall"
case $APKG_PKG_STATUS in
        install)
                echo " case $APKG_PKG_STATUS "
        ;;
        uninstall)
			echo " case $APKG_PKG_STATUS "
			if [ -e ${PKG_PATH}/install/install.sh ] ; then
				${PKG_PATH}/install/install.sh uninstall  > /tmp/${PKG_NAME}_uninstall.log 2>&1 
			fi
        ;;
        upgrade)
				echo " case $APKG_PKG_STATUS "
		;;
        *)
                /usr/sbin/syslog -g 0 -l 1 --user admin --event "APKG $NAME false $APKG_PKG_STATUS status ??? "
        ;;
esac
