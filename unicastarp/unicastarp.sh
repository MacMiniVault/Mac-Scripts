#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.01 RELEASE DATE NOV 08 2013     #
# DESC:  DISABLES  ARP CACHE VALIDATION     #
#############################################
#REQUIREMENTS:
#  OS X 10.9 or newer
#############################################
#CHECK FOR OS X 10.9
if [[  $(sw_vers -productVersion | grep '10.9')  ]]
then
   if [[ -f /etc/sysctl.conf ]]
   then
      if grep 'unicast' /etc/sysctl.conf > /dev/null 2>&1
      then
         echo "PATCH WAS PREVIOUSLY ENABLED"
         exit
      else
         sudo sysctl -w net.link.ether.inet.arp_unicast_lim=0  > /dev/null 2>&1
         echo "net.link.ether.inet.arp_unicast_lim=0" | sudo tee -a /etc/sysctl.conf  > /dev/null 2>&1
         sudo chown root:wheel /etc/sysctl.conf
         sudo chmod 644 /etc/sysctl.conf
         echo "PATCH ENABLED"
      fi
   fi
fi
