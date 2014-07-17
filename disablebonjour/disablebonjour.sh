#!/bin/bash
# MAKES SURE WE ARE RUNNING 10.6 -> 10.9 #YOSEMITE SUPPORT TBD
if [[  $(sw_vers -productVersion | grep '10.[6-9]') ]]
then
# CHECKS FOR FLAG IN CURRENT PLIST FILE
if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist | grep 'NoMulticast') ]]
then
echo "MULTICAST DISABLED, NO CHANGES MADE"
else
sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string -NoMulticastAdvertisements" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
echo "MULTICAST DISABLED, PLEASE REBOOT"
fi
exit
else
echo "THIS SCRIPT HAS BEEN TESTED ON MAC OS X 10.6 THROUGH OS X 10.9"
fi
exit
