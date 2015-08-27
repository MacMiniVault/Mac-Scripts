#READ ME FOR MMV WORDPRESS SCRIPT
===========

The primary scenario behind this script is to use a remote Mac as a web server to host a [WordPress](http://www.wordpress.org) site.  This script will run on a Mac that has OS X 10.8/10.9/10.10 and Server.app installed and initialized.  MySQL is also required and is not installed by default.  A quick tutorial on how to install MySQL on OS X 10.10 Yosemite can be found [here](http://www.macminivault.com/mysql-yosemite/). 

Note this script is primarily made for Macs in a production environment running on a static IP.  If you have Server.app installed on a development machine and you don't have a problem editing the /etc/hosts file it could be used to quickly get a WordPress site setup.

#WHAT THIS SCRIPT DOES
+ Checks to make sure OS X is at 10.8.x, 10.9.x, or 10.10.x and has Server.app installed and initiated and MySQL is installed
+ Downloads the latest version of WordPress
+ Starts the Web service within Server.app and enables PHP functionality
+ Prompts for a domain name, does basic validation to make sure it's really a domain
+ Checks to see if a similar name exists in Server.app Web panel (can hit on false positives)
+ Create database and database user (randomized naming)
+ Extracts, edits, and moves WordPress files to proper location and sets config file
+ Sets permissions so Apache owns files, things like WordPress updates, media uploads, and plugin installations can be completed within the WordPress backend.

#INSTALLATION
**Before installation: Make sure you have OS X 10.8, 10.9, or 10.10; Server.app installed and initialized, and MySQL installed (see link above for tutorial).**

+ Open Terminal and run the following command

        bash <(curl -Ls http://git.io/KQ_dvw)

+ Enter in your system password, MySQL root password, and a domain name when prompted
+ Open Server.app and within the Web panel create a website that matches the domain name entered in the script
+ Use the additional domains setting to add the 'www.' version of the domain if applicable
+ Under 'Advanced Settings', check the checkbox for 'Allow overrides using .htaccess files'
+ Point the domain's DNS records to the IP of your MAC or edit your /etc/hosts file and visit the domain in a web browser to finalize the WordPress installation
