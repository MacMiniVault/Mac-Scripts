#!/bin/bash
#############################################
# AUTHOR: JONATHAN SCHWENN @JONSCHWENN      #
# MAC MINI VAULT - MAC MINI COLOCATION      #
# MACMINIVAULT.COM - @MACMINIVAULT          #
# VERSION 1.00 RELEASE DATE MAR 19 2013     #
# DESC:  CHANGES THE PORT SSH LISTENS ON    #
#############################################
#REQUIREMENTS:
#  OS X 10.8 or newer
#############################################
#CHECK FOR OS X 10.8+
if [[  $(sw_vers -productVersion | grep '10.[8-9]')  ]]
then
echo "THIS SCRIPT WILL CHANGE YOUR SSH PORT AND RESTART SSH."
echo "THE DEFAULT PORT FOR SSH IS 22, WE RECOMMEND A CUSTOM"
echo "PORT OVER 1000.  THIS SCRIPT CAN ALSO RETURN SSH BACK"
echo "TO 22, JUST ENTER "22" FOR THE PORT NUMBER."
echo "........."
echo "PLEASE ENTER A PORT NUMBER:"
while read port; do
	if [[ $port =~ [0-9]{2,10} ]]; then
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
echo "INVALID PORT: MUST BE NUMERIC! (2 to 10 digits)"
	fi
done
#TURN OFF AND TURN BACK ON REMOTE LOGIN
echo "yes" | sudo systemsetup -setremotelogin off > /dev/null 2>&1
sleep 5
sudo systemsetup -setremotelogin on > /dev/null 2>&1
else
echo "ERROR: YOU ARE NOT RUNNING OS X 10.8 OR NEWER"
exit 1
fi
