#!/bin/sh

if [ -z "${1}" ] ; then
	echo "Usage"
 	echo "$0 NAME_of-square_image_WITHOUT extension ex. firefox"
	echo ".................. (for forefox.png 256x256 or whatever square)"
	exit 1
fi

if [ -e "${1}.png" ] ; then
	if [ $? -ne 0 ] ; then
		ln -s /usr/builtin/bin/magick /usr/builtin/bin/convert
	fi
	/usr/builtin/bin/convert "${1}.png" -resize 90x90 ${1}-enable.png
	/usr/builtin/bin/convert "${1}.png" -resize 90x90 -colorspace Gray ${1}-disable.png
else
	echo " $1 don't exist ????"
fi
