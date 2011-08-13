#!/bin/bash

# Variables
_insertRandomWord=./insertRandomData.sh
_wordInserted="_randomFreenetWords.dat"
_telnetPort=8887


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
		send -- \"RequestAttackLock:$1\r\"
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
		send -- \"RequestAttackLock\r\"
		expect eof
		send -- \"close\r\"
		" | grep "status:")
	value=$(echo $returned | cut -d':' -f2)
	value=$(echo $value | sed -e 's/\r//g')
	eval $_variable="'$value'"
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
declare randomInsertCount
declare randomRequestCount
declare saveDir

ParameterScriptWelcome "attackRequestTraceBack.sh"
ParameterConfigurationFile configFile $1
ParameterRandomCount randomInsertCount $2
ParameterRandomCount randomRequestCount $3
ParameterSaveDirectoryGeneral saveDir $4
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

fileName=$saveDir"request-attack $(date --rfc-3339=seconds).dat"
fileName=$(echo $fileName | sed -e 's/ /_/g' -e 's/:/\-/g')
echo "Creating file $fileName"
mkdir -p $saveDir

#reset the list of inserted random words
rm "$saveDir$_wordInserted"

#Number of lines in $configFile
lineCount=`awk 'NF!=0 {++c} END {print c}' $configFile`

# set control lock
setControlLock "true"

######################################################################
# Insert x random words from random points
for i in `seq $randomInsertCount`
do
	rnum=$((RANDOM%$lineCount+1))
	line=$(sed -n "$rnum p" $configFile)
	
	remoteMachine=$(echo $line | cut -d',' -f1)

	# insert the random word
	$_insertRandomWord 1 $remoteMachine   
done


######################################################################
# Request y random words from random points
for i in `seq $randomRequestCount`
do
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

	rnum=$((RANDOM%$lineCount+1))
	line=$(sed -n "$rnum p" $configFile)
	remoteMachine=$(echo $line | cut -d',' -f1)
	
	rnum=$((RANDOM%$randomInsertCount+1))
	line=$(sed -n "$rnum p" $saveDir$_wordInserted)
	insertedWord=$(echo $line |cut -d':' -f1)
	insertedChk=$(echo $line | cut -d':' -f2)
	insertedLoc=$(echo $line |cut -d':' -f3)

	# reset the debug server
	reset

	echo "Requesting $insertedWord : $insertedChk"
	# request the random word
	returned=$(expect -c "
		spawn telnet $remoteMachine 2323
		match_max 100000
		send -- \"get:$insertedChk\r\"
		expect eof
		send -- \"close\r\"
		" )

	sleep 10 #sleep x seconds

	returned=$(expect -c "
		spawn telnet localhost $_telnetPort
		match_max 100000
		send -- \"PrintChks\r\"
		expect eof
		send -- \"close\r\"
		" | grep "|")
	echo $returned

	# Save origin, CHK, UIDS, and nodes with UIDs
	echo "$remoteMachine|$returned" >> $fileName

	# Give the attacker node the go ahead
	setControlLock "false"
done
echo "********** Attack Complete ***************"
