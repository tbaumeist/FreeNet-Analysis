#!/bin/bash

# Variables
_dataArrayLocal=()
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_cleanScript=./clean.sh
_assignLocations=./common/assignLocation.sh

#Parameters
#1 Remote Machine
#2 Remote User
#3 Password
#4 Remote Install Dir
#5 Local Install Dir
function UpdateMachine
{
	unset _dataArrayLocal
	echo "Checking files on $1 as user $2 in directory $4 ..."
	GetLocalData $5
	CheckRemoteData $1 $2 $3 $4 $5
}


#Parameters
#1 Local Install Directory
# Array to store results
#	% 1 = File Name
#	% 2 = File Size
#	% 3 = Modified Date in seconds
function GetLocalData
{
	local installEscaped=$(echo $1 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	local index=1
	#1 File Size:2 Year:3 Day of Year:4 Hour:5 Minute:6 Second:7 File Name
	while read fileLine
	do
		if [[ $(echo $fileLine | cut -d':' -f7) == *$1* ]]
		then
			_dataArrayLocal[$index]=$(echo $fileLine | cut -d':' -f7 | sed -e "s/$installEscaped//")
			_dataArrayLocal[$index+1]=$(echo $fileLine | cut -d':' -f1)
			local year=$(echo $fileLine | cut -d':' -f2)
			local day=$(echo $fileLine | cut -d':' -f3 | sed 's/0*//')
			local hour=$(echo $fileLine | cut -d':' -f4 | sed 's/0*//')
			local min=$(echo $fileLine | cut -d':' -f5 | sed 's/0*//')
			local sec=$(echo $fileLine | cut -d':' -f6 | sed 's/0*//')
			sec=${sec/\.*}
			_dataArrayLocal[$index+2]=$[(year*31622400)+(day*86400)+(hour*3600)+(min*60)+sec]

			#echo "Local file foud"
			#echo "${_dataArrayLocal[$index]}"
			#echo ${_dataArrayLocal[$index+1]} 
			#echo ${_dataArrayLocal[$index+2]}

			let "index += 3"
		fi
	done  < <(find $1 -type f -printf '%s:%TY:%Tj:%TT:%p:\n')
}

#Parameters
#1 Remote Server IP
#2 Remote User Name
#3 Remote User Password
#4 Remote Installed directory
#5 Local Installed directory
#  Array to store results
#	% 1 = File Name
#	% 2 = File Size
#	% 3 = Modified Date in seconds
function CheckRemoteData
{
	echo "Deleting old Freenet.jar files"
	$_sshScript $1 $2 $3 "rm $4freenet*"


	for (( i = 1 ; i < ${#_dataArrayLocal[@]} ; i = i+3 ))
	do
		local fileCopy=true
		# just blindly copy the files no matter if they are the same, much faster
		#for (( j = 1 ; j < ${#_dataArrayRemote[@]} ; j = j+3 ))
		#do
			#if [ "${_dataArrayLocal[$i]}" = "${_dataArrayRemote[$j]}" ]
			#then
				#echo " This and that ${_dataArrayLocal[$i+1]} = ${_dataArrayRemote[$j+1]}"
				#if [ "${_dataArrayLocal[$i+1]}" = "${_dataArrayRemote[$j+1]}" ]
				#then
					#echo " This and that ${_dataArrayLocal[$i+2]} = ${_dataArrayRemote[$j+2]}"
					#if [ "${_dataArrayLocal[$i+2]}" = "${_dataArrayRemote[$j+2]}" ]
					#then
					#	fileCopy=false
					#fi
				#fi				
			#fi
		#done

		# File not found copy it
		if [ $fileCopy = true ]
		then
			local from="$5${_dataArrayLocal[$i]}"
			local to="$4${_dataArrayLocal[$i]}"
			local toDir=$(dirname "$to")
			local runCommand="mkdir -p $toDir"
			echo "Creating directory $toDir"
			$_sshScript $1 $2 $3 "$runCommand"
			echo "Copying file from $from to $to"
			$_scpScript $1 $2 $3 "$from" "$toDir"
		fi
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

ParameterScriptWelcome "update.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd
#===================================================================================================

echo -n "Reset Nodes (r)/ No reset (n) [default is n]:"
read control 

if [ "$control" = "r" ]	
then
	#clean all of the peer info since, copying the ini will invalidate it
	$_cleanScript $configFile $password 

	# change the node location of all the nodes
	$_assignLocations $configFile $password
fi

while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
	localInstallDir=$(echo $line | cut -d',' -f5)
	
	UpdateMachine "$remoteMachine" "$remoteUser" "$password" "$remoteInstallDir" "$localInstallDir" &

done < "$configFile"

wait

echo "********** Update Complete ***************"
