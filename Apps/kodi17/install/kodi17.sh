#!/bin/sh
if [ ! -e $HOME/mykodi17 ] ; then
	mkdir $HOME/mykodi17
fi
export HOME=$HOME/mykodi17

KODI=/opt/kodi17/bin/kodi
export DISPLAY=:0
export AE_SINK=ALSA
$KODI 
