#!/bin/bash

# Variables
_defaultPort=2323
_scpScriptCopyFrom=./common/scplogin_copyFrom.exp
_sshScript=./common/sshlogin.exp


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

defFileName="network-topology $(date --rfc-3339=seconds).dot"
defFileName=$(echo $defFileName | sed -e 's/ /_/g' -e 's/:/\-/g')

ParameterScriptWelcome "networkTopology.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterSaveDirectoryTopology saveDir $3
ParameterFileName fileName $defFileName $4
ParameterScriptWelcomeEnd
#===================================================================================================


fileName=$saveDir$fileName
echo "Creating file $fileName"

mkdir -p $saveDir

echo "digraph G {" > "$fileName"
echo "node [fontsize=24]" >> "$fileName"
echo "overlap=\"scale\"" >> "$fileName"

exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	#remove peer file from remote machine if it already exists
	runCommand="rm $remoteInstallDirpeers.txt"
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
	
	rm $saveDir"peers.txt"
	$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"peers.txt" "$saveDir"
	cat $saveDir"peers.txt" | sed "s/192.168.0.1//g" | sed "s/:[0-9]*//g"  >> "$fileName"
	rm $saveDir"peers.txt"
	
done
exec 0<&3

echo "}" >> "$fileName"

#cat "$fileName"

circo -Tpng "$fileName" -o "$fileName.png"


echo "********** Graph Complete ***************"
