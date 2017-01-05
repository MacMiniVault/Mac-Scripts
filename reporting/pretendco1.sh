#!/bin/bash

# Get Server Ping's, if up : get Host, get Server.app version, 
# get OS X version, get Uptime, get Volume usage report, dig resolution.
# get hostinfo,

# 192.168.0.159 : filemaker
# 192.168.0.160 : miniserver01 
# 192.168.0.161 : miniserver02
# 192.168.0.164 : proserver01
# 192.168.0.165 : proserver02

function main {
		for ip in 192.168.0.159 192.168.0.160 192.168.0.161 192.168.0.164 192.168.0.165; do
			if ping -c 1 $ip 2>&1 > /dev/null; then
				ssh root@$ip 'printf "Server : "; dig -x' $ip '|grep "NS";
					printf "Server Version : "; serverinfo --shortversion;
					printf "Uptime : ";  uptime;
					printf "Volumes : ";  df -h /Volumes/*; 
					hostname;
					hostinfo;
#					systemstats;
#					zprint -s|head -n 13; 
					echo "";';
			else 
				echo $ip ": failed";
			fi
		done

# Ping Switchs just to see if they are up
# 192.168.0.168 : Qlogic SANbox 5600
# 192.168.0.169 : Qlogic SANbox 5600
# 192.168.0.170 : Qlogic SANbox 5600

	for ip in 192.168.0.168 192.168.0.169 192.168.0.170; do 
		if ping -c 1 $ip 2>&1 > /dev/null; then
			echo $ip " : Switch Up";
		else
			echo $ip " : Switch Down";
		fi
	done 
}
