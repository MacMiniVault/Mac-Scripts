#!/bin/bash
sudo -v
# CHECKS FOR FLAG IN CURRENT PLIST FILE
			if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.discoveryd.plist | grep 'no-multicast') ]]
	                then	
				echo "MULTICAST DISABLED, NO CHANGES MADE"
                	else
                        	sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string --no-multicast" /System/Library/LaunchDaemons/com.apple.discoveryd.plist
                        	echo "MULTICAST DISABLED (OSX 10.10)"
                	fi
sudo systemsetup -setallowpowerbuttontosleepcomputer off > /dev/null 2>&1
sudo pmset sleep 0
sudo pmset disksleep 0
sudo pmset displaysleep 0
sudo pmset displaysleep 0
sudo pmset autorestart 1
sudo pmset womp 1
sudo pmset repeat wakeorpoweron MTWRFSU  23:00:00
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekKeyboard '0' > /dev/null 2>&1
sudo defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekPointingDevice '0' > /dev/null 2>&1
