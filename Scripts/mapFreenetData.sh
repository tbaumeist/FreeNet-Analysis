#!/bin/bash

# Variables
_defaultPort=2323
_scpScriptCopyFrom=./common/scplogin_copyFrom.exp
_sshScript=./common/sshlogin.exp
_tmpWordInserted="/tmp/_randomFreenetWords.dat"
_defaultSaveDir="/tmp/"
_fileName="datastorea.txt"
_dataArrayWordIndex=()

#Parameters
function readMasterList
{

	echo "Loading the master word file from $_tmpWordInserted"
	local index=1
	while read line
	do
		local word=$(echo $line |cut -d':' -f1)
		local chk=$(echo $line | cut -d':' -f2 | cut -d'@' -f2 | cut -d',' -f1)
		local loc=$(echo $line |cut -d':' -f3)
		#echo $word:$chk:$loc
		_dataArrayWordIndex[$index]=$word
		_dataArrayWordIndex[$index+1]=$chk
		_dataArrayWordIndex[$index+2]=$loc
		_dataArrayWordIndex[$index+3]=""
		#echo "${_dataArrayWordIndex[$index]}:${_dataArrayWordIndex[$index+1]}:${_dataArrayWordIndex[$index+2]} "
		let "index += 4"
	done < <(cat $_tmpWordInserted)
}

#Parameters
function printMasterList
{
	echo "List of random words and their storage location."
	echo -e "Actual Loc\t\t Random word\t Stored Locs"
	for (( i = 1 ; i < ${#_dataArrayWordIndex[@]} ; i = i+4 ))
	do
		echo -e "${_dataArrayWordIndex[$i+2]}\t ${_dataArrayWordIndex[$i]}\t ${_dataArrayWordIndex[$i+3]}"
	done
}

#Parameters
#1 Remote Server IP
#2 Remote Install dir
function GetData
{
	#remove peer file from remote machine if it already exists
	runCommand="rm $2$_fileName"
	$_sshScript $remoteMachine $remoteUser $password "$runCommand"

	local returned=$(expect -c "
	spawn telnet $remoteMachine $_defaultPort
	match_max 100000
	expect \"*TMCI>*\"
	send -- \"STOREFILEA\r\"
	send -- \"QUIT\r\"
	expect eof
	")
	#echo $returned

	rm $_defaultSaveDir$_fileName
	$_scpScriptCopyFrom $remoteMachine $remoteUser $password $remoteInstallDir$_fileName "$_defaultSaveDir"
	
	local loc=$(sed q $_defaultSaveDir$_fileName)
	#echo $loc
	while read line
	do
		local chk=$(echo $line | cut -d'@' -f4 | cut -d':' -f1)
		
		for (( i = 1 ; i < ${#_dataArrayWordIndex[@]} ; i = i+4 ))
		do
			if [ "${_dataArrayWordIndex[$i+1]}" = "$chk" ]
			then
				_dataArrayWordIndex[$i+3]="${_dataArrayWordIndex[$i+3]} $loc"				
			fi
		done

	done < <(cat $_defaultSaveDir$_fileName | grep "freenet.keys.NodeCHK")

	rm $_defaultSaveDir$_fileName
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
declare saveDir

ParameterScriptWelcome "mapFreenetData.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterScriptWelcomeEnd
#===================================================================================================

unset _dataArrayWordIndex
readMasterList

exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)
       
	echo $remoteMachine
	GetData $remoteMachine $remoteInstallDir
done
exec 0<&3

printMasterList

echo "********** Complete ***************"
