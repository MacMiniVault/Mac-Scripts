#!/bin/bash
# REQUEST ADMIN PASSWORD AND KEEP ALIVE
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
# MAKES SURE WE ARE AT LEAST RUNNING 10.8 OR NEWER
if [[  $(sw_vers -productVersion | grep '10.[8-9]') ]]
then
# CHECKS FOR FLAG IN CURRENT PLIST FILE
if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist | grep 'NoMulticast') ]]
then
echo "SORRY, MULTICAST IS ALREADY DISABLED"
else
# ADDS NOMULTICASTADVERTISEMENTS FLAG
sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string -NoMulticastAdvertisements" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
echo "DNS MULTICAST (BONJOUR) ADVERTISING DISABLED"
fi
# SET ENERGY PREFFERENCES
# SET AUTO POWER ON / WAKE EVERY MIDNIGHT
sudo systemsetup -setallowpowerbuttontosleepcomputer off > /dev/null 2>&1
sudo pmset disksleep 0
sudo pmset displaysleep 0
sudo pmset sleep 0
sudo pmset displaysleep 0
sudo pmset autorestart 1
sudp pmset womp 1
sudo pmset repeat wakeorpoweron MTWRFSU  12:00:00
echo "ENERGY PREFERENCES ARE SET"
# DISABLES WIFI/BLUETOOTH NETWORKING 
while true; do
                read -p "IS THIS MACHINE IN MKE1 or PHX1? [M/P]" sp
                case $sp in
                [Mm]* ) sudo networksetup -setdnsservers Ethernet 66.185.16.130 66.185.16.131; break;;
                [Pp]* ) sudo networksetup -setdnsservers Ethernet 162.253.135.66 162.253.135.67; break;;
                * ) echo "Please type either an M or a P.";;
                esac
        done
sudo networksetup -setnetworkserviceenabled Wi-Fi off
sudo networksetup -setnetworkserviceenabled "Bluetooth PAN" off
sudo networksetup -setnetworkserviceenabled "Bluetooth DUN" off
echo "NETWORK PREFERNECES ARE SET"
# SET PREFERENCES FOR FINDER AND LOGIN WINDOW
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
sudo killall Finder
echo "FINDER PREFERENCES ARE SET"
sudo defaults write /library/preferences/com.apple.loginwindow PowerOffDisabled -bool true
sudo defaults write /library/preferences/com.apple.loginwindow SHOWFULLNAME -bool true
sudo defaults write /library/preferences/com.apple.loginwindow showInputMenu -bool true
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
echo "LOGIN WINDOW PREFERENCES ARE SET"
# SET COMPUTER NAME, DISABLE AND REENABLE REMOTE LOGIN AND SCREEN SHARING
MINI=xxx
echo "WHAT MACHINE IS THIS? (e.g.; a1-8, d8-8, e16-5)"
read MINI
sudo scutil --set ComputerName "$MINI.macminivault.com"
echo "COMPUTER NAME SET"
echo "yes" | sudo systemsetup -setremotelogin off > /dev/null 2>&1
sleep 5
#sudo systemsetup -setremotelogin on > /dev/null 2>&1
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true
sleep 5
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist
echo "REMOTE LOGIN AND SCREEN SHARING ARE ENABLED"
defaults write ~/Library/Preferences/com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/RemoteDesktop.menu" "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" "/System/Library/CoreServices/Menu Extras/Volume.menu" "/System/Library/CoreServices/Menu Extras/Clock.menu"
sudo killall SystemUIServer
echo "WIFI AND BLUETOOTH ICONS ARE REMOVED FROM MENU BAR"
# DISABLES THE ANNOYING "NO KEYBOARD" BLUETOOTH POPUP
if [[  $(sw_vers -productVersion | grep '10.8') ]]
then
sudo rm  /System/Library/LaunchAgents/com.apple.btsa.plist
launchctl unload -w /System/Library/LaunchAgents/com.apple.bluetoothUIServer.plist
launchctl unload -w /System/Library/LaunchAgents/com.apple.bluetoothAudioAgent.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.blued.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.bnepd.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.IOBluetoothUSBDFU.plist
cd /System/Library/CoreServices
sudo mv Bluetooth\ Setup\ Assistant.app/ Bluetooth\ Setup\ Assistant-OFF.app/
cd -
echo "BLUETOOTH IS DISABLED" 
fi
echo "...."
echo "...."
if [[  $(sw_vers -productVersion | grep '10.9') ]]
then
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekKeyboard '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekPointingDevice '0' > /dev/null 2>&1
echo "BLUETOOTH IS DISABLED"
# DISABLE IDIOTIC SETTING 'DISPLAYS HAVE SEPERATE SPACES' ON MAVERICKS
defaults write com.apple.spaces spans-displays -bool TRUE
# DISABLES UNICAST ARP CACHE VALIDATION
if [[ -f /etc/sysctl.conf ]]
then
if grep 'unicast' /etc/sysctl.conf > /dev/null 2>&1
then
echo "PATCH WAS PREVIOUSLY ENABLED"
fi
else
sudo sysctl -w net.link.ether.inet.arp_unicast_lim=0  > /dev/null 2>&1
echo "net.link.ether.inet.arp_unicast_lim=0" | sudo tee -a /etc/sysctl.conf  > /dev/null 2>&1
sudo chown root:wheel /etc/sysctl.conf
sudo chmod 644 /etc/sysctl.conf
echo "PATCH ENABLED"
fi
fi
echo "...."
echo "...."
# PROGRESS SPINNER AND SOFTEWARE UPDATES
echo "RUNNING SOFTWARE UPDATES"
echo "MACHINE WILL REBOOT AFTER SOFTWARE UPDATES ARE INSTALLED"
echo "SOFTWARE UPDATES CAN TAKE 10+ MINUTES"
spinner()
{
    local pid=softwareupdate
    local delay=0.5
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $5}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
sudo softwareupdate -i -r > /dev/null 2>&1 &
sleep 1
/bin/echo -n "SOFTWARE UPDATES ARE DOWNLOADING AND INSTALLING" && spinner 
echo ""
history -c
clear
# WE ARE GOING TO REBOOT FOR ALL CHANGES AND UPDATES TO TAKE EFFECT
sudo reboot > /dev/null 2>&1
else
echo "SORRY, THIS IS ONLY FOR OS X 10.8 OR NEWER"
fi
exit
