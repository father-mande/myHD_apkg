#!/bin/sh
BLUE="\033[0;36m"
NC="\033[0m"
RED="\033[0;31m"
IDESK_I="130x130"
BOLD="\033[1m"

usage(){
	echo -e "==== Usage : $0 Path_to_${RED}square${NC}_icon (resize to ${IDESK_I}) Path_to_background "
	echo -e "==== ex. ${BLUE}$0 kodi18.png ../back/fond_bleu_idesk.png${NC}"
	echo -e "==== result will be like : ${BOLD}kodi18_idesk.png${NC}"
	exit 1
}

##### by default work in myHD_apkg/genere_icons/save and back are in myHD_apkg/genere_icons/back
### test if we are in save
PWD=$(pwd)
if [ "$(basename "${PWD}")" != "save" ] ; then
	echo "HUM folder seem to not be : save ???"
	usage
else
	if [ "$(basename "$(dirname "${PWD}")")" != "genere_icons" ] ; then
		echo "HUM directory for save seem incorrect ???"
		usage
	fi
fi

if [ -z "$1" -o -z "$2" ] ; then
	usage
fi

if [ -e "$1" ] ; then
	if [ "${1##*.}" != "png" ] ; then
		echo "hum! : ${1} is not a .png file ????"
		exit 1
	fi
else
	echo "hum! $1 don't exist ? "
	exit 1
fi

if [ ! -e "$2" ] ; then
	echo "hum! $2 don't exist ?"
	exit 1
fi

if [ -e tempo.png ] ; then
	rm -f tempo.png
fi

### first convert to 130x130 icon
which convert
if [ $? -ne 0 ] ; then
	ln -s /usr/builtin/bin/magick /usr/builtin/bin/convert
fi

FILENAME=$(echo "${1%%.*}")
./generate_adm_icon.sh ${FILENAME}

convert "$1" -resize 130x130 tempo.png
NAME=$(basename "$1" .png)
convert "$2" tempo.png -gravity center -compose over -composite ${NAME}-Idesk.png

# rm tempo.png
echo "done"


