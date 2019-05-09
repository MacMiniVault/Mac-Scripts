#READ ME FOR VPN SCRIPT
===========

The primary scenario behind this script is to use a remote Mac as a VPN server.  The majority of the time when a Mac is placed in a data center it has a public IP address and the network environment does not lend itself to doling out IP addresses for VPN clients.

OS X 10.8 Mountain Lion with Server.app replaced the ipfw firewall with pf and includes other changes which make setting up the VPN server with a single public IP address more difficult. 

This script automates and greatly speeds up the setup process as  well as reducing the possibility of accidentally kicking your Mac off its network connection. This script is used in conjunction with VPN Enabler for Mojave, a 3rd party VPN server.

This script was developed and tested by the staff of Mac Mini Vault, we colocate a lot of Macs and tirelessly work to add usability and streamline the plight of the Mac in the data center world.  Check out our website at http://www.macminivault.com

#WHAT THIS SCRIPT DOES
+ Checks to make sure macOS is at 10.12.x, 10.13.x, or 10.14.x and has does not have Server.app installed
+ Checks to see if this script has run before
+ Creates and configures a private VLAN for VPN clients
+ Backs up and edits the firewall config, adding in NAT
+ Enables firewall rules and IP forwarding

#INSTALLATION
**Before installation: Make sure you have macOS 10.12/10.13/10.14, Sever.app is not installed / has been uninstalled, no VLANs are configured, and a un-customized firewall configuration. Install VPN Enabler first, and go ahead and configure it**

+ Open Terminal and run the following command

        bash <(curl -Ls http://git.io/1UlbJQ)
:exclamation: [**Security Notice**](https://github.com/MacMiniVault/Mac-Scripts#readme)

+ Enter in your macOS password when prompted, reboot when finished
+ When machine reboots, make sure VPN Enabler is running
+ Create a VPN connection on your client using your username, password, and passphrase – using the advanced options to route all traffic through VPN

#NOTES
+ If, while saving your changes in VPN Enabler your settings disappear, it could mean that VPN Enabler isn't successfully being granted administrator privileges. If you have macOS Server (Server.app) installed, this needs to be fully removed from your system, and then the system needs to be rebooted. Second, try changing your administrator password in macOS.
