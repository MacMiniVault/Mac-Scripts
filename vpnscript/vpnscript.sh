#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 3.00 RELEASE DATE NOV 11, 2015    #
# DESC:  THIS SCRIPT SETS UP A VPN SERVER   #
#        THAT PLACES VPN CLIENTS IN A LOCAL #
#        VLAN, ALLOWING CLIENTS TO ROUTE    #
#        ALL TRAFFIC THROUGH REMOTE MAC     #
#        ONLY USING THE SINGLE PUBLIC IP    #
#############################################
#REQUIREMENTS:
#  OS X 10.8, OS X 10.9.1 w/SERVER.APP 3.0.2, OS X 10.10 or OS X 10.11
#  SERVER.APP INSTALLED / INITIALIZED
#  NO VLANS CONFIGURED
#  THIS SCRIPT WILL BACKUP AND REPLACE DNS AND FIREWALL CONFIGS
#############################################
#CHECK FOR OS X AND SERVER.app
OSX=no
if [[  $(sw_vers -productVersion | grep '10.8') && $(serverinfo --configured | grep 'has') ]]
then
OSX=yes
fi
if [[  $(sw_vers -productVersion | grep '10.9') && $(serverinfo --configured | grep 'has') && $(serverinfo --shortversion | grep -v '3.0.1') ]]
then
OSX=yes
fi
if [[  $(sw_vers -productVersion | grep '10.10') && $(serverinfo --configured | grep 'has')  ]]
then
OSX=yes
fi
if [[  $(sw_vers -productVersion | grep '10.11') && $(serverinfo --configured | grep 'has')  ]]
then
OSX=yes
fi

if [ $OSX = yes ]
then
echo "Congratulations, you are running OS X and have Server.app installed...."
#CHECK IF SCRIPT HAS BEEN RUN BEFORE
if [ -e /etc/vpn_MMV ]; then
echo "SCRIPT CAN NOT BE RUN MORE THAN ONCE."
exit 1
else
#CREATE TEST FILE TO ENSURE SCRIPT IS NOT EXECUTED MULTIPLE TIMES
sudo touch /etc/vpn_MMV
#STOP VPN AND DNS SERVICES
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin stop dns > /dev/null 2>&1
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin stop vpn > /dev/null 2>&1
#START VLAN SETTINGS
sudo networksetup -createVLAN LAN Ethernet 1
sudo networksetup -setmanual LAN\ Configuration 10.0.0.1 255.255.255.0 10.0.0.1
if [[ $(sw_vers -productVersion | grep '10.8') ]]
then
#FIND CURRENT RESOLVING DNS SERVERS
RESOLVERS=$(grep nameserver /etc/resolv.conf | awk '{ printf ("%s;\n", $2) }')
#START DNS SETTINGS
#SETTING PERMS FOR EDITING - WILL SET PERMS BACK
sudo chmod 666 /etc/named.conf
#BACKUP AND RE-WRITE NAMED.CONF
sudo cp /etc/named.conf /etc/named-backup.conf
sudo cat << EOF > /etc/named.conf
include "/etc/rndc.key";
options {
        directory "/var/named";
        allow-recursion {
                com.apple.ServerAdmin.DNS.public;
        };
        allow-transfer {
                none;
        };
        forwarders {
               $RESOLVERS
        };
};
controls {
        inet 127.0.0.1 port 54 allow {
                "any";
        } keys {
                "rndc-key";
        };
};
acl "com.apple.ServerAdmin.DNS.public" {
        localhost;
        localnets;
};
logging {
        channel "_default_log" {
                file "/Library/Logs/named.log";
                severity info;
                print-time yes;
        };
        category "default" {
                "_default_log";
        };
};
zone "." IN {
        type hint;
        file "named.ca";
};
zone "localhost" IN {
        type master;
        file "localhost.zone";
        allow-update {
                "none";
        };
};
zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.local";
        allow-update {
                "none";
        };
};
EOF
#SET PERMS BACK
sudo chmod 644 /etc/named.conf
#START FIREWALL SETTINGS
#SETTING PERMS FOR EDITING - WILL SET PERMS BACK
sudo chmod 666 /etc/pf.anchors/com.apple
sudo cp /etc/pf.anchors/com.apple /etc/pf-backup
sudo sed -i -e 's/^scrub-anchor "100.I/#scrub-anchor "100.I/' /etc/pf.anchors/com.apple
sudo sed -i -e 's/^nat-anchor "100.I/#nat-anchor "100.I/' /etc/pf.anchors/com.apple
sudo sed -i -e 's/^rdr-anchor "100.I/#rdr-anchor "100.I/' /etc/pf.anchors/com.apple
sudo sed -i -e 's/^anchor "100.I/#anchor "100.I/' /etc/pf.anchors/com.apple
#FIX APPLE TYPO FOR ADAPTIVE FIREWALL - APPLE KB TS4418
sudo sed -i -e 's/^load anchor "400.AdaptiveFirewall\//load anchor "400.AdaptiveFirewall/' /etc/pf.anchors/com.apple
sudo sed  -i -e '/^#anchor "100.I/  a\
nat-anchor "100.customNATRules/*"\
rdr-anchor "100.customNATRules/*"\
load anchor "100.customNATRules" from "/etc/pf.anchors/customNATRules"
'  /etc/pf.anchors/com.apple
#SET PERMS BACK
sudo chmod 644 /etc/pf.anchors/com.apple
elif [[  $(sw_vers -productVersion | grep '[10.9|10.10|10.11]')   ]]
then
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
fi
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
sudo /usr/libexec/PlistBuddy -c 'add :ProgramArguments:3 string -e' /System/Library/LaunchDaemons/com.apple.pfctl.plist
echo 'net.inet.ip.forwarding=1' | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
#START VPN SETTINGS
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin settings > /dev/null 2>&1 << EOF
vpn:Servers:com.apple.ppp.l2tp:IPv4:DestAddressRanges:_array_index:0 = 10.0.0.150
vpn:Servers:com.apple.ppp.l2tp:IPv4:DestAddressRanges:_array_index:1 = 10.0.0.200
vpn:Servers:com.apple.ppp.l2tp:DNS:OfferedServerAddresses:_array_index:0 = 10.0.0.1
EOF
echo "ENTER VPN PASSPHRASE:"
while read passphrase; do
     if [[ (-z "${passphrase}") || ("${passphrase}" =~ ^[0-9]+$) ]]; then
          echo "The passphrase you entered was empty or all numeric, please make it something a little more secure (long alphanumeric)..."
          echo "ENTER VPN PASSPHRASE:"
     else
          echo "Checking strength of passphrase..."
          break
     fi
done
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin settings vpn:Servers:com.apple.ppp.l2tp:L2TP:IPSecSharedSecretValue = $passphrase
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin start dns > /dev/null 2>&1
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin start vpn > /dev/null 2>&1
echo "VPN SETUP SUCCESSFUL"
echo "REBOOT TO TAKE EFFECT"
echo "ONCE REBOOTED, TURN VPN OFF AND BACK ON"
fi
exit 0
#END IF STATEMENT CHECKING FOR OS X & SERVER.APP
else
echo "ERROR: YOU ARE NOT RUNNING OS X OR YOU DO NOT HAVE SERVER.APP INSTALLED"
echo "NOTE: FOR MAVERICKS, SERVER.APP 3.0.2 OR HIGHER IS REQUIRED"
exit 1
fi
