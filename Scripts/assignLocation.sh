#!/bin/bash

# Variables
_dataArrayRemote=()
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_defaultConfigFile=./config/remoteMachines.dat
_tmpDir="/tmp/"


#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
# Array to store results
#	% 1 = File Name
#	% 2 = File Size
#	% 3 = Modified Date in seconds
function GetRemoteData
{
	local runCommand="find $4node-* -type f -printf '%s:%TY:%Tj:%TT:%p:\n'"
	local installEscaped=$(echo $4 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	echo "Running ssh $2@$1..."
	local index=1
	#1 File Size:2 Year:3 Day of Year:4 Hour:5 Minute:6 Second:7 File Name
	while read fileLine
	do
		#echo "File: $fileLine"
		#echo "Check: $4"
		if [[ $(echo $fileLine | cut -d':' -f7) == *$4* ]]
		then
			_dataArrayRemote[$index]=$(echo $fileLine | cut -d':' -f7 | sed -e "s/$installEscaped//")
			_dataArrayRemote[$index+1]=$(echo $fileLine | cut -d':' -f1)
			local year=$(echo $fileLine | cut -d':' -f2)
			local day=$(echo $fileLine | cut -d':' -f3 | sed 's/0*//')
			local hour=$(echo $fileLine | cut -d':' -f4 | sed 's/0*//')
			local min=$(echo $fileLine | cut -d':' -f5 | sed 's/0*//')
			local sec=$(echo $fileLine | cut -d':' -f6 | sed 's/0*//')
			sec=${sec/\.*}

			#echo $year
			#echo $day
			#echo $hour
			#echo $min
			#echo $sec

			_dataArrayRemote[$index+2]=$[(year*31622400)+(day*86400)+(hour*3600)+(min*60)+sec]


			#echo "Remote file foud"
			#echo "${_dataArrayRemote[$index]}"
			#echo ${_dataArrayRemote[$index+1]} 
			#echo ${_dataArrayRemote[$index+2]}

			let "index += 3"
		fi
	done  < <($_sshScript $1 $2 $3 "$runCommand")
}


#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
#5 Location
function Changelocation
{
	local localFile="$_tmpDir${_dataArrayRemote[1]}"
	local remoteFile="$4${_dataArrayRemote[1]}"
	#echo "remote $remoteFile"
	#echo "local $localFile and loc $5"
	$_scpScript $1 $2 $3 "$remoteFile" "$localFile"
	sed -e "s/^location=.*/location=$5/" "$localFile" > "$localFile.correct"
	$_scpScript $1 $2 $3 "$localFile.correct" "$remoteFile"
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

location=0.0
machineCount=0

exec 3<&0
# get total number of machines
exec 0<$configFile
while read line
do
	machineCount=$(echo $machineCount + 1 | bc)
done

step=$(calc 1 / $machineCount)

exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
       
	echo "Changing location on $remoteMachine to location $location"
	unset _dataArrayRemote
	GetRemoteData $remoteMachine $remoteUser $password $remoteInstallDir
	Changelocation $remoteMachine $remoteUser $password $remoteInstallDir $location

	location=$(echo $location + $step | bc)
done
exec 0<&3
echo "********** Clean Complete ***************"
