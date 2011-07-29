#!/bin/bash

# Variables
_defaultPort=2323
_sshScript=./common/sshlogin.exp
_wordfile="/usr/share/dict/words"


#Parameters
#1 Remote Server IP
#2 Count
function InsertData
{
	#Number of lines in $_wordfile
	local tL=`awk 'NF!=0 {++c} END {print c}' $_wordfile`
	for i in `seq $2`
	do
		local rnum=$((RANDOM%$tL+1))
		local word=$(sed -n "$rnum p" $_wordfile)
		echo "Inserting: $word"
		expect -c "
		spawn telnet $1 $_defaultPort
		match_max 100000
		expect \"*TMCI>*\"
		send -- \"PUT:$word\r\"
		expect eof
		send -- \"QUIT\r\"
		interact timeout 30 return 
		" | egrep "URI:|Double:"
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
declate insertHost

ParameterScriptWelcome "insertRandomData.sh"
#ParameterConfigurationFile configFile $1
ParameterRandomCount randomCount $1
ParameterEnterHost insertHost $2
ParameterScriptWelcomeEnd
#===================================================================================================

InsertData $insertHost $randomCount

echo "********** Insert Complete ***************"
