#!/bin/bash

# Variables
_generalImageFolder=./../NodeImages/General/
_seedFile=seednodes.fref
_updateScript=./update.sh
_runScript=./runRemote.sh
_expScript=./exp_routePrediction.sh
_sshScript=./common/sshlogin.exp

#Parameters
# 1 config file
# 2 password
function reboot
{
	while read machine
	do
		remoteMachine=$(echo $machine | cut -d',' -f1)
		remoteUser=$(echo $machine | cut -d',' -f3)
		$_sshScript $remoteMachine $remoteUser $2 "sudo reboot" &
	done < "$1"

	# now we wait
	while true; do
		local isUpYet
		checkAllUp $1 $2 isUpYet
		if [[ -n "$isUpYet" ]]
		then
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
		result=$($_sshScript $remoteMachine $remoteUser $2 | grep "No route to host")
		if [[ -n "$result" ]]
		then
			echo "$remoteMachine has not started yet!!!!!"
			echo "waiting"
			value="wait"
			break
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
	$_runScript "$1" "$2" "x"
	
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
declare randomCount
declare repeatCount
declare htlCount
declare saveDir
declare fileName

declare configFolder

ParameterScriptWelcome "exp_routePrediction.sh"
ParameterRandomCount randomCount "How many random words to insert at each node? " $1
ParameterRandomCount htlCount "Max HTL? " $2
ParameterRandomCount repeatCount "Number of time to run exp? " $3
ParameterConfigurationFolder configFolder $4
ParameterPassword password $5
ParameterSaveDirectoryGeneral saveDir $6
ParameterFileName fileName $_wordInserted $7
ParameterScriptWelcomeEnd
#===================================================================================================

for file in $configFolder*.dat
do
	for i in `seq $repeatCount`
	do
		configName=$(basename $file | cut -d'.' -f1)
		outputFolder="$saveDir$configName/$i/"
		echo "Setting up output folder $outputFolder"	
		
		setup "$file" "$password" "$_generalImageFolder$_seedFile"

		$_expScript $randomCount $htlCount "$file" "$password" "$outputFolder" "$fileName"
	done
done

echo "********** Running Experiments Complete ***************"
