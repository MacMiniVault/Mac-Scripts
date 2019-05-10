#!/bin/bash
#############################################
# ORIGINAL AUTHOR: JON SCHWENN @JONSCHWENN  #
# CONTRIBUTOR: ALEX LEACH @AJLEACH          #
# MAC MINI VAULT - MAC HOSTING              #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 4.00 RELEASE DATE MAY 09, 2019    #
# DESC:  THIS SCRIPT SETS UP A VPN SERVER   #
#        THAT PLACES VPN CLIENTS IN A LOCAL #
#        VLAN, ALLOWING CLIENTS TO ROUTE    #
#        ALL TRAFFIC THROUGH REMOTE MAC     #
#        ONLY USING THE SINGLE PUBLIC IP    #
#############################################
#REQUIREMENTS:
#  MACOS 10.12 OR 10.13 OR 10.14
#  VPN ENABLER FOR MOJAVE INSTALLED / CONFIGURED
#  NO MACOS SERVER (SERVICES DISABLED / UNINSTALLED)
#  NO VLANS CONFIGURED
#  THIS SCRIPT WILL BACKUP AND REPLACE FIREWALL CONFIGS
#############################################
#CHECK FOR MACOS AND ENSURE SERVER.APP IS NOT INSTALLED
OSX=no
if [[  $(sw_vers -productVersion | grep '10.12') && $(serverinfo --configured | grep 'NOT') ]]
then
OSX=yes
fi
if [[  $(sw_vers -productVersion | grep '10.13') && $(serverinfo --configured | grep 'NOT') ]]
then
OSX=yes
fi
if [[  $(sw_vers -productVersion | grep '10.14') && $(serverinfo --configured | grep 'NOT') ]]
then
OSX=yes
fi

if [ $OSX = yes ]
then
echo "Congratulations, you are running macOS and have do not have Server.app installed...."
#CHECK IF SCRIPT HAS BEEN RUN BEFORE
if [ -e /etc/vpn_MMV ]; then
echo "THIS VPN SCRIPT CANNOT BE RUN MORE THAN ONCE. INSTALLATION ABORTED. NO CHANGES HAVE BEEN MADE."
exit 1
else
#CREATE TEST FILE TO ENSURE SCRIPT IS NOT EXECUTED MULTIPLE TIMES
sudo touch /etc/vpn_MMV
#START VLAN SETTINGS
sudo networksetup -createVLAN LAN Ethernet 1
sudo networksetup -setmanual LAN\ Configuration 10.0.0.1 255.255.255.0 10.0.0.1
#START FIREWALL SETTINGS
#SETTING PERMS FOR EDITING - WILL SET PERMS BACK
sudo chmod 666 /etc/pf.anchors/com.apple
sudo cp /etc/pf.anchors/com.apple /etc/pf-backup
sudo sed  -i -e '8i\
nat-anchor "100.customNATRules/*"\
rdr-anchor "100.customNATRules/*"\
load anchor "100.customNATRules" from "/etc/pf.anchors/customNATRules"
'  /etc/pf.anchors/com.apple
#SET PERMS BACK
sudo chmod 644 /etc/pf.anchors/com.apple
#CREATE CUSTOM NAT RULES - SETTING PERMS FOR EDITING - WILL SET PERMS BACK
sudo touch /etc/pf.anchors/customNATRules
sudo chmod 666 /etc/pf.anchors/customNATRules
sudo cat << EOF > /etc/pf.anchors/customNATRules
nat on en0 from 10.0.0.0/24 to any -> (en0)
pass from {lo0, 10.0.0.0/24} to any keep state
EOF
#SET PERMS BACK
sudo chmod 644 /etc/pf.anchors/customNATRules
#ENABLE PF AND ENABLE KERNEL IP FORWARDING
sudo pfctl -f /etc/pf.conf > /dev/null 2>&1
echo 'net.inet.ip.forwarding=1' | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
#COPY AND CREATE PLIST
sudo cp /System/Library/LaunchDaemons/com.apple.pfctl.plist /Library/LaunchDaemons/net.mmvpf.pfctl.plist
sudo sed -i '' 's/com.apple.pfctl/net.mmvpf.pfctl/' /Library/LaunchDaemons/net.mmvpf.pfctl.plist
sudo sed -i '' 's/>-f</>-e</' /Library/LaunchDaemons/net.mmvpf.pfctl.plist
sudo sed -i '' '/pf\.conf/d' /Library/LaunchDaemons/net.mmvpf.pfctl.plist
sudo launchctl load -w /Library/LaunchDaemons/net.mmvpf.pfctl.plist
echo "VPN SETUP SUCCESSFUL"
echo "REBOOT TO TAKE EFFECT"
echo "ONCE REBOOTED, MAKE SURE VPN ENABLER IS TURNED ON"
fi
exit 0
#END IF STATEMENT CHECKING FOR MACOS
else
echo "ERROR: YOU ARE NOT RUNNING MACOS 10.12/10.13/10.14 OR YOU HAVE SERVER.APP INSTALLED"
exit 1
fi
