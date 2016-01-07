#READ ME FOR CHANGE SSH PORT SCRIPT
===========

**This script does not and will not work on OS X 10.11 El Capitan due to System Integrity Protection (SIP), which prevents changes to files in the /System directory. Disabling SIP may allow this script to work, but that is not recommended and has not been tested.**

Enabling remote SSH access on a Mac is simplistic and easy.  Under the sharing preferences there is a 'Remote Login' option that requires a single click to be activated.  This allows for some powerful remote access via the command line.  SFTP file transfers and remotely diagnosing a distressed Mac with non-functioning VNC/ARD access are two prime examples for enabling Remote Login.  

If this machine is live on the internet and port 22 is not being filtered by a firewall then you may run into some unwanted attention.  Bots and scanners crawl the web looking for responses on port 22.  The majority of the time this results in no harm, as they have to randomly guess login credentials.  For the peace of mind and a little added security, running SSH on a non-standard port is just a good idea.

For a list of standard port numbers check out article [TS1629](http://support.apple.com/kb/ts1629) in Apple's Knowledge Base.

This script was developed and tested by the staff of Mac Mini Vault, we colocate a lot of Macs and tirelessly work to add usability and streamline the plight of the Mac in the data center world.  Check out our website at http://www.macminivault.com

#WHAT THIS SCRIPT DOES
+ Checks to make sure OS X is at 10.8.x or newer
+ Checks to make sure what is entered in is a valid number
+ Sets the entered port number in the SSH configuration
+ Restarts SSH / Remote Login

#INSTALLATION

+ Open Terminal and run the following command

        bash <(curl -Ls http://git.io/_9fF7g)
:exclamation: [**Security Notice**](https://github.com/MacMiniVault/Mac-Scripts#readme)

+ Enter in a valid port number
- Note: This script does not prevent you from using other active ports!  Choose wisely, we recommend something high up above 1000.
+ Enter in your password when prompted.
+ Thats it!  (re-run script and enter "22" to return to factory setting)
+ To connect to the server just add the port number to your ssh command.  If your alternative port was 9222, the command would be:

        ssh -p9222 user@server.example.com
