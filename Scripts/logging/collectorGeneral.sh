#!/bin/bash

# Variables
_sshScript=../common/sshlogin.exp
_scpScriptCopyFrom=../common/scplogin_copyFrom.exp
_generalProcessScript=generalLogProcessor.sh
_startDirectory=./
_sleepMinutes=10



#Parameters
#1 Configuration File
#2 Password
#3 Start Directory
#4 Local Folder
function CollectLogs
{
	local config=$1
	local password=$2
	local startDir=$3
	local folderName=$4

	local folderNameRawData=$folderName"raw_data/"

	echo "Creating folder $folderName"
	mkdir -p $folderNameRawData

	exec 3<&0
	exec 0<$config
	while read line
	do
		remoteMachine=$(echo $line | cut -d',' -f1)
		remoteType=$(echo $line | cut -d',' -f2)
		remoteUser=$(echo $line | cut -d',' -f3)
		remoteInstallDir=$(echo $line | cut -d',' -f4)
	
		#copy remote files
		$startDir$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"logs/general_messages-*.gz" "$folderNameRawData"
	
		# delete remote files
		runCommand="rm "$remoteInstallDir"logs/general_messages-*.gz"
		#echo $runCommand
		$startDir$_sshScript $remoteMachine $remoteUser $password "$runCommand"

		#rename local files
		rename "s/\/general_messages-*/\/"$remoteMachine"__general_messages-/" $folderNameRawData*
	done
	exec 0<&3

	$startDir$_generalProcessScript $configFile $password $startDir $folderName 

	echo "********** Collected Logs ***************"
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password
# 3 Working in directory
# 4 Save to directory

declare configFile
declare password
declare startDirectory
declare folderRootName

# check if start directory was supplied
if [[ -n "$3" ]]
then
	# was given
	startDirectory="$3"
else
	# use default dir
	startDirectory="$_startDirectory"
fi
echo "CollectorGeneral.sh Working in directory :$startDirectory"

source $startDirectory../common/parameters.sh


ParameterScriptWelcome "collectorGeneral.sh"
ParameterConfigurationFile configFile $1
configFile=$startDirectory$configFile #append start directory incase this cript was started in another dir
ParameterPassword password $2
ParameterSaveDirectoryLogs folderRootName $4
ParameterScriptWelcomeEnd
#===================================================================================================



while true; do

	echo "Waiting for next poll in $_sleepMinutes minutes ...."
	sleep $[$_sleepMinutes*60] # sleep for x minutes
	#sleep $[60] # sleep for x minutes
	
	folderName=$folderRootName"General Logs $(date --rfc-3339=seconds)/"
	folderName=$(echo $folderName | sed -e 's/ /_/g' -e 's/:/\-/g')
	CollectLogs $configFile $password $startDirectory $folderName &   #runs in its own job
done
