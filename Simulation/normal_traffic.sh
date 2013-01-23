#!/bin/bash

# Variables
_telS=../Scripts/common/telnet.exp

_simJars="../bin/*"
_defaultrunDir=~/Desktop/Sim/normal_traffic
_machineName="localhost"
_defaultPort=5200

_htl=5
_peers=5
_nodeCount=50
_wordsPer=5


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Port to use for simulator
# 2 Directory to store run files

#source
source ./common/simulationControl.sh
source ./common/simulatedNodeControl.sh
source ../Scripts/common/parameters.sh

declare port
declare runDir

ParameterScriptWelcome "normal_traffic.sh"
ParameterRandomQuestion port "Simulator port? Default:[5200]" "$_defaultPort" $1
ParameterRandomQuestion runDir "Directory to save run data? Default:[$_defaultrunDir]" "$_defaultrunDir" $2
ParameterScriptWelcomeEnd
#===================================================================================================

_insertLog="$runDir/insert.log"

# initial clean up
rm -rf "$runDir"


# Start the simulation environment
echo "Starting simulation env.."
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/console.dat" "$runDir/prot.trac" || exit 1

# Create small network, 100 nodes, 5 peers, 5 HTL
echo "Creating new network..."
CreateNetwork "$_telS" "$_machineName" "$port" "$_nodeCount" "$_peers" "$_htl" || exit 1

# Get the network state
declare networkState
GetNetworkState "$_telS" "$_machineName" "$port" networkState || exit 1
echo "Network state: $networkState"

# Get the topology
echo "Getting topology..."
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/topBegin.dot" || exit 1

# Get node info
echo "Getting node information..."
GetNodeInfo "$_telS" "$_machineName" "$port" || exit 1

# Check node info is not empty
[ ${#_sim_control_node_ids[@]} -eq $_nodeCount ] || exit 1
[ ${#_sim_control_node_TMCI[@]} -eq $_nodeCount ] || exit 1

declare tmpPort
declare tmpKey
declare tmpLoc

for k in `seq $_wordsPer`
do 
	for i in `seq ${#_sim_control_node_TMCI[@]}`
	do
		# Put data
		tmpPort=${_sim_control_node_TMCI[$i]}
		PutData "$_telS" "$_machineName" "$tmpPort" "$_htl" "Test$i$k" tmpKey tmpLoc
		if [ $? -eq 0 ]
		then
			echo "Put $tmpPort:Test$i$k:$tmpLoc:$tmpKey"
			echo "$tmpPort:Test$i$k:$tmpLoc:$tmpKey" >> "$_insertLog"
		fi
	done
done

lineCount=`awk 'NF!=0 {++c} END {print c}' $_insertLog`
while read line
do
	key=$(echo $line | cut -d':' -f4)
	word=$(echo $line | cut -d':' -f2)
	rnum=$((RANDOM%$lineCount+1))
	tmpPort=${_sim_control_node_TMCI[$rnum]}

	echo "Getting $word..."
	GetData "$_telS" "$_machineName" "$tmpPort" "$key" || echo "Failed $tmpPort to get $key"

done < "$_insertLog"

# Get the topology
echo "Getting topology..."
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/topEnd.dot" || exit 1

# Stop the simulation environment
echo "Stopping simulation..."
StopSimulation "$_telS" "$_machineName" "$port" || exit 1

echo "Complete"


