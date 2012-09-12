#!/bin/bash

# Variables
_prompt_sim="SIM>"
_success_value_sim="SUCCESS"
_status_sim="STATUS:"

source ./common/depCheck.sh

function HelpControl
{
	echo "Simulation Control Script Commands- Command: Parameters"
	echo -e "\tStopSimulation: telnet_script machine_ip port"
	echo -e "\tStartSimulation: Jar_location_of_simulator Port [Directory_to_save_run_data] [Console_output_file] [Protocol_trace_file]"
	echo -e "\tCreateNetwork: telnet_script machine_ip port Node_count Peer_count HTL"
	echo -e "\tRestoreNetwork: telnet_script machine_ip port Node_count Peer_count HTL Network_state"
	echo -e "\tCreateTopologyOnly: telnet_script machine_ip port Node_count Peer_count HTL"
	echo -e "\tGetNetworkState: telnet_script machine_ip port out_network_state"
	echo -e "\tGetTopologyGraph: telnet_script machine_ip port storage_file"
	echo -e "\tGetStoredData: telnet_script machine_ip port storage_file"
	echo -e "\tGetNodeInfo: telnet_script machine_ip port {Output stored in _sim_control_node_ids and _sim_control_node_TMCI"
	echo -e "\tPrintNodeIds"
	echo -e "\tPrintNodePorts"
	echo -e "\RoutePredictionExperimentStart: telnet_script machine_ip port number_of_inserts_per_node file_name"
	echo -e "\RoutePredictionExperimentDone: telnet_script machine_ip port"
}

#Parameters
#1 returned message to evaluate
function Success
{
	#echo $1
	if [[ "$1" == *"$_success_value_sim"* ]]; then
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
	local returned=$($1 "$2" "$3" "$_prompt_sim" "SHUTDOWN" | grep "$_status_sim")
	
	Success "$returned"
	if [ $? -ne 0 ]
	then	
		return 1
	fi

	# issues shutdown command, can continue as soon as the port has been freed
	local portCheck=`lsof -iTCP:$3`

	while [ "$portCheck" != "" ]
	do
		# Port still being used
		#echo "sleeping.."
		sleep 1
		portCheck=`lsof -iTCP:$3`
	done

	return 0
}


#Parameters
#1 Jar location of simulator
#2 Port
#3 Directory to save run data
#4 Console output file
#5 Protocol trace file
function StartSimulation
{
	#echo "storing $3console.dump"
	mkdir -p "$3"
	java -cp "$1" freenet.testbed.Simulator "$2" "$3/data" "$5" >& "$4" 2>&1 &
	_current_pid_sim=$!
	CheckIfRunning $_current_pid_sim
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
	local returned=$($1 "$2" "$3" "$_prompt_sim" "START $4 $5 $6" | grep "$_status_sim")
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
	local returned=$($1 "$2" "$3" "$_prompt_sim" "RESTORE $4 $5 $6 $7" | grep "$_status_sim")
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
function CreateTopologyOnly
{
	local returned=$($1 "$2" "$3" "$_prompt_sim" "TOPOLOGYONLY $4 $5 $6" | grep "$_status_sim")
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
	eval $_variable="''"
	local returned=$($1 "$2" "$3" "$_prompt_sim" "NETWORKSTATE" | grep "STATE:")

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
	$1 "$2" "$3" "$_prompt_sim" "TOPOLOGY" > "$4.tmp"
	
	# check status
	local returned=$(cat "$4.tmp" | grep "$_status_sim")
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
	#echo "overlap=\"scale\"" >> "$4"

	cat "$4.srt" >> "$4"

	echo "}" >> "$4"

	rm -f "$4.tmp"
	rm -f "$4.srt"

	return 0
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 Storage File
function GetStoredData
{
	rm -f $4
	$1 "$2" "$3" "$_prompt_sim" "LISTSTOREDDATA" > "$4.tmp"
	
	# check status
	local returned=$(cat "$4.tmp" | grep "$_status_sim")
	Success "$returned"
	if [ $? -ne 0 ]
	then	
		rm -f "$4.tmp"
		return 1
	fi
	
	# get the stored location only data
	cat "$4.tmp" | grep -P "\t" > "$4"

	rm -f "$4.tmp"

	return 0
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
declare -a _sim_control_node_ids
declare -a _sim_control_node_TMCI
function GetNodeInfo
{
	unset _sim_control_node_ids
	unset _sim_control_node_TMCI

	local tmp=/tmp/freenet_sim_output_GetNodeInfo
	rm -f $tmp
	$1 "$2" "$3" "$_prompt_sim" "LISTNODES" > "$tmp"
	
	# check status
	local returned=$(cat "$tmp" | grep "$_status_sim")
	Success "$returned"
	if [ $? -ne 0 ]
	then	
		return 1
	fi
	
	# get the topology only data
	cat "$tmp" | grep -P "\t" > "$tmp.tmp"

	local index=1
	while read line
	do
		_sim_control_node_ids[$index]=$(echo $line | cut -d':' -f1)
		_sim_control_node_TMCI[$index]=$(echo $line | cut -d':' -f2)
		let "index += 1"
	done < "$tmp.tmp"

	rm -f "$tmp"
	rm -f "$tmp.tmp"

	return 0
}

function PrintNodeIds
{
	echo ${_sim_control_node_ids[@]}
}

function PrintNodePorts
{
	echo ${_sim_control_node_TMCI[@]}
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 number of inserts per node
#5 save to file name
function RoutePredictionExperimentStart
{
	rm -f $5

	local returned=$($1 "$2" "$3" "$_prompt_sim" "EXPERIMENT:ROUTEPREDSTART $4 $5" | grep "$_status_sim")
	Success "$returned"
	return $?
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
function RoutePredictionExperimentDone
{
	rm -f $5

	local returned=$($1 "$2" "$3" "$_prompt_sim" "EXPERIMENT:ROUTEPREDDONE" | grep "$_status_sim")
	Success "$returned"
	return $?
}


