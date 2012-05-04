#!/bin/bash

# Variables
_prompt="SIM>"
_successValue="SUCCESS"
_status="STATUS:"

#Parameters
#1 returned message to evaluate
function Success
{
	#echo $1
	if [[ "$1" == *"$_successValue"* ]]; then
		return 0
	fi
	return 1
}

#Parameters
#1 Process ID
function CheckIfRunning
{
	# check if it started
	sleep 2
	if ! kill -0 $1 > /dev/null 2>&1; then
		#echo "not running"
		return 1
	fi
	#echo "running"
	return 0
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
function StopSimulation
{
	#echo "Stopping simulator..."
	local returned=$($1 "$2" "$3" "$_prompt" "SHUTDOWN" | grep "$_status")
	sleep 2
	Success "$returned"
	return $?
}


#Parameters
#1 Jar location of simulator
#2 Port
#3 Directory to save run data
function StartSimulation
{
	#echo "storing $3console.dump"
	mkdir -p "$3"
	java -cp "$1" freenet.testbed.Simulator "$2" "$3/data" >& "$3/console.dump" 2>&1 &
	CheckIfRunning $!
	return $?
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 Node count
#5 Peer count
#6 HTL
function CreateNetwork
{
	local returned=$($1 "$2" "$3" "$_prompt" "START $4 $5 $6" | grep "$_status")
	Success "$returned"
	return $?
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 Node count
#5 Peer count
#6 HTL
#7 Network State
function RestoreNetwork
{
	local returned=$($1 "$2" "$3" "$_prompt" "RESTORE $4 $5 $6 $7" | grep "$_status")
	Success "$returned"
	return $?
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 RETURN: Network state
function GetNetworkState
{
	local _variable=$4
	local returned=$($1 "$2" "$3" "$_prompt" "NETWORKSTATE" | grep "STATE:")

	local networkState=$(echo $returned | cut -d':' -f2)
	#echo "Setting State $networkState"
	eval $_variable="'$networkState'"
	
	[ "$networkState" == "" ] && return 1 || return 0
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 Storage File
function GetTopologyGraph
{
	rm -f $4
	$1 "$2" "$3" "$_prompt" "TOPOLOGY" > "$4.tmp"
	
	# check status
	local returned=$(cat "$4.tmp" | grep "$_status")
	Success "$returned"
	if [ $? -ne 0 ]
	then	
		rm -f "$4.tmp"
		return 1
	fi
	
	# get the topology only data
	sort "$4.tmp" | grep -P "\t" > "$4.srt"

	echo "digraph G {" > "$4"
	#echo "node [fontsize=24]" >> "$4"
	echo "overlap=\"scale\"" >> "$4"

	cat "$4.srt" >> "$4"

	echo "}" >> "$4"

	rm -f "$4.tmp"
	rm -f "$4.srt"

	return 0
}


