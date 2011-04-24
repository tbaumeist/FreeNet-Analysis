#!/bin/bash

# Variables
_defaultPort=2323
_scpScriptCopyFrom=./common/scplogin_copyFrom.exp
_defaultSaveDir=~/Desktop/Freenet_Data/Network_Topology/


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

ParameterScriptWelcome "runRemote.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterSaveDirectoryTopology saveDir $3
ParameterScriptWelcomeEnd
#===================================================================================================


fileName=$saveDir"network-topology $(date --rfc-3339=seconds).dot"
fileName=$(echo $fileName | sed -e 's/ /_/g' -e 's/:/\-/g')
echo "Creating file $fileName"

mkdir -p $_defaultSaveDir

echo "digraph G {" > "$fileName"

exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	#remove peer file from remote machine if it already exists
	local runCommand="rm $remoteInstallDirpeers.txt"
	$_sshScript $remoteMachine $remoteUser $password "$runCommand"
       
	echo "Get peers from $remoteMachine"
	VAR=$(expect -c "
	spawn telnet $remoteMachine $_defaultPort
	match_max 100000
	expect \"*TMCI>*\"
	send -- \"PEERFILE:CONNECTED\r\"
	send -- \"QUIT\r\"
	expect eof
	")
	#echo $VAR
	
	rm $_defaultSaveDir"peers.txt"
	$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"peers.txt" "$_defaultSaveDir"
	cat $_defaultSaveDir"peers.txt" >> "$fileName"
	rm $_defaultSaveDir"peers.txt"
	
done
exec 0<&3

echo "}" >> "$fileName"

#cat "$fileName"

circo -Tpng "$fileName" -o "$fileName.png"


echo "********** Graph Complete ***************"
