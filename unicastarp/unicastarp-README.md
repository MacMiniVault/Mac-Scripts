#READ ME FOR UNICAST ARP CACHE VALIDATION
===========

There is a new security function in OS X 10.9 Mavericks that performs validation of the ARP cache.  Basically, it's trying to attempt to see if the network gateway (router) is being spoofed/redirected.  Unfortunately it interprets our redundant routers as an issue and causes network performance, lag, and packet loss.

Not many Macs are in this scenario, but we happen to have a lot.  Each Mac mini cabinet in our data center uses redundant Cisco 6509's as gateways.  There are multiple fiber paths that are one hop away from the upstream internet connections.  

To disable this function in OS X 10.9 we've written a script.  It's reversible in the future, but in the mean time it'll stop you from pulling your hair out.  Macs on high availability networks found in data centers and enterprise environments can be affected.

Credit to Lunaweb in this [post](https://discussions.apple.com/message/23529716#23529716) in Apple's Community Forum.

This script was developed and tested by the staff of Mac Mini Vault, we colocate a lot of Macs and tirelessly work to add usability and streamline the plight of the Mac in the data center world.  Check out our website at http://www.macminivault.com

#WHAT THIS SCRIPT DOES
+ Checks to make sure OS X is at 10.9
+ Checks for the patch and file already
+ Sets the configuration variable on the live system
+ Creates the proper file for the variable to be set upon reboot

#INSTALLATION

+ Open Terminal and run the following command

        bash <(curl -Ls http://git.io/6YzLCw)

+ Enter in your password when prompted.
+ Thats it! 
