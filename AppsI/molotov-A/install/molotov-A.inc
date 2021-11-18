#!/bin/bash

# export LANG=fr_FR.utf8
AUDIO=$(grep AUDIO /myHD_temp/info_adm.src | cut -f 2 -d "=")
export AUDIO
export LIBVA_DRIVER_NAME=i965

