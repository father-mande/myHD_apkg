#!/bin/bash
### executed in Ubuntu environment ...
NS_HOST=myHD
APP=stremio
# DEB=stremio_4.4.52-1_amd64.deb
### add DEB as $1
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/X11:/usr/local/sbin:/usr/local/bin:/usr/local/jre/bin
echo '==== START install ====' > /${NS_HOST}_temp/${APP}_install.out
echo "$(date)" >> /${NS_HOST}_temp/${APP}_install.out
/usr/bin/dpkg -i /${NS_HOST}_temp/${1} >> /${NS_HOST}_temp/${APP}_install.out 2>&1
/usr/bin/apt-get -yf install >> /${NS_HOST}_temp/${APP}_install.out 2>&1 
echo "$(date)" >> /${NS_HOST}_temp/${APP}_install.out
echo '==== END install ====' >> /${NS_HOST}_temp/${APP}_install.out
touch /${NS_HOST}_scripts/Apps/${APP}.already_installed
exit 0
