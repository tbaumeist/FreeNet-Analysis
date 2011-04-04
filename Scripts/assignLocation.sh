#!/bin/bash

# Variables
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_defaultConfigFile=./config/remoteMachines.dat


#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
function Changelocation
{
	local runCommand="rm $4*peers*"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1... command $runCommand"
	$_sshScript $1 $2 $3 "$runCommand"
}


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

location=0.1

exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
       
	echo "Cleaning files on $remoteMachine to location $location"
	#Changelocation $remoteMachine $remoteUser $password $remoteInstallDir $location


	location=echo 0.1 + 0.1 | bc
done
exec 0<&3
echo "********** Clean Complete ***************"
