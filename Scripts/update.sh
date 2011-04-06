#!/bin/bash

# Variables
_dataArrayRemote=()
_dataArrayLocal=()
_sshScript=./common/sshlogin.exp
_scpScript=./common/scplogin.exp
_cleanScript=./clean.sh
_assignLocations=./assignLocation.sh
_defaultConfigFile=./config/remoteMachines.dat


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
	local runCommand="find $4 -type f -printf '%s:%TY:%Tj:%TT:%p:\n'"
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

#clean all of the peer info since, copying the ini will invalidate it
$_cleanScript $configFile $password

# change the node location of all the nodes
$_assignLocations $configFile $password

exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
	localInstallDir=$(echo $line | cut -d',' -f5)
	#echo $remoteMachine
	#echo $remoteUser
	#echo $remoteInstallDir
	#echo $password
       
	unset _dataArrayRemote
	unset _dataArrayLocal
	echo "Checking files on $remoteMachine as user $remoteUser in directory $remoteInstallDir ..."
	#GetRemoteData $remoteMachine $remoteUser $password $remoteInstallDir
	GetLocalData $localInstallDir
	CheckRemoteData $remoteMachine $remoteUser $password $remoteInstallDir $localInstallDir
done
exec 0<&3
echo "********** Update Complete ***************"
