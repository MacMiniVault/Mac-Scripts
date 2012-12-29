#!/bin/bash
# MAKES SURE WE ARE AT LEAST RUNNING 10.8 OR NEWER
if [[  $(sw_vers -productVersion | grep '10.[8-9]') ]]
then
# CHECKS FOR FLAG IN CURRENT PLIST FILE
if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist | grep 'NoMulticast') ]]
then
echo "SORRY, MULTICAST IS ALREADY DISABLED"
else
sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string -NoMulticastAdvertisements" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
echo "DNS MULTICAST (BONJOUR) ADVERTISING DISABLED"
fi
# SET SYSTEM PREFFERENCES
sudo systemsetup -setharddisksleep never > /dev/null 2>&1
sudo systemsetup -setcomputersleep never > /dev/null 2>&1
sudo systemsetup -setdisplaysleep never > /dev/null 2>&1
sudo systemsetup -setallowpowerbuttontosleepcomputer off > /dev/null 2>&1
sudo systemsetup -setrestartpowerfailure on > /dev/null 2>&1
sudo systemsetup -setwakeonnetworkaccess on > /dev/null 2>&1
sudo pmset repeat wakeorpoweron MTWRFSU  12:00:00
echo "ENERGY PREFERENCES ARE SET"
sudo networksetup -setdnsservers Ethernet 66.185.16.130 66.185.16.131
sudo networksetup -setnetworkserviceenabled Wi-Fi off
sudo networksetup -setnetworkserviceenabled "Bluetooth PAN" off
sudo networksetup -setnetworkserviceenabled "Bluetooth DUN" off
echo "NETWORK PREFERNECES ARE SET"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
sudo killall Finder
echo "FINDER PREFERENCES ARE SET"
sudo defaults write /library/preferences/com.apple.loginwindow PowerOffDisabled -bool true
sudo defaults write /library/preferences/com.apple.loginwindow SHOWFULLNAME -bool true
echo "LOGIN WINDOW PREFERENCES ARE SET"
#
# NOTE: MENU BAR AND BLUETOOTH SETTINGS ARE NOT FUNCTIONING
#
#defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/RemoteDesktop.menu" "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" "/System/Library/CoreServices/Menu Extras/Volume.menu" "/System/Library/CoreServices/Menu Extras/Clock.menu"
#sudo killall SystemUIServer
#echo "WIFI AND BLUETOOTH ICONS ARE REMOVED FROM MENU BAR"
#cd ~/Downloads
#curl -O -s https://raw.github.com/MacMiniVault/Mac-Scripts/master/setupscript/blueutil
#sudo mkdir -p /usr/local/bin
#sudo mv blueutil /usr/local/bin/
#sudo chmod 744 /usr/local/bin/blueutil
#blueutil off 
#echo "BLUETOOTH PREFERENCES ARE SET"
echo "...."
echo "MAKE SURE SHARING PREFERENCES ARE CONFIGURED"
echo "RUN SOFTWARE UPDATES"
echo "REBOOT FOR ALL CHANGES TO TAKE EFFECT"
else
echo "SORRY, THIS IS ONLY FOR OS X 10.8 OR NEWER"
fi
exit
