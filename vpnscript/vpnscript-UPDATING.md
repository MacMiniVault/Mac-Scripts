# NOTICE FOR UPDATING SERVER.APP or OS X WITH VPN CONFIG
===========
If VPN stops connecting or routing client traffic after upgrading Server.app or OS X be sure to try a few things:

+ Reboot 
+ Turn VPN off and on
+ Check the network preferences for VLAN config

### If VLAN configuration is missing run the following commands in terminal:

*First run:*

	sudo networksetup -createVLAN LAN Ethernet 1

*Then run:*

	sudo networksetup -setmanual LAN\ Configuration 10.0.0.1 255.255.255.0 10.0.0.1

### If 10.8 was upgraded to 10.9, the firewall configuration would need to be updated as well.

+ Add these lines under the first (8) lines of comments in /etc/pf.anchors/com.apple  

        nat-anchor "100.customNATRules/*"
        rdr-anchor "100.customNATRules/*"
        load anchor "100.customNATRules" from "/etc/pf.anchors/customNATRules"