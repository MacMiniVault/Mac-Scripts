#!/bin/bash
# THIS IS NEEDED TO DELAY THE MYSQL LAUNCHD START UNTIL
# NETWORK/HOSTNAME IS AVAILABLE
 
. /etc/rc.common

CheckForNetwork

while [ "${NETWORKUP}" != "-YES-" ]
do
sleep 5
NETWORKUP=
CheckForNetwork
done
/usr/local/mysql/support-files/mysql.server start
