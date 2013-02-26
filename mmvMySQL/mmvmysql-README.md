#READ ME FOR MMV MySQL SCRIPT
===========

MySQL is not installed by default on OS X 10.7 or newer.  This script will fix that bug.

#WHAT THIS SCRIPT DOES
+ Downloads MySQL from Oracle
+ Installs MySQL and the bits required to make it start by default
+ Sets some paths 
+ Sets a default root password

#INSTALLATION
+ Open Terminal and run the following command

        bash <(curl -s https://raw.github.com/MacMiniVault/Mac-Scripts/master/mmvMySQL/mmvmysql.sh)

+ Enter in your system password when prompted
+ Install [Sequel Pro](http://www.sequelpro.com/) or phpmyadmin to manage MySQL