#!/bin/bash

# Variables
_defaultPort=2323
_sshScript=./common/sshlogin.exp
_wordfile="/usr/share/dict/words"
_wordInserted="_randomFreenetWords.dat"
_telnetScript=./common/telnet.exp
_mapDataScript=./mapFreenetData.sh
_netTopology=./networkTopology.sh
_topCheckInterval=5


#Parameters
#1 Remote Server IP
#2 Count
#3 File
#4 MaxHTL
function InsertData
{
	#Number of lines in $_wordfile
	local tL=`awk 'NF!=0 {++c} END {print c}' $_wordfile`
	for i in `seq $2`
	do
		for k in `seq $4`
		do
			if [ $k -le 1 ]
			then
				continue
			fi
			local rnum=$((RANDOM%$tL+1))
			local word=$(sed -n "$rnum p" $_wordfile)
			echo "Inserting: $word, htl=$k"
			local returned=$($_telnetScript "$1" "$_defaultPort" "TMCI> " "PUTHTL:$k:$word" | egrep "URI:|Double:")
			echo $returned
		
			if [[ -n "$returned" ]]
			then
				local doctored=$(echo $returned | sed -e 's/URI//g' -e 's/Double//g' -e 's/\r//g')
				echo "$word $doctored : $1 : $k" >> $3
			fi
		done
	done
}

#Parameters
#1 count
function saveTopology
{
	#save topology
	$_netTopology $configFile $password "$saveDir" "top-$1.dot"
	let "prev=$1-$_topCheckInterval"
	if [ $prev -gt 0 ]
	then
		local dif=$(diff "$saveDir""top-$prev.dot" "$saveDir""top-$1.dot" | wc -m)
		if [ $dif -eq 0 ]
		then
			rm "$saveDir""top-$prev.dot"
			rm "$saveDir""top-$prev.dot.png"
		fi
	fi
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Number of random words to insert
# 2 Configuration file
# 3 password
# 4 Save directory
# 5 File to save inserted words in

source ./common/parameters.sh

declare configFile
declare password
declare randomCount
declare htlCount
declare saveDir
declare fileName

ParameterScriptWelcome "exp_routePrediction.sh"
ParameterRandomCount randomCount "How many random words to insert at each node? " $1
ParameterRandomCount htlCount "Max HTL? " $2
ParameterConfigurationFile configFile $3
ParameterPassword password $4
ParameterSaveDirectoryGeneral saveDir $5
ParameterFileName fileName $_wordInserted $6
ParameterScriptWelcomeEnd
#===================================================================================================

mkdir -p $saveDir

_topCheckInterval=$randomCount
totalWordCount=0

while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)

	let "totalWordCount=$totalWordCount + $randomCount"

	saveTopology $totalWordCount
	InsertData $remoteMachine $randomCount "$saveDir$fileName" $htlCount
	
done < "$configFile"

$_mapDataScript "$configFile" "$password" "$saveDir"

echo "********** Insert Complete ***************"
