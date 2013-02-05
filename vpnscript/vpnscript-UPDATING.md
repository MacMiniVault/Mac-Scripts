#NOTICE FOR UPDATING SERVER.APP WITH VPN CONFIG
===========
If VPN stops connecting or routing client traffic after upgrading Server.app be sure to try a few things:

+ Reboot
+ Turn VPN off and on
+ Check the network preferences for VLAN config

#If VLAN configuration is missing run the following commands in terminal:

	sudo networksetup -createVLAN LAN Ethernet 1
	sudo networksetup -setmanual LAN\ Configuration 10.0.0.1 255.255.255.0 10.0.0.1