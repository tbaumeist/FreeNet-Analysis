#!/bin/bash

# Variables
_dataArrayRemote=()
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_scpScriptCopyFrom=./common/scplogin_copyFrom.exp
_tmpDir="/tmp/"

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Install Directory
#5 New Location
function GenerateLocation
{
	echo "Changing location on $1 to location $5"
	unset _dataArrayRemote
	GetRemoteData $1 $2 $3 $4
	Changelocation $1 $2 $3 $4 $5
}

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
	#echo "Array count = ${#_dataArrayRemote[@]}"
	for (( j = 1 ; j < ${#_dataArrayRemote[@]} ; j = j+3 ))
	do
		local localFile="$_tmpDir$1${_dataArrayRemote[$j]}"
		local remoteFile="$4${_dataArrayRemote[$j]}"
		echo "remote $remoteFile"
		echo "local $localFile and loc $5"
		$_scpScriptCopyFrom $1 $2 $3 "$remoteFile" "$localFile"
		sed -e "s/^location=.*/location=$5/" "$localFile" > "$localFile.correct"
		$_scpScript $1 $2 $3 "$localFile.correct" "$remoteFile"
	done
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

ParameterScriptWelcome "assignLocations.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd

#===================================================================================================

location=0.0

while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	# random location
	radNumber=$[$RANDOM%1000]
	location=$(echo "scale=4;$radNumber / 1000" | bc)
	# add leading zero on
	location="0$location"
	#echo $location
	GenerateLocation $remoteMachine $remoteUser $password $remoteInstallDir $location &

done < "$configFile"

wait #wait for everyone

echo "********** Clean Complete ***************"
