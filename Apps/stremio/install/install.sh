#!/bin/sh
NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/builtin/sbin:/usr/builtin/bin:/usr/local/sbin:/usr/local/bin:/opt/sbin:/opt/bin
UBU=%UBU%
APP=%NAME%
DEB=stremio_4.4.52-1_amd64.deb
APKG_PATH=/usr/local/AppCentral/MH-${UBU}${APP}
SHELL_SCRIPT=${APP}.sh

APKG_FOLDER=/usr/local
UVER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
MYHD_BIN=${MYHD_PATH}/bin
CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
SCRIPTS_PATH=${APKG_FOLDER}/.${NS_HOST}/${NS_HOST}_${UVER}_scripts
TEMP_PATH=${MYHD_PATH}/${NS_HOST}_temp
CHRT=jchroot

generate_script_install(){
	cp -p ${APKG_PATH}/install/${APP}_ubuntu_install.sh ${TEMP_PATH}/${APP}_install.sh
	chmod a+x ${TEMP_PATH}/${APP}_install.sh
}

test_ubuntu_run(){
	echo "==== is ${NS_HOST} running ?"
	ps -eaf | grep ${CHRT} | grep -q ${NS_HOST}
	if [ $? -ne 0 ] ; then
		echo "Hum! ${NS_HOST} is not started ??? "
		/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST} is not started ?? $APP can't start ... "
		exit 0
	fi
}

wait_for_end(){
		### wait for end ...
		NB=600
		while [ $NB -gt 0 ]
		do
			if [ -e ${SCRIPT_PATH}/Apps/${NAME}.already_installed ] ; then
				# rm -f ${TEMP_PATH}/${APP}_installed
				# touch ${APKG_PATH}/MH${UBU}-${APP}_installed
				break
			else
				sleep 2
				NB=$((NB-1))
			fi
		done
		if [ $NB -le 0 ] ; then
			/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST} can't install ${APP} in 20 minutes ... "
			exit 0
		fi
}

tmux_send(){
	${MYHD_BIN}/tmux has-session -t ${NS_HOST} 2>/dev/null
	if [ $? -eq 0 ] ; then
		${MYHD_BIN}/tmux send-keys -t ${NS_HOST} "/${NS_HOST}_temp/${APP}_install.sh ${DEB}" Enter
	else
		/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST} is not started ?? $APP can't start ... "
		exit 0
	fi
}

ns_send(){
	PROG=$(which ${NS_HOST}_root)
	if [ -z ${PROG} ] ; then
		/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST}_root seem to don't exist ??? "
		exit 0
	fi
	${PROG} "/${NS_HOST}_temp/${APP}_install.sh /${DEB}"
}

ssh_send(){
	PROG=$(which ${NS_HOST}_root_ssh)
	if [ -z ${PROG} ] ; then
		/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST}_root_ssh seem to don't exist ??? "
		exit 0
	fi
	${PROG} "/${NS_HOST}_temp/${APP}_install.sh ${DEB}"
}

do_it(){
	### perhaps NOW not necessary (done in pre-install.sh)
	test_ubuntu_run
	### now install the product in ${NS_HOST}
	cp -p ${APKG_PATH}/install/${DEB} ${TEMP_PATH}/
	if [ -e ${TEMP_PATH}/${APP}_installed ] ; then
		rm -f ${TEMP_PATH}/${APP}_installed
	fi
	###
	if [ -e ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh ] ; then
		rm -f ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh.prev
		mv ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh.prev
	fi
	cp -p ${APKG_PATH}/install/${SHELL_SCRIPT} ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh
	chmod a+x ${SCRIPTS_PATH}/Apps/MH${UBU}_${APP}.sh
	###
	if [ -e ${APKG_PATH}/install/MH${UBU}_${APP}.xbindkeysrc ] ; then
		cp -p ${APKG_PATH}/install/MH${UBU}_${APP}.xbindkeysrc ${SCRIPTS_PATH}/Apps/
	fi
	###
	generate_script_install
	### to use a real terminal ... send using tmux T.B.C. now can be done using ssh
	tmux_send
	# ns_send
	wait_for_end
	rm -f ${TEMP_PATH}/${DEB}
	rm -f ${TEMP_PATH}/${APP}_install.sh
	touch ${SCRIPTS_PATH}/Apps/${APP}.already_installed
}

if [ ! -e ${SCRIPTS_PATH}/Apps/${APP}.already_installed ] ; then
	do_it
fi
