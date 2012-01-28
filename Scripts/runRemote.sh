#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_loggingScript=./logging/collectorGeneral.sh
_port=8889
_telnetPort=8887
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

function close
{
	if [ $remoteDebugPID -ge 0 ]	
	then
		echo "Killing debug server $remoteDebugPID"
		kill $remoteDebugPID
	fi
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password
# 3 Start Options

source ./common/parameters.sh

declare configFile
declare password
declare remoteDebugPID=-1
declare control

ParameterScriptWelcome "runRemote.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterRandomQuestion control "Start normal (s)/ Start remote debugging (r)/ Start only seed nodes (seed)/ Stop (x) [default is x]:" "x" $3
ParameterScriptWelcomeEnd

#===================================================================================================

#Get local IP
IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | grep -v '192.168.33' | cut -d: -f2 | awk '{ print $1}'`


# start remote debug server
if [ "$control" = "r" ]	
then
	# Start the remote debug collector
	trap close INT

	echo "Starting debug server"
	java -jar $_debugServer $_port $_telnetPort &
	remoteDebugPID=$!
fi

while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	if [ "$control" = "s" ]	
	then
		echo "Starting Freenet on $remoteMachine"
		StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir "" ""
		# space out starting nodes			
		sleep 20
	elif [ "$control" = "r" ]	
	then
		echo "Starting Freenet on $remoteMachine with remote debug"
		StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir $IP $_port
		# space out starting nodes			
		sleep 20
	elif [ "$control" = "seed" ]
	then
		if [ "$remoteType" = "SEED" ]
		then
			echo "Starting Freenet seed node on $remoteMachine"
			StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir "" ""
			# space out starting nodes			
			sleep 20
		fi
	else
		echo "Stopping Freenet on $remoteMachine"
		StopRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir &
	fi
done < "$configFile"

#wait for the stop machine command to finish
wait

if [ $remoteDebugPID -ge 0 ]	
then
	echo "*******************************************"
	echo "Listening to debug server (CTRL-C to close)"
	wait $remoteDebugPID
fi

echo "********** Run Script Complete ***************"
