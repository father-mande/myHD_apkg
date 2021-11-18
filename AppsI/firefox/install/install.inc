#!/bin/sh
echo "real install"
/usr/local/bin/myHD_root "/usr/bin/apt-get -y install %NAME%"
/usr/local/bin/myHD_root "/usr/bin/apt-get -y install %NAME%-locale*"
