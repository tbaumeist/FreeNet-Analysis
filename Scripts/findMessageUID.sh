#!/bin/bash

# Variables
_defaultPort=2323

#Parameters
#1 Remote Server IP
#2 UID filter
function GetData
{
	local returned=$(expect -c "
	spawn telnet $1 $_defaultPort
	match_max 100000
	expect \"*TMCI>*\"
	send -- \"PRINTMESSAGEUIDS\r\"
	send -- \"QUIT\r\"
	expect eof
	" | grep $2)
	if [[ -n "$returned" ]]
	then
		echo -e "\t$1 \t$returned"
	fi
}


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password

source ./common/parameters.sh

declare configFile

ParameterScriptWelcome "findMessageUID.sh"
ParameterConfigurationFile configFile $1
ParameterScriptWelcomeEnd
#===================================================================================================

# ask for count
echo -n "Enter message UID:"
read messageUID
echo ""

echo "********** Starting Search ***************"
exec 3<&0
exec 0<$configFile
while read line
do
	remoteMachine=$(echo $line | cut -d',' -f1)
	remoteType=$(echo $line | cut -d',' -f2)
	remoteUser=$(echo $line | cut -d',' -f3)
	remoteInstallDir=$(echo $line | cut -d',' -f4)

	messageUID=$(echo $messageUID | sed -e 's/-/\\-/g' )

	GetData $remoteMachine $messageUID
done
exec 0<&3

echo "********** Complete ***************"
