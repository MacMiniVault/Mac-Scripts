#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 0.99 RELEASE DATE DEC 08 2014     #
# DESC:  CREATES LAUNCHD START FOR MySQL    #
#############################################
#REQUIREMENTS:
#  OS X 10.7 or newer and MySQL installed
#############################################

echo "ONLY SAY YES IF YOU HAVE MYSQL INSTALLED AND UPGRADED TO YOSEMITE"
echo "AFTER THE UPGRADE MYSQL WOULD NOT START ON BOOT"
echo "IF YOU SAY YES, THIS SCRIPT WILL ENABLE START ON BOOT VIA LAUNCHD"
echo "ALSO WORKS IF YOU INSTALLED MYSQL VIA THE MYSQL INSTALLER ON YOSEMITE"
echo "..."
read -p 'DO YOU WANT TO MAKE MYSQL START ON BOOT? [y/n]: '  answer
case "${answer}" in [Yy])
sudo /usr/local/mysql/support-files/mysql.server stop > /dev/null 2>&1 
curl -s -o ~/Downloads/com.mysql.server.plist https://raw.githubusercontent.com/MacMiniVault/Mac-Scripts/master/mmvMySQL/com.mysql.server.plist
sudo mv ~/Downloads/com.mysql.server.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.mysql.server.plist
sudo chmod 644 /Library/LaunchDaemons/com.mysql.server.plist
sudo launchctl load -w /Library/LaunchDaemons/com.mysql.server.plist
echo "THE PLIST FILE HAS BEEN INSTALLED AND ENABLED"
echo "TO DISABLE IT, RUN sudo launchctl unload -w Library/LaunchDaemons/com.mysql.server.plist"
echo "ONCE UNLOADING, YOU SHOULD REBOOT YOUR SYSTEM BEFORE TRYING TO START MYSQL"
;;
esac
