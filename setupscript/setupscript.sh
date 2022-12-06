#!/bin/bash
# REQUEST ADMIN PASSWORD AND KEEP ALIVE
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
# MAKES SURE WE ARE AT LEAST RUNNING 10.8 OR NEWER
if [[  $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | grep -E '10.[7-9]|1[0-9]') ]]
then
# CLEAR NVRAM IN CASE FIND MY MAC WAS PREVIOUSLY ENABLED
sudo nvram -d fmm-computer-name
sudo nvram -d fmm-mobileme-token-FMM
# DISABLE BONJOUR ADVERTISING
if [[  $(sw_vers -productVersion | grep '10.[6-9]') ]]
	then
		# CHECKS FOR FLAG IN CURRENT PLIST FILE
		if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist | grep 'NoMulticast') ]]
		then
			echo "MULTICAST DISABLED, NO CHANGES MADE"
		else
			sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string -NoMulticastAdvertisements" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
			echo "MULTICAST DISABLED (OS X 10.6-10.9)"
		fi
fi
# SET ENERGY PREFERENCES
# SET AUTO POWER ON / WAKE EVERY MIDNIGHT
sudo systemsetup -setallowpowerbuttontosleepcomputer off > /dev/null 2>&1
sudo pmset sleep 0
sudo pmset disksleep 0
sudo pmset displaysleep 0
sudo pmset autorestart 1
sudo pmset womp 1
sudo pmset repeat wakeorpoweron MTWRFSU  23:00:00
sudo pmset -c powernap 0
echo "ENERGY PREFERENCES ARE SET"
# SET DNS RESOLVERS AND TIMEZONE
while true; do
                read -p "IS THIS MACHINE IN MKE1 or PHX1? [M/P]" sp
                case $sp in
                [Mm]* ) sudo networksetup -setdnsservers Ethernet 66.185.16.131 66.185.16.130; sudo systemsetup -settimezone America/Chicago; break;;
                [Pp]* ) sudo networksetup -setdnsservers Ethernet 162.253.135.67 162.253.135.66; sudo systemsetup -settimezone America/Phoenix; break;;
                * ) echo "Please type either an M or a P.";;
                esac
        done
# SET SEARCH DOMAIN AND CLEAR DNS CACHE TO USE CACHING SERVERS
sudo networksetup -setsearchdomains Ethernet macminivault.com
sudo killall -HUP mDNSResponder
# CLEAN UP ANY SAVED WIFI PASSWORDS
sudo networksetup -removeallpreferredwirelessnetworks en1
# DISABLES WIFI/BLUETOOTH NETWORKING
sudo networksetup -deletepppoeservice "Bluetooth PAN"
sudo networksetup -deletepppoeservice "Bluetooth DUN"
sudo networksetup -deletepppoeservice "Thunderbolt Bridge"
sudo networksetup -deletepppoeservice "FireWire"
echo "NETWORK PREFERENCES ARE SET"
# SET PREFERENCES FOR FINDER AND LOGIN WINDOW
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
sudo killall Finder
echo "FINDER PREFERENCES ARE SET"
sudo defaults write /Library/Preferences/com.apple.loginwindow PowerOffDisabled -bool true
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
echo "LOGIN WINDOW PREFERENCES ARE SET"
# SET COMPUTER NAME, DISABLE AND REENABLE REMOTE LOGIN AND SCREEN SHARING
MINI=xxx
echo "WHAT MACHINE IS THIS? (e.g.; a1-8, d8-8, e16-5)"
read MINI
sudo scutil --set ComputerName "$MINI.macminivault.com"
sudo scutil --set HostName "$MINI.macminivault.com"
echo "COMPUTER NAME SET"
echo "yes" | sudo systemsetup -setremotelogin off > /dev/null 2>&1
sleep 5
#sudo systemsetup -setremotelogin on > /dev/null 2>&1
if [[  $(sw_vers -productVersion | grep '10.[6-9]') ]]
then
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true
sleep 5
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist
fi
if [[  $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | grep -E '10.1[0-5]|1[1-3].[0-9]') ]]
then
sudo launchctl enable system/com.apple.screensharing
sleep 5
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
fi
echo "REMOTE LOGIN AND SCREEN SHARING ARE ENABLED"
# DISABLES THE ANNOYING "NO KEYBOARD" BLUETOOTH POPUP
# MOUNTAIN LION SPECIFIC SETTINGS
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
# MAVERICKS SPECIFIC SETTINGS
if [[  $(sw_vers -productVersion | grep '10.9') ]]
then
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekKeyboard '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekPointingDevice '0' > /dev/null 2>&1
echo "BLUETOOTH IS DISABLED"
# DISABLE IDIOTIC SETTING 'DISPLAYS HAVE SEPERATE SPACES'
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
# 10.10+ SETTINGS
if [[  $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | grep -E '10.1[0-5]|1[1-3].[0-9]') ]]
then
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekKeyboard '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekPointingDevice '0' > /dev/null 2>&1
echo "BLUETOOTH IS DISABLED"
# DISABLE IDIOTIC SETTING 'DISPLAYS HAVE SEPERATE SPACES'
defaults write com.apple.spaces spans-displays -bool TRUE
fi
echo "...."
echo "...."
echo "RUN SOFTWARE UPDATES MANUALLY AFTER THE REBOOT."
# PROGRESS SPINNER AND SOFTWARE UPDATES
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
if [[  $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | grep -E '10.[7-9]|10.1[0-3]') ]]
then
sudo softwareupdate -i -r > /dev/null 2>&1 &
fi
# New 2018 minis that require an EFI firmware update will not come back online unless the --restart option is selected - obviously this means the rest of the script won't be run, which is fine.
if [[  $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | grep -E '10.1[4-5]') ]]
then
sudo softwareupdate -i -r --restart > /dev/null 2>&1 &
fi
# SCRIPTED UPDATES NO LONGER WORK ON BIG SUR+ DUE TO SECONDARY AUTH PROMPT, SKIPPING TO REBOOT
if [[  $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | grep -E '1[1-3].[0-9]') ]]
then
sudo reboot > /dev/null 2>&1
fi
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
