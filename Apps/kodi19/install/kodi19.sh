#!/bin/sh

KODI=$(which kodi)
export DISPLAY=:0
export KODI_AE_SINK=ALSA
$KODI 
