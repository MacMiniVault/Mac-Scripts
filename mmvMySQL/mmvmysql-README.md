#YOSMITE OS X 10.10 NOTE:
[BE SURE TO READ THIS!!!](https://github.com/MacMiniVault/Mac-Scripts/blob/master/mmvMySQL/mmvmysql-Yosemite.md)

#READ ME FOR MMV MySQL SCRIPT
===========

MySQL is not installed by default on OS X 10.7 or newer.  This script will fix that bug.

:exclamation: For OS X 10.11 and above, we no longer recommend using this script. Instead, we recommend following [these instructions](http://www.macminivault.com/install-mysql-on-macos-sierra/).

#WHAT THIS SCRIPT DOES
+ Checks for OS X and MySQL
+ Downloads MySQL from Oracle
+ Installs MySQL and the bits required to make it start by default
+ Sets some paths
+ Sets a default root password
+ Presents the option to load a basic performance my.cnf and restart MySQL
+ Presents the option to automatically download and install Sequel Pro

#INSTALLATION
+ Open Terminal and run the following command

        bash <(curl -Ls http://git.io/eUx7rg)
:exclamation: [**Security Notice**](https://github.com/MacMiniVault/Mac-Scripts#readme)

+ Enter in your system password when prompted
+ The script will install MySQL, generate a root password and display it along with writing a file to the desktop including the password.
+ Click to install the MySQL preference pane when prompted.
+ Close your terminal and open a new terminal to access MySQL via command line
+ Install [Sequel Pro](http://www.sequelpro.com/) or phpmyadmin to manage MySQL

#UNINSTALLATION
There is no uninstall script - if you need to uninstall MySQL, we recommend wiping your machine and reinstalling OS X.

#FORGOT YOUR PASSWORD?
This script will restart MySQL, reset the password, and then restart it again

	bash <(curl -Ls http://git.io/9xqEnQ)

#TUNING
This script creates a modified my.cnf file named mmv.cnf.  The performance settings will not be perfect for every MySQL server.  The intention was to give a small performance boost in a generic way.  This script gives the option to copy over the mmv.cnf file to /etc/my.cnf and restart MySQL.  We encourage you to further tune your MySQL server after it is running for awhile.  You can do so by running this command in your terminal and it will display stats and recommendations. (Credit Major Hayden for MySQLTuner)

	perl <(curl -Ls https://raw.github.com/major/MySQLTuner-perl/master/mysqltuner.pl)
