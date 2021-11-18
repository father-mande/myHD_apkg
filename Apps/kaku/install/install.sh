#!/bin/sh
NS_HOST=myHD
MYHD_PATH=/usr/local/AppCentral/${NS_HOST}

UBU=%UBU%
APP=%NAME%
DEB=Kaku_2.0.2_amd64.deb
APKG_PATH=/usr/local/AppCentral/MH-${APP}
SHELL_SCRIPT=${APP}.sh

APKG_FOLDER=/usr/local
UVER=$(/usr/bin/confutil -get ${MYHD_PATH}/${NS_HOST}.conf ${NS_HOST} UVER)
MYHD_BIN=${MYHD_PATH}/bin
CHROOT_PATH=${APKG_FOLDER}/.${NS_HOST}/${UVER}
SCRIPTS_PATH=${APKG_FOLDER}/.${NS_HOST}/${NS_HOST}_${UVER}_scripts
TEMP_PATH=${MYHD_PATH}/myHD_temp
CHRT=jchroot

generate_script_install(){
	echo "#!/bin/sh" > ${TEMP_PATH}/${APP}_install.sh
	echo "echo '==== START install ====' > /myHD_temp/${APP}_install.out" >> ${TEMP_PATH}/${APP}_install.sh
	echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/X11:/usr/local/sbin:/usr/local/bin:/usr/local/jre/bin" >> ${TEMP_PATH}/${APP}_install.sh
	echo "/usr/bin/dpkg -i /myHD_temp/${DEB} 2>&1 >> /myHD_temp/${APP}_install.out" >> ${TEMP_PATH}/${APP}_install.sh
	echo "/usr/bin/apt-get -yf install 2>&1 >> /myHD_temp/${APP}_install.out" >> ${TEMP_PATH}/${APP}_install.sh
	echo "echo '==== END install ====' >> /myHD_temp/${APP}_install.out" >> ${TEMP_PATH}/${APP}_install.sh
	echo "touch /myHD_temp/${APP}_installed" >> ${TEMP_PATH}/${APP}_install.sh
	echo "exit 0" >> ${TEMP_PATH}/${APP}_install.sh
	chmod a+x ${TEMP_PATH}/${APP}_install.sh
}

test_ubuntu_run(){
	echo "==== is ${NS_HOST} running ?"
	ps -eaf | grep ${CHRT} | grep -q ${NS_HOST}
	if [ $? -ne 0 ] ; then
		echo "Hum! myHD is not started ??? "
		/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST} is not started ?? $APP can't start ... "
		exit 0
	fi
}

tmux_send(){
	${MYHD_BIN}/tmux has-session -t ${NS_HOST} 2>/dev/null
	if [ $? -eq 0 ] ; then
		${MYHD_BIN}/tmux send-keys -t ${NS_HOST} "/myHD_temp/${APP}_install.sh" Enter
		### wait for end ...
		NB=120
		while [ $NB -gt 0 ]
		do
			if [ -e ${TEMP_PATH}/${APP}_installed ] ; then
				rm -f ${TEMP_PATH}/${APP}_installed
				break
			else
				sleep 2
				NB=$(($NB-1))
			fi
		done
		if [ $NB -le 0 ] ; then
			/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST} can't install ${APP} in 4 minutes ... "
			exit 0
		fi
	else
		/usr/sbin/syslog -g 0 -l 2 -u root --event "Hum! ${NS_HOST} is not started ?? $APP can't start ... "
		exit 0
	fi
}

if [ ! -e ${APKG_PATH}/install/.already_installed ] ; then
	test_ubuntu_run
	### now install the product in myHD
	cp -p ${APKG_PATH}/install/${DEB} ${TEMP_PATH}/
	if [ -e ${TEMP_PATH}/${APP}_installed ] ; then
		rm -f ${TEMP_PATH}/${APP}_installed
	fi
	generate_script_install
	### to use a real terminal ... send using tmux
	tmux_send
	###
	if [ -e ${SCRIPTS_PATH}/Apps/MH_${APP}.sh ] ; then
		rm -f ${SCRIPTS_PATH}/Apps/MH_${APP}.sh.prev
		mv ${SCRIPTS_PATH}/Apps/MH_${APP}.sh ${SCRIPTS_PATH}/Apps/MH_${APP}.sh.prev
	fi
	cp -p ${APKG_PATH}/install/${SHELL_SCRIPT} ${SCRIPTS_PATH}/Apps/MH_${APP}.sh
	chmod a+x ${SCRIPTS_PATH}/Apps/MH_${APP}.sh
	rm -f ${TEMP_PATH}/${DEB}
	rm -f ${TEMP_PATH}/${APP}_install.sh
	touch ${APKG_PATH}/install/.already_installed
fi
