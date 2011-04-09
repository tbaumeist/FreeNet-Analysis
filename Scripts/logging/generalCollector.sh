#!/bin/bash

# Variables
_sshScript=../common/sshlogin.exp
_scpScriptCopyFrom=../common/scplogin_copyFrom.exp
_defaultConfigFile=../config/remoteMachines.dat
_defaultSaveDir=~/Desktop/Node_Logs/

#===================================================================================================
#===================================================================================================
# parameters
# 1 Configuration file [optional]
# 2 password [optional, must supply parameter 1]

# check if config file was supplied
if [[ -n "$1" ]]
then
	# config file was given
	configFile="$1"
else
	# use default config file
	configFile="$_defaultConfigFile"
	echo "Using default configuration file :$configFile"
fi

# password check code
if [[ -n "$2" ]]
then
	# password was given
	password="$2"
else
	# ask for password
	echo -n "Enter password:"
	stty -echo
	read password
	stty echo
	echo ""
fi

folderName=$_defaultSaveDir"General Logs $(date --rfc-3339=seconds)/"
folderName=$(echo $folderName | sed -e 's/ /_/g' -e 's/:/\-/g')
folderNameRawData=$folderName"raw_data/"
echo "Creating folder $folderName"

mkdir -p $folderNameRawData


exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
	
	#copy remote files
	$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"logs/general_messages-*.gz" "$folderNameRawData"
	
	# delete remote files
	runCommand="rm "$remoteInstallDir"logs/general_messages-*.gz"
	#echo $runCommand
	$_sshScript $remoteMachine $remoteUser $password "$runCommand"

	#rename local files
	rename "s/\/general_messages-*/\/"$remoteMachine"__general_messages-/" $folderNameRawData*

done
exec 0<&3



echo "********** Complete ***************"
