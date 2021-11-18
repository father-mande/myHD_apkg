#!/bin/sh
NS_HOST=myHD
APP=stremio
# APKG_PATH=/usr/local/AppCentral/MH-${APP}
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/X11:/usr/local/sbin:/usr/local/bin:/usr/local/jre/bin
### FISRT start xbindkeys to be able to EXIT stremio
if [ -e /${NS_HOST}_scripts/Apps/${APP}.already_installed ] ; then
	case "$1" in
	stop)
		kill -9 $(/bin/pidof stremio)
		kill -9 $(/bin/pidof xbindkeys)
		for P in $(ps -eaf | grep -v grep | grep stremio | tr -s ' ' | cut -f 2 -d ' ')
		do
			kill -9 $P 
		done
	;;
	*)
	/bin/pidof xbindkeys
	if [ $? -eq 0 ] ; then
		kill -9 $(/bin/pidof xbindkeys)
	fi
	/usr/bin/xbindkeys --file /${NS_HOST}_scripts/Apps/MH_stremio.xbindkeysrc

	STREMIO=$(/usr/bin/which stremio)
	export DISPLAY=:0
	/usr/bin/pulseaudio --start --log-target=syslog
	$STREMIO 
	;;
	esac
else
	export DISPLAY=:0
	/usr/bin/zenity --info --text="<span font='24'><b>Stremio</b>\n\nInstall is not finished\nPlease wait and retry later</span>" --timeout=10 --no-wrap
fi
