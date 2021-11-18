#!/bin/sh -e
### BEGIN INIT INFO
# Short-Description: Start or stop myHD Application
### END INIT INFO
UBU=%UBU%
NAME=%NAME%

PKG_NAME=MH${UBU}-${NAME}
PKG_PATH=/usr/local/AppCentral/${PKG_NAME}

NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}
TEMP_PATH=${MYHD_PATH}/${NS_HOST}_temp
SCRIPTS_PATH=${MYHD_PATH}/${NS_HOST}_scripts

ASPORTAL_PATH=/usr/local/AppCentral/asportal
ASPORTAL_STAT=$(apkg --info-installed asportal | grep 'Enabled:' | awk '{print $2}')

IUSER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf idesk IUSER)


. /lib/lsb/init-functions

start_daemon () {
if [ "${UBU}" != "I" ] ; then
    sed -i 's/\"show\":\".*\"/\"show\":\"true\"/g' ${PKG_PATH}/asportal/${PKG_NAME}.json

    if [ -e "$ASPORTAL_PATH" ] &&  [ "Yes" = "$ASPORTAL_STAT" ]; then
        $ASPORTAL_PATH/CONTROL/start-stop.sh reload &
    fi
else
	if [ ! -e ${PKG_PATH}/install/.already_installed ] ; then
		if [ -e ${PKG_PATH}/install/install.sh ] ; then
			if [ -e ${PKG_PATH}/install/.nohup_install ] ; then
				# APKG restarted at end of install
				${MYHD_PATH}/bin/nohup ${PKG_PATH}/install/install.sh install > /tmp/${PKG_NAME}_install.log 2>&1 &
			else
				${PKG_PATH}/install/install.sh install > /tmp/${PKG_NAME}_install.log 2>&1
			fi
		fi
	fi
fi
}

stop_daemon () {
if [ "${UBU}" != "I" ] ; then
    sed -i 's/\"show\":\".*\"/\"show\":\"false\"/g'  ${PKG_PATH}/asportal/${PKG_NAME}.json

    if [ -e "$ASPORTAL_PATH" ] && [ "Yes" = "$ASPORTAL_STAT" ]; then
       $ASPORTAL_PATH/CONTROL/start-stop.sh reload &
    fi
#else
#	if [ -e ${PKG_PATH}/install/install.sh ] ; then
#				${PKG_PATH}/install/install.sh clean  > /tmp/${PKG_NAME}_clean.log 2>&1 
#				sleep 2
fi
}

case "$1" in
    start)		
        log_daemon_msg "Starting daemon" "$PKG_NAME"
        start_daemon
        log_end_msg 0
        ;;
    stop)
        log_daemon_msg "Stopping daemon" "$PKG_NAME"
        stop_daemon
        log_end_msg 0
        ;;
    restart)
        log_daemon_msg "Restarting daemon" "$PKG_NAME"
        stop_daemon
		sleep 3
        start_daemon
        log_end_msg 0
        ;;
    debug)
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 2
        ;;
esac

if [ "$1" != "debug" ] ; then
    exit 0
fi
