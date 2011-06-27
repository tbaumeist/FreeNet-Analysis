#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_loggingScript=./logging/collectorGeneral.sh
_port=8889
_debugServer=./debug/DebugServer.jar



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
#5 Local IP
#6 Local Port
function StartRemoteMachine
{
	local runCommand="$4run.sh start $5 $6"
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

if [ "$control" = "s" ]	
then
	echo -n "Start logging collection (l)/ Start remote debugging {linux only} (r)/ Nothing (x) [default is x]:"
	read controlAfter 
fi

#Get local IP
IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

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
		if [ "$controlAfter" = "r" ]	
		then
			echo "Starting Freenet on $remoteMachine with remote debug"
			StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir $IP $_port
		else
			echo "Starting Freenet on $remoteMachine"
			StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir "" ""
		fi
	else
		echo "Stopping Freenet on $remoteMachine"
		StopRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir
	fi
done
exec 0<&3

if [ "$controlAfter" = "l" ]	
then
	# Start Logging Script

	timeDelay=300
	echo "Starting logging script ctrl-C to stop it..."
	echo "Letting Freenet nodes warm up, logging collection process will begin in $timeDelay seconds"
	sleep $timeDelay
	$_loggingScript "$configFile" $password "./logging/"
fi

if [ "$controlAfter" = "r" ]	
then
	# Start the remote debug collector

	echo "Starting debug server"
	java -jar $_debugServer $_port
fi


echo "********** Complete ***************"
