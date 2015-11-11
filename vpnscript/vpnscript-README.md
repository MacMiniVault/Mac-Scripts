#READ ME FOR VPN SCRIPT
===========

The primary scenario behind this script is to use a remote Mac as a VPN server.  The majority of the time when a Mac is placed in a data center it has a public IP address and the network environment does not lend itself to doling IP addresses for VPN clients.

OS X 10.8 Mountain Lion with Server.app replaces the ipfw firewall with pf and includes other changes which make setting up the VPN server with a single public IP address more difficult. 

This script automates and greatly speeds up the setup process as  well as reducing the possibility of accidentally kicking your Mac off its network connection.

This script was developed and tested by the staff of Mac Mini Vault, we colocate a lot of Macs and tirelessly work to add usability and streamline the plight of the Mac in the data center world.  Check out our website at http://www.macminivault.com

#WHAT THIS SCRIPT DOES
+ Checks to make sure OS X is at 10.8.x, 10.9.x, 10.10.x, or 10.11.x and has Server.app installed and initiated
+ Checks to see if this script has run before
+ Stops DNS & VPN
+ Creates and configures a private VLAN for VPN clients
+ Backs up and generates a new DNS config using the current resolving DNS servers as forwarders (10.8 only)
+ Backs up and edits the firewall config adding in NAT
+ Enables firewall rules and IP forwarding
+ Enables VPN and sets VPN client addresses to VLAN
+ Prompts for and sets the VPN passphrase 

#INSTALLATION
**Before installation: Make sure you have OS X 10.8/10.9/10.10/10.11, Sever.app installed and initialized, no VLANs configured, and a un-customized firewall configuration.**

+ Open Terminal and run the following command

        bash <(curl -Ls http://git.io/1UlbJQ)
:exclamation: [**Security Notice**](https://github.com/MacMiniVault/Mac-Scripts#readme)

+ Enter in your password and a passphrase when prompted, reboot when finished
+ When machine reboots, turn off VPN for a minute, then turn it back on
+ Create a VPN connection on your client using your username, password, and passphrase – using the advanced options to route all traffic through VPN

#NOTES
+ Using this script on Mavericks works if system is on 10.9.1 and Server.app 3.0.2 or greater and the VPN update patch from Apple has been applied.
+ You can easily lock down OS X 10.10 Server without any additional 3rd party firewall software. Allow access via VPN and allow VNC access only to local networks, etc.
