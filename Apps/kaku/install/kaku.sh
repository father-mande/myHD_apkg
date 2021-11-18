#!/bin/sh

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/X11:/usr/local/sbin:/usr/local/bin:/usr/local/jre/bin
KAKU=/usr/local/bin/kaku
export DISPLAY=:0
/usr/bin/pulseaudio --start --log-target=syslog
$KAKU 


