#!/bin/bash
# MAKES SURE WE ARE AT LEAST RUNNING 10.6 OR NEWER
if [[  $(sw_vers -productVersion | grep '10.[6-9]') ]]
then
if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist | grep 'NoMulticast') ]]
sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string -NoMulticastAdvertisements" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
echo "PLEASE REBOOT"
else
echo "SORRY, MULTICAST IS ALREADY DISABLED"
fi
exit
else
echo "SORRY, THIS IS ONLY FOR OS X 10.6 OR NEWER"
fi
exit
