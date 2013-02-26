#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.00 RELEASE DATE FEB 27 2013     #
# DESC:  THIS SCRIPT INSTALLS MySQL on OSX  #
#############################################
#REQUIREMENTS:
#  OS X 10.7 or newer
#############################################
#CHECK FOR OS X 10.7+
if [[  $(sw_vers -productVersion | grep '10.[7-8]')  ]]
then
echo "Downloading MySQL Installers ... may take a few moments"
curl -s -o ~/Downloads/MySQL.dmg http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.10-osx10.7-x86_64.dmg
hdiutil attach -quiet ~/Downloads/MySQL.dmg
cd /Volumes/mysql-5.6.10-osx10.7-x86_64/
echo "..."
echo "..."
echo "Installing MySQL, administrator password required ..."
sudo installer -pkg mysql-5.6.10-osx10.7-x86_64.pkg -target /
echo "..."
echo "..."
echo "Installing MySQL start up items..."
sudo installer -pkg MySQLStartupItem.pkg -target /
echo "..."
echo "..."
echo "Click Install to install the MySQL preferance pane"
echo "..."
echo "..."
open MySQL.prefPane/
echo "..."
sleep 5
sudo /usr/local/mysql/support-files/mysql.server start
echo "export PATH=$PATH:/usr/local/mysql/bin" >> ~/.bash_profile
sudo mkdir /var/mysql; sudo ln -s /tmp/mysql.sock /var/mysql/mysql.sock
if [[  $(sudo /usr/local/mysql/support-files/mysql.server status | grep "SUCCESS") ]]
then
mypass="$(cat /dev/urandom | base64 | tr -dc A-Za-z0-9_ | head -c8)"
echo $mypass > ~/Desktop/MYSQL_PASSWORD
echo "Setting MySQL root Password to $mypass"
echo "Placing password on desktop..."
mysql -uroot -e "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$mypass' WITH GRANT OPTION;"
echo "..."
echo "..."
echo "ALL DONE!  Install Sequel Pro or phpmyadmin to administer MySQL"
hdiutil detach -quiet /Volumes/mysql-5.6.10-osx10.7-x86_64/

else
"SORRY, MySQL IS NOT RUNNING ... THERE MUST BE A PROBLEM"
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.7 OR NEWER"
exit 1
fi
