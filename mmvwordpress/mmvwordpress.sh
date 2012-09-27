#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.01 RELEASE DATE SEPT 27, 2012   #
# DESC:  THIS SCRIPT SETS UP WORDPRESS ON   #
#        A OS X 10.8 MACHINE W/ SERVER.APP  #
#        AND MYSQL INSTALLED                #
#############################################
#REQUIREMENTS:
#  OS X 10.8
#  SERVER.APP INSTALLED / INITIALIZED
#  MYSQL INSTALLED 
#############################################
#CHECK FOR OS X 10.8, SERVER.app, and MySQL
if [[  $(sw_vers -productVersion | grep '10.8') && $(which serveradmin) && $(which mysql) ]]
then
echo "Congratulations, you are running OS X 10.8.x and have Server.app and MySQL installed...."
#GET LATEST WORDPRESS VERSION
cd ~/Downloads
curl -o mmvwordpress.tar.gz http://wordpress.org/latest.tar.gz
tar xzf mmvwordpress.tar.gz
cd wordpress 
mv wp-config-sample.php wp-config.php
#START WEB SERVICE AND MAKE SURE PHP IS ENABLED
echo "YOU MAY BE ASKED FOR YOUR SYSTEM ADMINISTRATOR PASSWORD...."
sudo serveradmin start web
sudo webappctl start com.apple.webapp.php
#ASK FOR DOMAIN NAME - THANKS TO @SHAUNINMAN FOR SOME OF THE REGEX USED IN VALIDATION OF DOMAIN
echo "ENTER DOMAIN NAME:"
regex='^[a-zA-Z0-9\-\.]+\.((a[cdefgilmnoqrstuwxz]|aero|arpa)|(b[abdefghijmnorstvwyz]|biz)|(c[acdfghiklmnorsuvxyz]|cat|com|coop)|d[ejkmoz]|(e[ceghrstu]|edu)|f[ijkmor]|(g[abdefghilmnpqrstuwy]|gov)|h[kmnrtu]|(i[delmnoqrst]|info|int)|(j[emop]|jobs)|k[eghimnprwyz]|l[abcikrstuvy]|(m[acdghklmnopqrstuvwxyz]|mil|mobi|museum)|(n[acefgilopruz]|name|net)|(om|org)|(p[aefghklmnrstwy]|pro)|qa|r[eouw]|s[abcdeghijklmnortvyz]|(t[cdfghjklmnoprtvwz]|travel)|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw])$'
while read domain; do
 if [[ $domain =~ $regex ]]; then 
echo "BUILDING WORDPRESS SITE..... "
        if [[ $(sudo serveradmin settings web | grep $domain) ]]; then
                echo "DOMAIN ALREADY EXISTS ON THIS SERVER ..."
                echo ""
                echo "PLEASE ENTER A DOMAIN NAME:"
        else
                break 2
        fi
else
echo "YOU DID NOT ENTER A VALID DOMAIN NAME"
echo ""
echo "PLEASE ENTER A DOMAIN NAME:"
fi
done    
#CREATE DATABASE NAME AND USER
wpname="$(cat /dev/urandom | base64 | tr -dc A-Za-z0-9_ | head -c8)"
wpname=wp_$wpname
wppass="$(cat /dev/urandom | base64 | tr -dc A-Za-z0-9_ | head -c15)"
echo "ENTER MySQL ROOT PASSWORD TO CREATE DATABASE AND USER:"
mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS $wpname;GRANT ALL ON *.* TO '$wpname'@'localhost' IDENTIFIED BY '$wppass';FLUSH PRIVILEGES;"
#CREATE WORDPRESS DOCUMENTROOT AND OWN BY APACHE
sudo mkdir /Library/Server/Web/Data/Sites/$domain > /dev/null 2>&1
sudo cp -R ~/Downloads/wordpress/* /Library/Server/Web/Data/Sites/$domain > /dev/null 2>&1
sudo rm -rf ~/Downloads/wordpress
sudo sed -i -e "s/^define('DB_NAME', 'database_name_here');/define('DB_NAME', '$wpname');/" /Library/Server/Web/Data/Sites/$domain/wp-config.php > /dev/null 2>&1
sudo sed -i -e "s/^define('DB_USER', 'username_here');/define('DB_USER', '$wpname');/" /Library/Server/Web/Data/Sites/$domain/wp-config.php > /dev/null 2>&1
sudo sed -i -e "s/^define('DB_PASSWORD', 'password_here');/define('DB_PASSWORD', '$wppass');/" /Library/Server/Web/Data/Sites/$domain/wp-config.php > /dev/null 2>&1
sudo chown -R _www:staff /Library/Server/Web/Data/Sites/$domain > /dev/null 2>&1

#LEAVING THIS AREA BLANK

#EVENTUALLY WANT TO SCRIPT IN VHOST CREATION WITH serveradmin


#END IF STATEMENT CHECKING FOR OS X & SERVER.APP & MySQL
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.8 OR YOU DO NOT HAVE SERVER.APP MySQL INSTALLED"
exit 1
fi

