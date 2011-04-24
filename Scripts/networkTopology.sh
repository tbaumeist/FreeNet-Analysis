#!/bin/bash

# Variables
_defaultPort=2323
_scpScriptCopyFrom=./common/scplogin_copyFrom.exp
_defaultConfigFile=./config/remoteMachines.dat
_defaultSaveDir=~/Desktop/Freenet_Data/Network_Topology/


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

fileName=$_defaultSaveDir"network-topology $(date --rfc-3339=seconds).dot"
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
	
	$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir"peers.txt" "$_defaultSaveDir"
	cat $_defaultSaveDir"peers.txt" >> "$fileName"
	rm $_defaultSaveDir"peers.txt"
	
done
exec 0<&3

echo "}" >> "$fileName"

#cat "$fileName"

circo -Tpng "$fileName" -o "$fileName.png"


echo "********** Graph Complete ***************"
