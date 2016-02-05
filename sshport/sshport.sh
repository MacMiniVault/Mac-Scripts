#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.01 RELEASE DATE NOV 05 2013     #
# DESC:  CHANGES THE PORT SSH LISTENS ON    #
#############################################
#REQUIREMENTS:
#  OS X 10.8, 10.9, 10.10
#############################################
#CHECK FOR OS X 10.8-10.10
if [[  $(sw_vers -productVersion | grep -E '10.[8-9]|10.10')  ]]
then
echo "THIS SCRIPT WILL CHANGE YOUR SSH PORT AND RESTART SSH."
echo "THE DEFAULT PORT FOR SSH IS 22, WE RECOMMEND A CUSTOM"
echo "PORT OVER 1000.  THIS SCRIPT CAN ALSO RETURN SSH BACK"
echo "TO 22, JUST ENTER "22" FOR THE PORT NUMBER."
echo "........."
echo "PLEASE ENTER A PORT NUMBER:"
while read port; do
	if [[ $port =~ ^[0-9]{2,5}$ ]]; then
		if [[ $port = 22 ]]; then
			sudo /usr/libexec/PlistBuddy -c "Set Sockets:Listeners:SockServiceName ssh" /System/Library/LaunchDaemons/ssh.plist
echo "SYSTEM WILL NOW LISTEN ON DEFAULT PORT 22 FOR SSH"
		break 2
		else
			sudo /usr/libexec/PlistBuddy -c "Set Sockets:Listeners:SockServiceName $port" /System/Library/LaunchDaemons/ssh.plist
echo "SYSTEM WILL NOW LISTEN ON PORT $port FOR SSH"
		break 2
		fi
	else
echo "INVALID PORT: MUST BE NUMERIC! (2 to 5 digits)"
	fi
done
#TURN OFF AND TURN BACK ON REMOTE LOGIN
echo "yes" | sudo systemsetup -setremotelogin off > /dev/null 2>&1
sleep 5
sudo systemsetup -setremotelogin on > /dev/null 2>&1
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.8, 10.9, or 10.10. THIS SCRIPT DOES NOT WORK ON 10.11: https://github.com/MacMiniVault/Mac-Scripts/blob/master/sshport/sshport-README.md"
exit 1
fi
