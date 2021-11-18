#!/bin/sh
echo "real install example for firefox from Ubuntu default repository"
echo "NAME between % are remplaced by Idesk App. name "
#/usr/local/bin/myHD_root "/usr/bin/apt-get -y install NAME"
#/usr/local/bin/myHD_root "/usr/bin/apt-get -y install NAME-locale*"
/usr/local/bin/myHD_root "/usr/bin/dpkg -i /myHD_scripts/Idesk/App_Store/skype/skypeforlinux-64.deb"
/usr/local/bin/myHD_root "/usr/bin/apt-get -y -f install"

