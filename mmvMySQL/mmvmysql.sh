#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.06 RELEASE DATE FEB 26 2014     #
# DESC:  THIS SCRIPT INSTALLS MySQL on OSX  #
#############################################
#REQUIREMENTS:
#  OS X 10.7 or newer
#############################################
# CHECK FOR OS X 10.7+
if [[  $(sw_vers -productVersion | grep '10.[7-9]')  ]]
then
# CHECK FOR EXISTING MySQL
if [[ -d /usr/local/mysql && -d /var/mysql ]]
then
echo "It looks like you already have MySQL installed..."
echo "This script will most likely fail unless MySQL is completley removed"
echo "..."
	while true; do
		read -p "DO YOU WANT TO CONTINUE? [y/N]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit ;;
		* ) echo "Please answer yes or no.";;
		esac
	done
fi
# LOOKS GOOD, LETS GRAB MySQL AND GET STARTED ...
echo "Downloading MySQL Installers ... may take a few moments"
curl -# -o ~/Downloads/MySQL.dmg http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.17-osx10.7-x86_64.dmg
hdiutil attach -quiet ~/Downloads/MySQL.dmg
cd /Volumes/mysql-5.6.17-osx10.7-x86_64/
echo "..."
echo "..."
echo "Installing MySQL, administrator password required ..."
sudo installer -pkg mysql-5.6.17-osx10.7-x86_64.pkg -target /
echo "..."
echo "..."
echo "Installing MySQL start up items..."
sudo installer -pkg MySQLStartupItem.pkg -target /
echo "..."
echo "..."
echo "Click Install to install the MySQL preferance pane"
echo "..."
echo "..."
# MOVING PREFPANE TO DOWNLOADS FOLDER SO IT CAN STILL BE INSTALLED
# AFTER THE SCRIPT COMPLETES AND REMOVES THE INSTALLER FILES
# AS SCRIPT DOESN'T WAIT FOR USER TO CLICK "INSTALL" FOR PREFPANE
cp -R MySQL.prefPane ~/Downloads/MySQL.prefpane
open ~/Downloads/MySQL.prefPane/
echo "..."
sleep 15
sudo /usr/local/mysql/support-files/mysql.server start
echo "export PATH=$PATH:/usr/local/mysql/bin" >> ~/.bash_profile
sudo mkdir /var/mysql; sudo ln -s /tmp/mysql.sock /var/mysql/mysql.sock
if [[  $(sudo /usr/local/mysql/support-files/mysql.server status | grep "SUCCESS") ]]
then
mypass="$(cat /dev/urandom | base64 | tr -dc A-Za-z0-9_ | head -c8)"
echo $mypass > ~/Desktop/MYSQL_PASSWORD
echo "Setting MySQL root Password to $mypass"
echo "Placing password on desktop..."
/usr/local/mysql/bin/mysql -uroot -e "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$mypass' WITH GRANT OPTION;"
echo "..."
echo "..."
cd ~/
hdiutil detach -quiet /Volumes/mysql-5.6.17-osx10.7-x86_64/
sleep 2
rm ~/Downloads/MySQL.dmg
# NEW MY.CNF PERFORMANCE OPTION START
echo "BASE PERFORMANCE MY.CNF IS JUST A GENERIC SUGGESTION FOR PERFORMANCE"
echo "YOUR RESULTS MAY VARY AND YOU MAY WANT TO FURTHER TUNE YOUR MY.CNF SETTINGS"
echo "BASE PERFORMANCE MY.CNF INCREASES BUFFERS/MEMORY USAGE"
echo "8GB+ RAM IS RECOMMENDED FOR BASE PERFORMANCE MY.CNF"
echo "..."
sudo cp /usr/local/mysql/my.cnf /usr/local/mysql/mmv.cnf
sudo tee -a /usr/local/mysql/mmv.cnf > /dev/null  << EOF

# CUSTOMIZED BY MMVMySQL SCRIPT - JUST GENERIC SETTINGS
# DO NOT TREAT AS GOSPEL

skip-external-locking
key_buffer_size = 384M
max_allowed_packet = 1M
table_open_cache = 512
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size = 32M
thread_concurrency = 4
EOF
        while true; do
                read -p "DO YOU WANT TO LOAD A BASE PERFORMANCE MY.CNF FILE? [y/N]" cnf
                case $cnf in
                [Yy]* ) sudo cp /usr/local/mysql/mmv.cnf /etc/my.cnf; sudo /usr/local/mysql/support-files/mysql.server restart; break  ;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
                esac
        done
# NEW MY.CNF PERFORMANCE OPTION END
# NEW SEQUEL PRO INSTALL OPTION START
while true; do
                read -p "DO YOU WANT TO AUTOMATICALLY INSTALL SEQUEL PRO? [Y/n]" sp
                case $sp in
                [Yy]* ) curl -# -o ~/Downloads/SequelPro.dmg https://sequel-pro.googlecode.com/files/sequel-pro-1.0.2.dmg; hdiutil attach -quiet ~/Downloads/SequelPro.dmg;cp -R /Volumes/Sequel\ Pro\ 1.0.2/Sequel\ Pro.app/ /Applications/Sequel\ Pro.app/; hdiutil detach -quiet /Volumes/Sequel\ Pro\ 1.0.2/;sleep 5; rm ~/Downloads/SequelPro.dmg; echo "Sequel Pro is now in your Applications folder!";  break  ;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
                esac
        done
# NEW SEQUEL PRO INSTALL OPTION END
echo " "
echo " "
echo "ALL DONE!  Install Sequel Pro or phpmyadmin to administer MySQL"
echo "Log off and log back in for 'mysql' to be recognized as a command in terminal"
else
"SORRY, MySQL IS NOT RUNNING ... THERE MUST BE A PROBLEM"
fi
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.7 OR NEWER"
exit 1
fi
