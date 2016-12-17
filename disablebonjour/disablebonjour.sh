#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 2.0  RELEASE DATE OCT 1 2014      #
# DESC:  DISABLES BONJOUR ADVERTISING       #
#############################################
#REQUIREMENTS:
#  OS X 10.6 or newer
#############################################

if [[  $(sw_vers) ]]
then
	# MAKES SURE WE ARE RUNNING 10.6 -> 10.9 or 10.10.4+ -> 10.11 or 10.12
	if [[  $(sw_vers -productVersion | grep '10.[6-9]') ]] || [[  $(sw_vers -productVersion | grep '10.10.[4-5]') ]]
	then
		# CHECKS FOR FLAG IN CURRENT PLIST FILE
		if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist | grep 'NoMulticast') ]]
		then
			echo "MULTICAST DISABLED, NO CHANGES MADE"
		else
			sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string -NoMulticastAdvertisements" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
			echo "MULTICAST DISABLED (OS X 10.6-10.9 or 10.10.4+), PLEASE REBOOT"
		fi
		exit
	else
	echo  "OS X 10.6 - 10.9 or 10.10.4+ NOT DETECTED, NO CHANGES HAVE BEEN MADE YET"
	echo  "CHECKING FOR OS X 10.10.0 to 10.10.3 ..."
		if [[  $(sw_vers -productVersion | grep '10.10[.0-3]') ]]
        	then
                	# CHECKS FOR FLAG IN CURRENT PLIST FILE
			if [[ $(sudo /usr/libexec/PlistBuddy -c Print /System/Library/LaunchDaemons/com.apple.discoveryd.plist | grep 'no-multicast') ]]
	                then
				echo "MULTICAST DISABLED, NO CHANGES MADE"
                	else
                        	sudo /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string --no-multicast" /System/Library/LaunchDaemons/com.apple.discoveryd.plist
                        	echo "MULTICAST DISABLED (OSX 10.10), PLEASE REBOOT"
                	fi
                	exit
		else
		echo "OS X 10.10 NOT DETECTED, NO CHANGES HAVE BEEN MADE YET"
		echo "CHECKING FOR OS X 10.11 to 10.12.2"
			if [[  $(sw_vers -productVersion | grep '10.1[1-2]') ]]
			then
				# CHECKS FOR FLAG IN CURRENT PLIST FILE
				if [[ $(defaults read /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements) == 1 ]]
				then
					echo "MULTICAST DISABLED, NO CHANGES MADE"
				else
					sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES
                    		    	echo "MULTICAST DISABLED (OSX 10.11 or 10.12), PLEASE REBOOT"
				fi
				exit
			fi
			exit
		fi
	fi

else
echo "SORRY, OS X NOT DETECTED - NO CHANGES MADE"
fi
exit
