#!/bin/bash

# Variables
_defaultPort=2323
_sshScript=./common/sshlogin.exp
_wordfile="/usr/share/dict/words"
_wordInserted="_randomFreenetWords.dat"


#Parameters
#1 Remote Server IP
#2 Count
#3 File
function InsertData
{
	#Number of lines in $_wordfile
	local tL=`awk 'NF!=0 {++c} END {print c}' $_wordfile`
	for i in `seq $2`
	do
		local rnum=$((RANDOM%$tL+1))
		local word=$(sed -n "$rnum p" $_wordfile)
		echo "Inserting: $word"
		local returned=$(expect -c "
		spawn telnet $1 $_defaultPort
		match_max 100000
		expect \"*TMCI>*\"
		send -- \"PUT:$word\r\"
		expect eof
		send -- \"QUIT\r\"
		interact timeout 30 return 
		" | egrep "URI:|Double:")
		echo $returned
		
		if [[ -n "$returned" ]]
		then
			local doctored=$(echo $returned | sed -e 's/URI//g' -e 's/Double//g' -e 's/\r//g')
			echo "$word $doctored" >> $3
		fi
	done
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Number of random words to insert
# 2 Host to perform the inserts

source ./common/parameters.sh

declare configFile
declare randomCount
declare insertHost
declare saveDir
declare fileName

ParameterScriptWelcome "insertRandomData.sh"
ParameterRandomCount randomCount "How many random words to insert? " $1
ParameterEnterHost insertHost "Enter host to perform insert from: " $2
ParameterSaveDirectoryGeneral saveDir $3
ParameterFileName fileName $_wordInserted $4
ParameterScriptWelcomeEnd
#===================================================================================================

InsertData $insertHost $randomCount "$saveDir$fileName"

echo "********** Insert Complete ***************"
