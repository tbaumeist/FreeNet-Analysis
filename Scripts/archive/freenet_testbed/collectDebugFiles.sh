#!/bin/bash

# Variables
_defaultPort=2323
_scpScriptCopyFrom=./common/scplogin_copyFrom.exp
_sshScript=./common/sshlogin.exp
_telnetScript=./common/telnet.exp

#Parameters
#1 Remote Machine
#2 Remote User
#3 Password
#4 Remote Install Dir
#5 Output File

function GetLogs
{
       
	echo "Getting logs from $1"
	
	$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"Debug.SentMessages.dat" $saveDir$1"Debug.SentMessages.dat"
	cat $saveDir$1"Debug.SentMessages.dat"   >> "$5"
	rm $saveDir$1"Debug.SentMessages.dat"
}


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password
# 3 Save location

source ./common/parameters.sh

declare configFile
declare password
declare saveDir
declare fileName

defFileName="debugFiles $(date --rfc-3339=seconds).log"
defFileName=$(echo $defFileName | sed -e 's/ /_/g' -e 's/:/\-/g')

ParameterScriptWelcome "collectDebugFiles.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterSaveDirectoryTopology saveDir $3
ParameterFileName fileName $defFileName $4
ParameterScriptWelcomeEnd
#===================================================================================================


fileName=$saveDir$fileName
echo "Creating file $fileName"

mkdir -p $saveDir

while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	GetLogs "$remoteMachine" "$remoteUser" "$password" "$remoteInstallDir" "$fileName" &
	
done < "$configFile"

# wait for all peers to respond
wait

echo "********** Collection Complete ***************"
