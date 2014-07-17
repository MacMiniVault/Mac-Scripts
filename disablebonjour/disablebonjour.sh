#!/bin/bash
# MAKES SURE WE ARE AT LEAST RUNNING 10.6 OR NEWER
if [[  $(sw_vers -productVersion | grep '10.[6-9]|1[0-9]') ]]
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
echo "SORRY, THIS IS ONLY FOR OS X 10.6 OR NEWER"
fi
exit
