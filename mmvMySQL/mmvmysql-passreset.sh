#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.01 RELEASE DATE SEPT 18 2013    #
# DESC: SCRIPT RESETS PASS FOR MySQL on OSX #
#############################################
#REQUIREMENTS:
#  OS X 10.7 or newer
#############################################
#CHECK FOR OS X 10.7+
if [[  $(sw_vers -productVersion | grep '10.[7-9]')  ]]
then
sudo /usr/local/mysql/support-files/mysql.server start
if [[  $(sudo /usr/local/mysql/support-files/mysql.server status | grep "SUCCESS") ]]
then
sudo /usr/local/mysql/support-files/mysql.server stop
sudo /usr/local/mysql/support-files/mysql.server start --skip-grant-tables
mypass="$(cat /dev/urandom | base64 | tr -dc A-Za-z0-9_ | head -c8)"
echo $mypass > ~/Desktop/MYSQL_PASSWORD
echo "Setting MySQL root Password to $mypass"
echo "Placing password on desktop..."
/usr/local/mysql/bin/mysql -uroot -e "UPDATE mysql.user SET Password=PASSWORD('$mypass') WHERE User='root'; FLUSH PRIVILEGES;"
sudo /usr/local/mysql/support-files/mysql.server restart 

else
"SORRY, MySQL IS NOT RUNNING ... THERE MUST BE A PROBLEM"
fi
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.7 OR NEWER"
exit 1
fi
