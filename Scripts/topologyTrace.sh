#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_topologyScript=./networkTopology.sh
_cleanScript=./clean.sh


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

ParameterScriptWelcome "topologyTrace.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd

#===================================================================================================


$_cleanScript $configFile $password

exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	echo "Starting Freenet on $remoteMachine"
	StartRemoteMachine $remoteMachine $remoteUser $password $remoteInstallDir

	sleep 20
	
	echo "Taking a snapshot of the topology so far"
	$_topologyScript $configFile $password

done
exec 0<&3

echo "********** Complete ***************"
