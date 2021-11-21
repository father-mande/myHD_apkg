#!/bin/sh
NS_HOST=myHD
# APKG_PATH=/share/Public/apkg/for_64b or actual place for
APKG_PATH="$(/usr/bin/dirname "$(/usr/bin/dirname "$(/usr/bin/realpath $0)")")"
# APKG_FOLDER=/usr/local
# UVER=$(/usr/bin/confutil -get ${APKG_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
# MYHD_BIN=${APKG_PATH}/bin
# CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
MYHD_APKG_PATH=${APKG_PATH}/${NS_HOST}_apkg
FILE_PATH=${APKG_PATH}/files
APPS_PATH=${MYHD_APKG_PATH}/Apps
APPSI_PATH=${MYHD_APKG_PATH}/AppsI
# echo -e "MYHD_APKG_PATH : ${MYHD_APKG_PATH} ... APPS_PATH : ${APPS_PATH}"
GEN_APKG_PATH=${APKG_PATH}/apkg
FILES_ADD=${APKG_PATH}/files
# TEMP_APKG_PATH=${APKG_PATH}/${NS_HOST}_apkg/temp

BLUE="\033[0;36m"
NC="\033[0m"
RED="\033[0;31m"

APKG_NAME="$2"
VER="1.0.99"
PNG="${APKG_NAME}.png"
# SHELL_SCRIPT="${APKG_NAME}.sh"
UBU=""

set_www(){
	BLUE="<b>"
	NC="</b>"
	RED="<b>"
}

usage(){
	echo "$(basename $0) usage :"
	echo "=========="
	echo -e "${RED}ATTENTION${NC} ${BLUE}APKG_NAME${NC} is the name for internal ${NS_HOST} usage ${RED}NOT${NC} the name of the APKG generated"
	echo -e "......... ex. If APKG_NAME is ${BLUE}kodi18${NC} (to use in command here after) BUT Asustor/Asportal APKG_NAME will be ${BLUE}MH-kodi18${NC} (${RED}MH-${NC} is added automatically)"
	echo "=========="
	echo -e "$(basename $0) ${BLUE}create APKG_NAME UBU ${NC}... create and generate the associated ${NS_HOST} APKG for UBU (ALL(or nothing),16,18 Ubuntu env.)"
	#echo -e "$(basename $0) ${BLUE}delete APKG_NAME ${NC}... delete previously created associated APKG (but not remove it from Asportal (look here after for remove it))"
	echo -e "$(basename $0) ${BLUE}status ${NC}... List ALL existing generated APKGs files and if installed in Asportal"
	echo -e "$(basename $0) ${BLUE}list_all_installed_apkg ${NC}... list ${NS_HOST} APKGs installed in Asportal (include myHD externaly generated)"
	echo "=========="
	echo -e "$(basename $0) ${BLUE}status APKG_NAME ${NC}... verify if generated APKG files exist (MH-${BLUE}APKG_NAME${NC}_Version.apk) "
	echo -e "$(basename $0) ${BLUE}install [MH-APKG_NAME|MH16-APKG_NAME|MH18-APKG_NAME] [Version] ${NC}... install the generated ${NS_HOST} companion APKG in Asportal"
	echo -e "$(basename $0) ${BLUE}remove [MH-APKG_NAME|MH16-APKG_NAME|MH18-APKG_NAME] ${NC}... uninstall the associated APKG in Asportal"
	echo -e "$(basename $0) ${BLUE}delete [MH-APKG_NAME|MH16-APKG_NAME|MH18-APKG_NAME] [Version] ${NC}... delete MHxx-APKG_NAME_Version_x86-64.apk generated"
	echo "=========="
	echo -e "$(basename $0) ${BLUE}list_skeleton ${NC}... list skeleton for Applications and files already available to generate .apk (MH(MH16 or MH18)-${BLUE}APKG_NAME${NC}_Version.apk)"
	echo "=========="
	echo -e "$(basename $0) ${BLUE}copy_apkg_to_public_share [MH-APKG_NAME|MH16-APKG_NAME|MH18-APKG_NAME] [Version] ${NC}... copy MHxx-${BLUE}APKG_NAME${NC}_Version_x86-64.apk file to /share/Public (Public shared ressource) for a AppCentral WebUI install"
}

verify_cfg(){
	if [ ! -e ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ] ; then
		echo "NO ${APKG_NAME}.cfg file so try default"
		# create default file
		echo "[${APKG_NAME}]" > ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg
		echo "Version = 1.0.99" >> ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg
		echo "icon256 = ${APKG_NAME}.png" >> ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg
		echo "Shell = ${APKG_NAME}.sh" >> ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg
		if [ ! -e ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.sh ] ; then
			echo "Hum! ${APKG_NAME}.sh is require if no .cfg file"
			exit 1
		else
			if [ ! -e ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.png ] ; then
				echo "Hum! ${APKG_NAME}.png is require if no .cfg file"
				exit 1
			fi
		fi
		echo "Version forced to 1.0.99 ; default icon ${APKG_NAME}.png and default shell script ${APKG_NAME}.sh are used"
	else
		VER="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} Version)"
		if [ $? -ne 0 ] ; then
			echo "Version not provide force fake one"
			VER=1.1
		fi
		#######################
	  if [ ${UBU} = "I" ] ; then
		ICONIDESK="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} iconIdesk)"
		if [ $? -ne 0 ] ; then
		### must be changed to use a default icon ...
			echo "Hum! Idesk icon is not defined in .cfg "
			exit 1
		fi
		if [ ! -e ${APPS_PATH}/${APKG_NAME}/${ICONIDESK} ] ; then
			echo "Hum! ${ICONIDESK} is require and don't exist ????"
			exit 1
		fi
	  else	
		PNG="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} icon256)"
		if [ $? -ne 0 ] ; then
			PNG=${APKG_NAME}.png
			if [ ! -e ${APPS_PATH}/${APKG_NAME}/${PNG} ] ; then
				echo "Hum! ${APKG_NAME}.png is require is not define in .cfg file"
				exit 1
			fi
		else
			### add test if suffix is png
			if [ "${PNG##*.}" != "png" ] ; then
				echo "hum! : ${PNG} is not a .png file ????"
				exit 1
			fi
		fi
		
		FOND="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} Fond)"
		if [ $? -ne 0 ] ; then
			echo "force light gray background for Asportal icon"
			FOND=fond_gris_clair.png
		fi
	  fi
		if [ ! -e ${APPS_PATH}/${APKG_NAME}/install/install.sh ] ; then
			echo "Hum! ${APKG_NAME}don't have the require install/install.sh folder & file"
			echo "===== USE THE DEFAULT ${APPSI_PATH}/install.sh "
		fi
		
		CTRL="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} Ctrl)"
		if [ $? -ne 0 ] ; then
			echo "force default as CTRL"
			CTRL="default"
		fi
		
		
		CONFIG_JSON="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} config_json)"
		if [ $? -ne 0 ] ; then
			echo "Use config2.json for generated config.json"
			CONFIG_JSON=""
		fi
		
		APPIMAGE="$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} appimage)"
		if [ $? -ne 0 ] ; then
			echo "NOT APKG with AppImage exec"
			APPIMAGE=""
		fi
		
		CAPTION=$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} caption)
		if [ $? -ne 0 ] ; then
			echo "NOT IDESK Caption for APKG replace by ${APKG_NAME}"
			CAPTION="${APKG_NAME}"
		fi
		
		URL=$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} url)
		if [ $? -ne 0 ] ; then
			echo "NO URL defined for this App.  ${APKG_NAME}"
			URL=""
		fi
		# UBU=$(/usr/bin/confutil -get ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.cfg ${APKG_NAME} UBU)
		## UBU can be null or contains 16 for Ubuntu 16.04 or 18 for Ubuntu 18.04
		# if [ ! -z "$UBU" ] ; then
			# if [ "$UBU" = "18" -o "$UBU" = "16" ] ; then
			# 	echo "Ubuntu version is ${UBU}04"
			# else
			# 	UBU=""
			# fi
		# fi
	fi
}

if [ -z "$1" ] ; then
	usage
	exit 1
fi

if [ ! -e ${GEN_APKG_PATH} ] ; then
	mkdir ${GEN_APKG_PATH}
	chmod 777 ${GEN_APKG_PATH}
fi

if [ ! -e ${FILES_ADD} ] ; then
	mkdir ${FILES_ADD}
	chmod 777 ${FILES_ADD}
fi

case "$1" in 
create)
	UBU="$3"
	# test if UBU = ALL / 16 or 18 or 20 or I
	if [ -z "${UBU}" ] ; then
		UBU=ALL
	else
		if [ "${UBU}" = "ALL" -o "${UBU}" = "16" -o "${UBU}" = "18" -o "${UBU}" = "20" -o "${UBU}" = "I" ] ; then
			echo "Ubuntu version supported is : $UBU (I is  for 20 + Idesk) "
		else
			echo "HUM! Ubuntu version (3em param) must be ALL / 16/18/20 or I (or nothing) NOT : ${UBU} "
			exit 1
		fi
	fi
	if [ "${UBU}" = "I" ] ; then
		APPS_PATH="${APPSI_PATH}"
	fi
	#if [ -e ${GEN_APKG_PATH}/${APKG_NAME} ] ; then	
	#	echo "Hum! APKG ${APKG_NAME} already exist ... delete it if you want to change it"
	#	exit 1
	#fi
	if [ -e ${APPS_PATH}/${APKG_NAME} ] ; then
		echo "using ${APPS_PATH}/${APKG_NAME} to build apkg"
	else
		echo "HUM! no valid folder in Apps : ${APKG_NAME}_${UBU}"
		exit 1
	fi
	if [ "${UBU}" = "ALL" ] ; then
		UBU=""
	fi
	
	verify_cfg
	if [ ! -e ${GEN_APKG_PATH}/${APKG_NAME} ] ; then
		mkdir ${GEN_APKG_PATH}/${APKG_NAME}
	fi
	cp -pPR ${APKG_PATH}/${NS_HOST}_apkg/fake_apkg/* ${GEN_APKG_PATH}/${APKG_NAME}/
	## rename fake as MH${UBU}-${APKG_NAME}
	mv ${GEN_APKG_PATH}/${APKG_NAME}/fake ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}
	# build config.json before modding it
	if [ -z "${CONFIG_JSON}" ] ; then
		cat ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config1.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config2.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config3.json > ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config.json
	else
		if [ -s ${APPS_PATH}/${APKG_NAME}/${CONFIG_JSON} ] ; then
			cat ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config1.json ${APPS_PATH}/${APKG_NAME}/${CONFIG_JSON} ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config3.json > ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config.json
		else
			cat ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config1.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config2.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config3.json > ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config.json
		fi
	fi
	rm -f ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config1.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config2.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config3.json
	#
	sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config.json
	sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config.json
	sed -i "s/%VER%/${VER}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/config.json
	
	sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/env.sh
	sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/env.sh
	
	sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/pre-install.sh
	sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/pre-install.sh
	
	sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/pre-uninstall.sh
	sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/pre-uninstall.sh
	
	sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/post-install.sh
	sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/post-install.sh
	
	sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/start-stop.sh 
	sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/start-stop.sh 
	
	echo "myHD MH${UBU}-${APKG_NAME}" > ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/description.txt
	##
	#
	
	#UBU = I is not for asportal
	if [ "${UBU}" = "I" ] ; then
		echo "No asportal folder"
		rm -rf ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal
		rm -f ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/run_fake.sh
		mkdir ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/idesk
	else
		echo "For Asportal"
		mv ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/run_fake.sh ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/run_MH${UBU}-${APKG_NAME}.sh
		sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/run_MH${UBU}-${APKG_NAME}.sh
		sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/run_MH${UBU}-${APKG_NAME}.sh
		mv ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/fake.json ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/MH${UBU}-${APKG_NAME}.json
		sed -i "s/%NAME%/${APKG_NAME}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/MH${UBU}-${APKG_NAME}.json
		sed -i "s/%UBU%/${UBU}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/MH${UBU}-${APKG_NAME}.json
		sed -i "s/%CTRL%/${CTRL}/g" ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/MH${UBU}-${APKG_NAME}.json
		if [ -e ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/fake.png ] ; then
			rm -f ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/asportal/fake.png
		fi
	fi
	# time to generate icons and copy it to CONTROL & asportal folder in ${APKG_NAME} APKG folder
	if [ "${UBU}" != "I" ] ; then	
		${APKG_PATH}/${NS_HOST}_apkg/bin/conv.sh ${APKG_NAME} create ${UBU}
		if [ $? -ne 0 ] ; then
			echo "Hum generate the icons fail ??? "
			echo "deleting parts already built"
			$0 delete ${APKG_NAME}
			exit 1
		fi 
	else
		if [ -e ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}-Idesk.png ] ; then
			cp -p ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}-Idesk.png ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/idesk
		else
			echo "Idesk icon is not generated, please create it"
			echo "deleting parts already built"
			$0 delete ${APKG_NAME}
			exit 1
		fi
		cp -p ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}-enable.png   ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/icon-enable.png
		cp -p ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}-disable.png   ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/icon-disable.png
		cp -p ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}-enable.png   ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/CONTROL/icon.png
	fi
	#if [ "${UBU}" != "I" ] ; then
	#	APPS_PATH="${APPSI_PATH}"
	#fi
	## TODO REPLACE by install folder + install.sh
	if  [ ! -e ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh ] ; then
		echo "Hum! no script to run & launch ${APKG_NAME}"
		echo "Stop build"
		# $0 delete ${APKG_NAME}
		exit 1
	else
	## to be moves (sed) after the copy so no more .bak ....
		#cp -p ${APPS_PATH}/${APKG_NAME}/install/install.sh ${APPS_PATH}/${APKG_NAME}/install.sh.bak
		#cp -p ${APPS_PATH}/${APKG_NAME}/install/install.inc ${APPS_PATH}/${APKG_NAME}/install.inc.bak
		if [ ! -e ${APPS_PATH}/${APKG_NAME}/install/install.inc ] ; then
			cp -p ${APPSI_PATH}/install.inc ${APPS_PATH}/${APKG_NAME}/install/
		fi
		if [ ! -e ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.lnk ] ; then
			cp -p ${APPSI_PATH}/generic.lnk ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.lnk
		fi
		cp -p ${APPSI_PATH}/install.sh ${APPS_PATH}/${APKG_NAME}/install/
		cp -p ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.sh.bak
		cp -p ${APPS_PATH}/${APKG_NAME}/install/install.inc ${APPS_PATH}/${APKG_NAME}/install.inc.bak
		sed -i "s/%NAME%/${APKG_NAME}/g" ${APPS_PATH}/${APKG_NAME}/install/install.sh
		sed -i "s/%UBU%/${UBU}/g" ${APPS_PATH}/${APKG_NAME}/install/install.sh
		
		sed -i "s/%NAME%/${APKG_NAME}/g" ${APPS_PATH}/${APKG_NAME}/install/install.inc
		
		sed -i "s/%NAME%/${APKG_NAME}/g" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.lnk
		sed -i "s/%CAPTION%/${CAPTION}/g" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.lnk

		sed -i "s/%NAME%/${APKG_NAME}/g" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		
		grep -q "^APPIMAGE=" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		if [ $? -eq 0 ] ; then
			sed -i "s/%APPIMAGE%/${APPIMAGE}/g" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		fi
		grep -q "^URL=" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		if [ $? -eq 0 ] ; then
			sed -i "s,%URL%,${URL},g" ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		fi
		
		if [ ! -e ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install ] ; then
			mkdir ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install
		fi
		
		cp -p ${APPS_PATH}/${APKG_NAME}/install/install.* ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/
		cp -p ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.* ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/
		chmod a+x ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/install.sh	
		# cp -pP ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.* ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/
		chmod a+x ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/${APKG_NAME}.sh
		
		rm -f ${APPS_PATH}/${APKG_NAME}/install/install.sh
		rm -f ${APPS_PATH}/${APKG_NAME}/install/install.inc
		rm -f ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		#mv ${APPS_PATH}/${APKG_NAME}/install.sh.bak ${APPS_PATH}/${APKG_NAME}/install/install.sh
		mv ${APPS_PATH}/${APKG_NAME}/install.inc.bak ${APPS_PATH}/${APKG_NAME}/install/install.inc
		mv ${APPS_PATH}/${APKG_NAME}/${APKG_NAME}.sh.bak ${APPS_PATH}/${APKG_NAME}/install/${APKG_NAME}.sh
		#
		if [ -e ${FILE_PATH}/${APKG_NAME}/files${UBU} ] ; then
			mkdir ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/files
			echo "==== adding files for APKG"
			cp -pPR ${FILE_PATH}/${APKG_NAME}/files${UBU}/* ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/files/
		fi
		#if [ -e ${APPS_PATH}/${APKG_NAME}/install/files${UBU} ] ; then
		#	cp -pPR ${APPS_PATH}/${APKG_NAME}/install/files${UBU}/* ${GEN_APKG_PATH}/${APKG_NAME}/MH${UBU}-${APKG_NAME}/install/
		#fi
		
	fi
	### END OF TODO
	
	### end of change NOW create the apkg
	PWD=$(pwd)
	cd ${GEN_APKG_PATH}/${APKG_NAME}
	${APKG_PATH}/${NS_HOST}_apkg/apkg-tools.py create MH${UBU}-${APKG_NAME}
	##
	rm -rf MH${UBU}-${APKG_NAME}
	rm -f apkg-tools.py
	cd ${PWD}
	#
	;;
status)
	if [ "${APKG_NAME}" = "www" ] ; then
		set_www
		if [ ! -z "$3" ] ; then
			APKG_NAME="$3"
		else
			APKG_NAME=""
		fi
	fi
	if [ -z "${APKG_NAME}" ] ; then
		echo "Search for ALL APK generated or not for ${NS_HOST}"
		for F in ${GEN_APKG_PATH}/*
		do
			echo "====="
			if [ "$(basename ${F})" != "*" ] ; then
			for Q in ${F}/*.apk
			do
				if [ -e ${Q} ] ; then 
					echo -e "apkg for $BLUE $(basename ${F}) $NC exist : $(ls ${Q}) "
				else	
					echo -e "NO apkg available for $BLUE $(basename ${F}) $NC "
				fi
			done 
			### test if apkg is installed ?
			## echo -e "search if APKG $BLUE $(basename ${F}) $NC is installed as $BLUE MH-$(basename ${F}) $NC"
			for UBU in "16" "18" ""
			do
				/usr/sbin/apkg --list | grep -q "^MH${UBU}-$(basename ${F})"
				if [ $? -eq 0 ] ; then	
					#echo -e "APKG $BLUE $(basename ${F}) $NC is installed as $BLUE MH${UBU}-$(basename ${F}) $NC"
					echo -e "---- APKG $BLUE $(basename ${F}) $NC is installed in Asportal as  $BLUE MH${UBU}-$(basename ${F}) $NC"
					echo -e "---- ---- $BLUE MH${UBU}-$(basename ${F}) $NC version installed is : $(apkg --info-installed MH${UBU}-$(basename ${F}) | grep Version | cut -f 2 -d " ") "
				else
					echo -e "---- APKG $BLUE MH${UBU}-$(basename ${F}) $NC for Ubuntu ${UBU} version  is ${RED}NOT installed${NC} in Asportal"
				fi
			done
			fi
		done
		echo "====="
	else	
		echo -e "Search for generated APKG for $BLUE ${APKG_NAME} $NC"
		echo "====="
		ls ${GEN_APKG_PATH}/${APKG_NAME}/*.apk >/dev/null 2>&1
		if [ $? -eq 0 ] ; then
			## ADD if multiple version available
			for F in ${GEN_APKG_PATH}/${APKG_NAME}/*.apk
			do
				echo -e "apkg for $BLUE ${APKG_NAME} $NC exist : ${F}"
			done
		else	
			echo -e "NO apkg available for $BLUE ${APKG_NAME} $NC"
		fi
		### test if apkg is installed ?	
		for UBU in "16" "18" ""
		do
			#echo -e "search if APKG $BLUE ${APKG_NAME} $NC is installed as $BLUE MH${UBU}-${APKG_NAME} $NC"
			/usr/sbin/apkg --list | grep -q "^MH${UBU}-${APKG_NAME}"
			if [ $? -eq 0 ] ; then	
				echo -e "---- APKG $BLUE ${APKG_NAME} $NC is installed in Asportal as  $BLUE MH${UBU}-${APKG_NAME} $NC"
				echo -e "---- ----$BLUE MH${UBU}-${APKG_NAME} $NC version installed is : $(apkg --info-installed MH${UBU}-${APKG_NAME} | grep Version | cut -f 2 -d " ") "
			else
				echo -e "---- APKG $BLUE ${APKG_NAME} $NC for Ubuntu ${UBU} version  is ${RED}NOT installed${NC} in Asportal"
			fi
		done
		echo "====="
	fi
;;
list_skeleton)
	if [ ! -z "$2" ] ; then
		set_www
	fi
	echo "Search for Applications able to be generated as APKG"
	echo "===== LIST for Asportal"
	for F in ${APPS_PATH}/*
	do
		echo "====="
		echo -e "Folder for App. : $BLUE $(basename ${F}) $NC exist "
		echo "Files (nothing displayed if empty) inside are ( .png are generated when creating .apk) :"
		ls --color=auto $F 
	done
	echo "====="
	APPS_PATH=${APKG_PATH}/${NS_HOST}_apkg/AppsI
	echo "===== LIST for Idesk"
	for F in ${APPS_PATH}/*
	do
		echo "====="
		echo -e "Folder for App. : $BLUE $(basename ${F}) $NC exist "
		echo "Files (nothing displayed if empty) inside are  :"
		ls --color=auto $F 
	done
	echo "====="	
;;
list_delivery_skeleton)
	if [ ! -z "$2" ] ; then
		set_www
	fi
	DELIV="${NS_HOST}_Apps"
	echo "Search for Applications able to be generated as APKG from original delivery"
	if [ -e ${APKG_PATH}/${NS_HOST}_apkg/${DELIV} ] ; then
		for F in ${APKG_PATH}/${NS_HOST}_apkg/${DELIV}/*
		do
			echo "====="
			echo -e "Folder for App. : $BLUE $(basename ${F}) $NC exist "
			echo "Files (nothing displayed if empty) inside are ( .png are generated when creating .apk) :"
			ls --color=auto $F 
		done
		echo "====="
	else
		echo "===== EMPTY ... NOTHING to display"
	fi
;;
list_generated_installed_apkg)
	if [ ! -z "$2" ] ; then
		set_www
	fi
	echo "Search for ALL APKG (genrated internally) installed in Asportal by ${NS_HOST}"
	for F in ${GEN_APKG_PATH}/*
	do
		/usr/sbin/apkg --list | grep -q "^MH-$(basename ${F})"
		if [ $? -eq 0 ] ; then	
			echo "====="
			echo -e "---- APKG $BLUE MH-$(basename ${F}) $NC is installed in Asportal"
			echo -e "---- $BLUE MH-$(basename ${F}) $NC version installed is : $(apkg --info-installed MH-$(basename ${F}) | grep Version | cut -f 2 -d " ") "
		fi
	done
	echo "====="
;;
list_all_installed_apkg)
	echo "Search for ALL APKG installed in Asportal by ${NS_HOST}"
	echo "====="
	/usr/sbin/apkg --list | grep "^MH"
	echo "====="
;;
copy_apkg_to_public_share)
	APP_NAME=$(echo ${APKG_NAME} | cut -f 2 -d "-")
	if [ -z "${2}" ] ; then
		echo "Hum! please provide a MHxx-APKG_NAME to copy "
		exit 1
	fi
	if [ -z "${3}" ] ; then
		echo "Hum! you don't provide the version to copy ??? check using : ${0} status ${APP_NAME}"
		exit 1
	else
		if [ -e ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk ] ; then
			cp -p ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk /share/Public/
			if [ $? -ne 0 ] ; then
				echo "Hum ... no ${APKG_NAME}_${VER}_x86-64.apk found ? is it generated ??"
				exit 1
			fi
		else
			echo "Hum! ${APKG_NAME} don't exist ... "
			exit 1
		fi
	fi
;;
delete)
	APP_NAME=$(echo ${APKG_NAME} | cut -f 2 -d "-")
	if [ -z "${2}" ] ; then
		echo "Hum! please provide a MHxx-APKG_NAME to delete "
		exit 1
	fi
	if [ -z "${3}" ] ; then
		echo "Hum! you don't provide the version to install ??? check using : ${0} status ${APP_NAME}"
		exit 1
	else
		if [ -e ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk ] ; then 
			rm -rf ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk
		else		
			echo "Hum! can't delete ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk ... file don't exist"
		fi
	fi
	${APKG_PATH}/${NS_HOST}_apkg/bin/conv.sh ${APKG_NAME} delete
;;
install)
	APP_NAME=$(echo ${APKG_NAME} | cut -f 2 -d "-")
	if [ -z "${2}" ] ; then
		echo "Hum! you don't provide APKG_NAME as argument (MH-xxx; MH16-xxx or MH18-xxx)"
		exit 1
	fi
	if [ -z "${3}" ] ; then
		echo "Hum! you don't provide the version to install ??? check using : ${0} status ${APP_NAME}"
		exit 1
	else
		if [ -e ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk ] ; then
			/usr/sbin/apkg --list | grep -q "^${APKG_NAME}" 
			if [ $? -eq 0 ] ; then
				echo "Update require"
				/usr/sbin/apkg --disable ${APKG_NAME}
				sleep 2
				/usr/sbin/apkg --remove ${APKG_NAME}
				sleep 2
				NB=60
				while [ $NB -gt 0 ]
				do
					/usr/sbin/apkg --list | grep -q "^${APKG_NAME}"
					if [ $? -eq 0 ] ; then
						### still exist wait max 2 minutes
						sleep 2
						NB=$((NB-1))
					else
						### deleted as well 
						break
					fi
				done
			fi
				/usr/sbin/apkg --install ${GEN_APKG_PATH}/${APP_NAME}/${APKG_NAME}_${VER}_x86-64.apk
		else
			echo "Hum! ${APKG_NAME}_${VER}_x86-64.apk don't exist please use status to check "
		fi
	fi
	;;
remove)
	APP_NAME=$(echo ${APKG_NAME} | cut -f 2 -d "-")
	if [ -z "${2}" ] ; then
		echo "Hum! you don't provide APKG_NAME as argument (MH-xxx; MH16-xxx or MH18-xxx)"
		exit 1
	fi
	if [ -z "${3}" ] ; then
		echo "Hum! you don't provide the version to install ??? check using : ${0} status ${APP_NAME}"
		exit 1
	else
		/usr/sbin/apkg --list | grep -q "^${APKG_NAME}"
		if [ $? -eq 0 ] ; then
			/usr/sbin/apkg --disable ${APKG_NAME}
			sleep 3
			/usr/sbin/apkg --remove ${APKG_NAME}
			sleep 3
			NB=60
			while [ $NB -gt 0 ]
			do
				/usr/sbin/apkg --list | grep -q "^${APKG_NAME}"
				if [ $? -eq 0 ] ; then
					### still exist wait max 2 minutes
					sleep 2
					NB=$((NB-1))
				else
					### deleted as well 
					break
				fi
			done
		else
			echo "Can't remove ${APKG_NAME} APKG it is NOT installed"
			exit 1
		fi
	fi
	;;
*)
	usage
;;
esac
