#!/bin/bash

# Variables
_insertRandomWord=./insertRandomData.sh
_wordInserted="_randomFreenetWords.dat"
_telnetPort=8887
_defaultPort=2323


#Parameters
function reset
{
	local returned=$(expect -c "
		spawn telnet localhost $_telnetPort
		match_max 100000
		send -- \"reset\r\"
		expect eof
		send -- \"close\r\"
		")
}

#Parameters
#1 lock value
function setControlLock
{
	local returned=$(expect -c "
		spawn telnet localhost $_telnetPort
		match_max 100000
		send -- \"InsertAttackLock:$1\r\"
		expect eof
		send -- \"close\r\"
		")
}

#Parameters
#1 Variable to write to
function getControlLock
{
	local _variable=$1
	local value
	local returned=$(expect -c "
		spawn telnet localhost $_telnetPort
		match_max 100000
		send -- \"InsertAttackLock\r\"
		expect eof
		send -- \"close\r\"
		" | grep "status:")
	value=$(echo $returned | cut -d':' -f2)
	value=$(echo $value | sed -e 's/\r//g')
	eval $_variable="'$value'"
}


#Parameters
#1 Attack monitor host name
#2 Attack Cloud host name
function turnOnMonitorNode
{
	local returned=$(expect -c "
		spawn telnet $1 $_defaultPort
		match_max 100000
		expect \"*CMD>*\"
		send -- \"ATTACKAGENT:$2\r\"
		expect \"*CMD>*\"
		send -- \"ATTACKAGENTINSERTFILTER:true\r\"
		expect \"*CMD>*\"
		send -- \"QUIT\r\"
		expect eof
		")
}


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Count
# 3 Save Directory

source ./common/parameters.sh

declare configFile
declare randomCount
declare saveDir
declare attackMonitorHost
declare attackCloudHost

ParameterScriptWelcome "attackInsertTraceBack.sh"
ParameterConfigurationFile configFile $1
ParameterRandomCount randomCount "How many random words to insert? " $2
ParameterEnterHost attackMonitorHost "Enter host name for the monitor node: " $3
ParameterEnterHost attackCloudHost "Enter host name for node used to perform actual attack [attack cloud]: " $4
ParameterSaveDirectoryGeneral saveDir $5
ParameterScriptWelcomeEnd
#===================================================================================================

# check if debug server running
echo -n "Checking Debug Server Running: "
if nc -zv -w30 localhost $_telnetPort <<< ” &> /dev/null
then
	echo "OK"
else
	echo "FAILED"
	echo "***************************************************************"
	echo "Please start the debug server with the ./../runRemote.sh script"
	echo "***************************************************************"
	exit
fi

echo "Activating monitor node $attackMonitorHost to use $attackCloudHost as its attack node..."
turnOnMonitorNode $attackMonitorHost $attackCloudHost

fileName=$saveDir"insert-attack $(date --rfc-3339=seconds).dat"
fileName=$(echo $fileName | sed -e 's/ /_/g' -e 's/:/\-/g')
echo "Creating file $fileName"
mkdir -p $saveDir

#reset the list of inserted random words
rm "$saveDir$_wordInserted"

#Number of lines in $configFile
lineCount=`awk 'NF!=0 {++c} END {print c}' $configFile`

# set control lock
setControlLock "true"

for i in `seq $randomCount`
do
	#Wait for the attacker to give us the go ahead
	echo -n "Checking if can start : ."
	declare status
	getControlLock status
	waitCount=0
	while [ "$status" != "true" ]
	do
		echo -n "."
		sleep 20
		getControlLock status
		if [ $waitCount -ge 3 ]
		then
			break
		fi
		let "waitCount += 1"
	done
	echo ""
	echo "Starting..."
	

	rnum=$((RANDOM%$lineCount+1))
	line=$(sed -n "$rnum p" $configFile)
	
	remoteMachine=$(echo $line | cut -d',' -f1)

	# reset the debug server
	reset

	# insert the random word
	$_insertRandomWord 1 $remoteMachine   

	sleep 3 #sleep x seconds

	returned=$(expect -c "
		spawn telnet localhost $_telnetPort
		match_max 100000
		send -- \"PrintChks\r\"
		expect eof
		send -- \"close\r\"
		" | grep "|")
	echo $returned

	# Save origin, CHK, UIDS, and nodes with UIDs
	echo "Saving insert information..."
	echo "$remoteMachine|$returned" >> $fileName

	sleep 5 #sleep x seconds

	# Give the attacker node the go ahead
	echo "Flagging node to begin attack..."
	setControlLock "false"
done
echo "********** Attack Complete ***************"
