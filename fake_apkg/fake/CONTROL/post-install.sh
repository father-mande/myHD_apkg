#!/bin/sh
PKG_NAME="MH%UBU%-%NAME%"
APP=%NAME%
PKG_PATH=/usr/local/AppCentral/${NAME}

echo "post-install"
case $APKG_PKG_STATUS in
        install)
			echo " case $APKG_PKG_STATUS "
			if [ -e /share/Public/${NAME}.nohup_install ] ; then
				touch ${PKG_PATH}/install/.nohup_install
			fi
        ;;
        uninstall)
                echo " case $APKG_PKG_STATUS "
        ;;
        upgrade)
        	echo " case $APKG_PKG_STATUS "
			if [ -e /share/Public/${NAME}.nohup_install ] ; then
					touch ${PKG_PATH}/install/.nohup_install
			fi
		;;
        *)
                /usr/sbin/syslog -g 0 -l 1 --user admin --event "APKG $PKG_NAME false $APKG_PKG_STATUS status ??? "
        ;;
esac
