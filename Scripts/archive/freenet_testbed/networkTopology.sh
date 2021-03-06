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

function GetPeers
{
	#remove peer file from remote machine if it already exists
	#runCommand="rm $4peers.txt"
	#$_sshScript $1 $2 $3 "$runCommand"
       
	echo "Getting peers from $1"
	$_telnetScript "$1" "$_defaultPort" "TMCI> " "PEERFILE:CONNECTED" | grep "^\"" > $saveDir$1"peers.txt"
	
	#rm $saveDir$1"peers.txt"
	#$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"peers.txt" $saveDir$1"peers.txt"
	cat $saveDir$1"peers.txt" | sed "s/192.168.0.1//g" | sed "s/:[0-9]*//g"  >> "$5"
	rm $saveDir$1"peers.txt"
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

while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	GetPeers "$remoteMachine" "$remoteUser" "$password" "$remoteInstallDir" "$fileName" &
	
done < "$configFile"

# wait for all peers to respond
wait

sort "$fileName" > "$fileName.srt"

echo "digraph G {" > "$fileName"
#echo "node [fontsize=24]" >> "$fileName"
#echo "overlap=\"scale\"" >> "$fileName"

cat "$fileName.srt" >> "$fileName"

echo "}" >> "$fileName"
rm "$fileName.srt"

circo -Tpng "$fileName" -o "$fileName.png"

echo "********** Graph Complete ***************"
