#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
#5 Remote Machine Type
function MasterClean
{
	echo "Cleaning files on $1"
	CleanRemoteMachinePeers $1 $2 $3 $4
	CleanRemoteMachineThrottleData $1 $2 $3 $4
	CleanRemoteMachinePackets $1 $2 $3 $4
	CleanRemoteMachineExtraData $1 $2 $3 $4
	CleanRemoteMachinePersistentData $1 $2 $3 $4
	CleanRemoteMachineLogs $1 $2 $3 $4
	CleanRemoteMachineDatastore $1 $2 $3 $4
	if [ "$5" = "NODE" ]
	then	
		CleanRemoteMachineOpennet $1 $2 $3 $4
	fi
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachinePeers
{
	local runCommand="rm $4*peers*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachinePackets
{
	local runCommand="rm $4*packets*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineOpennet
{
	local runCommand="rm $4*opennet*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineThrottleData
{
	local runCommand="rm $4node-throttle.dat"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineExtraData
{
	local runCommand="rm -rf $4extra*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachinePersistentData
{
	local runCommand="rm -rf $4persistent*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineLogs
{
	local runCommand="rm -rf $4logs"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineTemp
{
	local runCommand="rm -rf $4temp*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineNode
{
	local runCommand="rm -rf $4temp*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function CleanRemoteMachineDatastore
{
	local runCommand="rm -rf $4datastore"
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

ParameterScriptWelcome "clean.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd
#===================================================================================================


while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
       
	MasterClean $remoteMachine $remoteUser $password $remoteInstallDir $remoteType &

done < "$configFile"

wait # wait for everyone to finish

echo "********** Clean Complete ***************"
