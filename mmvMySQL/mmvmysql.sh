#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 2.2 RELEASE DATE SEPT 28 2015     #
# DESC:  THIS SCRIPT INSTALLS MySQL on OSX  #
#############################################
#REQUIREMENTS:
#  OS X 10.7 or newer
#############################################
# CHECK FOR OS X 10.7+
if [[  $(sw_vers -productVersion | grep -E '10.[7-9]|10.[10-11]')  ]]
then
# CHECK FOR EXISTING MySQL
if [[ -d /usr/local/mysql  ]]
then
echo "It looks like you already have MySQL installed..."
echo "This script will most likely fail unless MySQL is completley removed."
echo "If MySQL does install, your old version and databases will still be"
echo "under /usr/local/ and you will have to manually move databases to the"
echo "new install.  It's important to copy/move with permissions intact."
echo "..."
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
# MYSQL INSTALLER WANTS A 'pidof' COMMAND SOMETIMES
# SO WE'LL GIVE IT A 'pidof' COMMAND
if [[ !  $(command -v pidof) ]]; then
if [ ! -d "$/usr/local/bin" ]; then
sudo mkdir -p /usr/local/bin
fi
# HARD TO CAT DIRECT TO BIN DIR, PUTTING IN DOCUMENTS THEN MOVING
sudo cat << 'EOF' > ~/Documents/pidof
#!/bin/sh
ps axc|awk "{if (\$5==\"$1\") print \$1}"
EOF
sudo mv ~/Documents/pidof /usr/local/bin/pidof
sudo chmod 755 /usr/local/bin/pidof
fi
# LOOKS GOOD, LETS GRAB MySQL AND GET STARTED ...
echo "Downloading MySQL Installers ... may take a few moments"
curl -# -Lo ~/Downloads/MySQL.dmg http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.30-osx10.9-x86_64.dmg
hdiutil attach -quiet ~/Downloads/MySQL.dmg
# PLIST TO ALTER MySQL INSTALLER TO NOT ATTEMPT TO INSTALL STARTUP ITEMS
curl -s -o ~/Downloads/MySQL-install.plist https://raw.githubusercontent.com/MacMiniVault/Mac-Scripts/master/mmvMySQL/install.plist
# DEAR MySQL, WHY HAVE A SPECIFIC 10.9 DOWNLOAD IF IT JUST HAS THE 10.8 INSTALLER?
cd /Volumes/mysql-5.6.30-osx10.8-x86_64/
echo "..."
echo "..."
echo "Installing MySQL, administrator password required ..."
sudo installer -applyChoiceChangesXML ~/Downloads/MySQL-install.plist -pkg mysql-5.6.30-osx10.8-x86_64.pkg -target /
# MySQL START SCRIPT CHANGES PATH - LINKING PIDOF TO THE MySQL DIR
sudo ln -s /usr/local/bin/pidof /usr/local/mysql/bin/pidof
echo "..."
echo "..."
# AS OF RIGHT NOW MYSQL AUTOMATICALLY INSTALLS THE STARTUP ITEMS AND PREFPANE
# STARTUP ITEMS DO NOT WORK IN YOSEMITE - WE MADE A LAUNCHD START SETUP
# TWO FILES ARE NEEDED
# A PLIST FOR LAUNCHD TO START ON BOOT
# AND A SCRIPT THAT THE PLIST LOADS, SCRIPT WAITS FOR NETWORKING TO INITIALIZE AND STARTS MySQL
curl -s -o ~/Downloads/mmv-start.sh https://raw.githubusercontent.com/MacMiniVault/Mac-Scripts/master/mmvMySQL/mmv-start.sh
sudo mv ~/Downloads/mmv-start.sh /usr/local/mysql/support-files/
sudo chown root:wheel /usr/local/mysql/support-files/mmv-start.sh

# LET'S START UP MYSQL
sudo /usr/local/mysql/support-files/mysql.server start

# ADDING MYSQL PATH TO BASH PROFILE, MAY CONFLICT WITH EXISTING PROFILES/.RC FILES
touch ~/.bash_profile >/dev/null 2>&1
echo -e "\nexport PATH=$PATH:/usr/local/mysql/bin" | sudo tee -a  ~/.bash_profile > /dev/null
sudo mkdir /var/mysql; sudo ln -s /tmp/mysql.sock /var/mysql/mysql.sock
sleep 10
# IF MySQL IS RUNNING, GENERATE, SET, AND DOCUMENT  ROOT PASSWORD
if [[  $(sudo /usr/local/mysql/support-files/mysql.server status | grep "SUCCESS") ]]
then
mypass="$(cat /dev/urandom | base64 | tr -dc A-Za-z0-9_ | head -c8)"
echo $mypass > ~/Desktop/MYSQL_PASSWORD
echo "Setting MySQL root Password to $mypass"
echo "Placing password on desktop..."
/usr/local/mysql/bin/mysql -uroot -e "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$mypass' WITH GRANT OPTION;"
echo "..."
echo "..."
# UNMOUNT AND DELELTE DOWNLOADED MySQL INSTALLER
cd ~/
hdiutil detach -quiet /Volumes/mysql-5.6.30-osx10.8-x86_64/
sleep 2
rm ~/Downloads/MySQL.dmg
rm ~/Downloads/MySQL-install.plist
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

innodb_buffer_pool_size=2G
skip-name_resolve
max-connect-errors=100000
max-connections=500

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
                [Yy]* ) curl -# -Lo ~/Downloads/SequelPro.dmg https://github.com/sequelpro/sequelpro/releases/download/release-1.1.2/sequel-pro-1.1.2.dmg; hdiutil attach -quiet ~/Downloads/SequelPro.dmg; cp -R /Volumes/Sequel\ Pro\ 1.1.2/Sequel\ Pro.app/ /Applications/Sequel\ Pro.app/; hdiutil detach -quiet /Volumes/Sequel\ Pro\ 1.1.2/;sleep 5; rm ~/Downloads/SequelPro.dmg; echo "Sequel Pro is now in your Applications folder";  break  ;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
                esac
        done
# NEW SEQUEL PRO INSTALL OPTION END
echo " "
echo " "
echo "ALL DONE!  Install Sequel Pro or phpmyadmin to administer MySQL"
echo " "
echo " "
echo "MySQL will start automatically after a reboot. Use the MySQL preference pain in system preferences to manage this."
echo "Open a new terminal for the 'mysql' command to be recognized in terminal"
echo " "
echo " "
else
"SORRY, MySQL IS NOT RUNNING ... THERE MUST BE A PROBLEM"
fi
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.7 OR NEWER"
exit 1
fi
