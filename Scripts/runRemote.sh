#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_loggingScript=./logging/collectorGeneral.sh



#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function StopRemoteMachine
{
	local runCommand="$4run.sh stop"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}


#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function StartRemoteMachine
{
	local runCommand="$4run.sh start"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password

source ./common/parameters.sh

declare configFile
declare password

ParameterScriptWelcome "runRemote.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd

#===================================================================================================

#ask start stop
echo -n "Start (s)/ Stop (x) [default is x]:"
read control 


exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	if [ "$control" = "s" ]	
	then
		echo "Starting Freenet on $remoteMachine"
		StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir
	else
		echo "Stopping Freenet on $remoteMachine"
		StopRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir
	fi
done
exec 0<&3

if [ "$control" = "s" ]	
then
	# Start Logging Script

	timeDelay=300
	echo "Starting logging script ctrl-C to stop it..."
	echo "Letting Freenet nodes warm up, logging collection process will begin in $timeDelay seconds"
	sleep $timeDelay
	$_loggingScript "$configFile" $password "./logging/"
fi

echo "********** Complete ***************"
