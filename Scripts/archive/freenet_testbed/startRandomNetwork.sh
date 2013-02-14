#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_runScript=./runRemote.sh
_updateScript=./update.sh
_generalImageFolder=./../NodeImages/General/
_seedFile=seednodes.fref

#Parameters
# 1 config file
# 2 password
function reboot
{
	while read machine
	do
		remoteMachine=$(echo $machine | cut -d',' -f1)
		remoteUser=$(echo $machine | cut -d',' -f3)
		$_sshScript $remoteMachine $remoteUser $2 "sudo reboot"
		sleep 40
	done < "$1"

	sleep 30

	# now we wait
	while true; do
		local isUpYet
		checkAllUp $1 $2 isUpYet
		if [[ -n "$isUpYet" ]]
		then
			echo "waiting 60 sec..."
			sleep 60
		else
			break
		fi
	done
}

#Parameters
# 1 config file
# 2 password
# 3 return param
function checkAllUp
{
	local _variable=$3
	local value
	value=""
	while read machine
	do
		remoteMachine=$(echo $machine | cut -d',' -f1)
		remoteUser=$(echo $machine | cut -d',' -f3)
		echo -n "Checking if $remoteMachine is up ... "
		result=$(sleep 2 | nc -w 10 $remoteMachine 22)
		if [ -z "$result" ] # is empty
		then
			echo "Down"
			value="wait"
			break
		else
			echo "Running"
		fi
	done < "$1"
	eval $_variable="'$value'"
}

#Parameters
#1 config file
#2 password
#3 seed file
function setup
{
	echo "Setting up using $1"
	echo "Updating seed file $3"

	#reboot machines for a fresh start
	reboot "$1" "$2"

	#shut down
	#$_runScript "$1" "$2" "x"
	
	# run update with new config file to distribute ini files
	$_updateScript "$1" "$2" "r"

	# start the seed nodes for updated node ref
	$_runScript "$1" "$2" "seed"

	#wait 5 minutes for everyone to start
	sleep 300

	# empty out old seed node ref file
	echo -n "" > "$3"

	#get new node refs
	while read machine
	do
		remoteMachine=$(echo $machine | cut -d',' -f1)
		remoteType=$(echo $machine | cut -d',' -f2)
		if [ "$remoteType" = "SEED" ]
		then
			echo "Getting http://$remoteMachine:8888/strangers/myref.txt"
			wget -O "$3$remoteMachine" "http://$remoteMachine:8888/strangers/myref.txt"
			cat "$3$remoteMachine" >> "$3"
			echo "" >> "$3"
			rm "$3$remoteMachine"
		fi
	done < "$1"

	#shut down
	$_runScript "$1" "$2" "x"

	# run update with new seed node ref file
	$_updateScript "$1" "$2" "r"

	# start the seed nodes for updated node ref
	$_runScript "$1" "$2" "s"

	#wait 5 minutes for everyone to start
	sleep 300
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters

source ./common/parameters.sh

declare configFile
declare password

ParameterScriptWelcome "startRandomNetwork.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd
#===================================================================================================

setup "$configFile" "$password" "$_generalImageFolder$_seedFile"

echo "********** Start Up Network Complete ***************"
