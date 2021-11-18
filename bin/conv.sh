#!/bin/sh 
# set -x
NS_HOST=myHD
#APKG_PATH=/share/Public/apkg/for_64b
APKG_PATH="$(/usr/bin/dirname $(/usr/bin/dirname $(/usr/bin/dirname $(/usr/bin/realpath $0))))"
# APKG_PATH=/usr/local/AppCentral/${NS_HOST}
APKG_FOLDER=/usr/local
APKG_NAME="$1"
UBU="$3"
UVER=$(/usr/bin/confutil -get ${APKG_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
MYHD_BIN=${APKG_PATH}/bin
CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
APPS_PATH=${APKG_PATH}/${NS_HOST}_apkg/Apps
GEN_APKG_PATH=${APKG_PATH}/${NS_HOST}_apkg/apkg
FOND_PATH=${APKG_PATH}/${NS_HOST}_apkg/Fond

CONV=$(which convert)
if [ -z "$CONV" ] ; then
	if [ -e /usr/builtin/bin/convert ] ; then
		CONV=/usr/builtin/bin/convert
	fi
fi

usage(){
	echo "$(basename $0) APKG_NAME create ... generate if not exist gif and mng for the APKG"
	echo "$(basename $0) APKG_NAME update ... delete old icons and call generate"
	echo "$(basename $0) APKG_NAME delete ... supress generated icons if exist"
	echo "$(basename $0) APKG_NAME check ... just verify if icons exist"
}

## test if an application name is provide as first 
if [ -z "$1" ] ; then
	usage
	exit 1
else
	if [ ! -e ${APPS_PATH}/${1} ] ; then
		echo "Hum! seem that App name don't have require folder / files in ${APPS_PATH} "
		exit 1
	fi
fi
### check that files exist
case "$2" in
create)
PNG=$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} icon256)
FOND=$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} Fond)
if [ ! -e ${APKG_PATH}/${NS_HOST}_apkg/Fond/${FOND} ] ; then
	echo "OUPSS! === $FOND === don't exist fail back to ligth gray"
	FOND=fond_gris_clair.png
fi
if [ ! -e ${APPS_PATH}/${1}/${PNG} ] ; then
	echo "Star a check to verify if the icons exist ..."
	echo "can't generate if no source 256x256 minimum ${1}.png file"
	$0 check
else
	if [ -e ${APPS_PATH}/${1}/${1}-enable.png ] ; then
		echo "not generated use the file ${1}-enable.png  provide "
	else
		$CONV ${APPS_PATH}/${1}/${PNG} -resize 90x90  ${APPS_PATH}/${1}/${1}-enable.png
	fi
	
	if [ -e ${APPS_PATH}/${1}/${1}-disable.png ] ; then
		echo "not generated use the file ${1}-disable.png  provide "
	else
		$CONV ${APPS_PATH}/${1}/${PNG} -resize 90x90 -colorspace Gray  ${APPS_PATH}/${1}/${1}-disable.png
	fi
	
	if [ -e ${APPS_PATH}/${1}/${1}-asportal.png ] ; then
		rm -f ${APPS_PATH}/${1}/${1}-asportal.png
	fi
	$CONV ${APPS_PATH}/${1}/${PNG} -resize 170x170 ${APPS_PATH}/${1}/${1}-asportal.png
	rm -f ${APPS_PATH}/${1}/MH-${1}.png
	rm -f ${APPS_PATH}/${1}/MH16-${1}.png
	rm -f ${APPS_PATH}/${1}/MH18-${1}.png
	$CONV ${APKG_PATH}/${NS_HOST}_apkg/Fond/${FOND} ${APPS_PATH}/${1}/${1}-asportal.png  -resize 265x170 -gravity center -compose over -composite ${APPS_PATH}/${1}/MH${UBU}-${1}.png
	
	### time to copy the icons in good place
	cp -p ${APPS_PATH}/${1}/${1}-enable.png ${GEN_APKG_PATH}/${1}/MH${UBU}-${1}/CONTROL/icon-enable.png
	cp -p ${APPS_PATH}/${1}/${1}-enable.png ${GEN_APKG_PATH}/${1}/MH${UBU}-${1}/CONTROL/icon.png
	cp -p ${APPS_PATH}/${1}/${1}-disable.png ${GEN_APKG_PATH}/${1}/MH${UBU}-${1}/CONTROL/icon-disable.png
	cp -p ${APPS_PATH}/${1}/MH${UBU}-${1}.png ${GEN_APKG_PATH}/${1}/MH${UBU}-${1}/asportal/MH${UBU}-${1}.png
fi 
;;
check)
	echo "png for MH ...) "
	ls -l ${APPS_PATH}/${1}/*.png
;;
update)
	$0 delete
	$0 create
;;
delete)
	rm -f ${APPS_PATH}/${1}/${1}-enable.png ${APPS_PATH}/${1}/${1}-disable.png ${APPS_PATH}/${1}/${1}-asportal.png ${APPS_PATH}/${1}/MH${UBU}-${1}.png
;;
*)
	usage
esac
