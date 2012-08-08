#!/bin/bash

# Variables
_telS=../Scripts/common/telnet.exp

_simJars="bin/*"
_defaultSaveDir=~/Desktop/Sim/top_only/
_defaultRunDir=/tmp/freenetSim/
_machineName="localhost"
_defaultPort=5200

_firstRun=0

_rtiExDir=~/FreeNet-Analysis/eclipse_workspace/Freenet-RoutePrediction/bin

_startNodeCount=50
_endNodeCount=400
_stepNodeCount=5

_peersNear=2

_randomize=5

#Parameters
#1 Node Count
#2 Peer Count
#3 HTL
#4 Run Count
#5 Topology file
function processTopology
{
	# fix the topology file so gephi can read it
	neato -Tdot "$5" | sed -e 's/\t[0-9]*//g' > "$5.fixed.dot"

	# process the topology file
	local appFlag="-a true"
	if [ $_firstRun -eq 0 ] 
	then
		appFlag=""
		_firstRun=1
	fi 
	java -cp "bin/*" frp.gephi.rti.AttackNodeAnalysisSingle -t "$5.fixed.dot" -n $1 -p $2 -htl $3 -ds $4 $appFlag -o "$_defaultSaveDir/topologyStats.csv"
}

#Parameters
#1 Node Count
#2 Peer Count
#3 HTL
#4 Run Count
function generateTopology
{
	#echo "Topology- node count: $1, peer count: $2, HTL: $3"

	# Stop the simulation environment (recover from errors)
	StopSimulation "$_telS" "$_machineName" "$_defaultPort"

	# Start the simulation environment
	StartSimulation "$_simJars" "$_defaultPort" "$_defaultRunDir" "$_defaultRunDir/console.dat" "$_defaultRunDir/prot.trac" || reportErrorExit "Unable to start the simulation environment"

	# Create small network, 100 nodes, 5 peers, 5 HTL
	CreateTopologyOnly "$_telS" "$_machineName" "$_defaultPort" "$1" "$2" "$3" || reportErrorExit "Unable to create topology"

	# Get the topology
	GetTopologyGraph "$_telS" "$_machineName" "$_defaultPort" "$_defaultSaveDir/$1-$2-$3-$4-top.dot" || reportErrorExit "Unable to get topology"

	# Stop the simulation environment
	StopSimulation "$_telS" "$_machineName" "$_defaultPort" || reportErrorExit "Unable to close simulation environment"

	processTopology $1 $2 $3 $4 "$_defaultSaveDir/$1-$2-$3-$4-top.dot"
}

#Parameters
#1 Node Count
#2 Peer Count
#3 HTL
function iterateRandomized
{
	local i=0
	for (( i=1; i <=$_randomize; i++ ))
	do
		echo "Topology- node count: $1, peer count: $2, HTL: $3, Run:$i"

		generateTopology $1 $2 $3 $i

	done
}

#Parameters
#1 Node Count
#2 Peer Count
function iterateHTLCount
{
	local i=0
	for (( i=$2-$_peersNear; i<=$2+$_peersNear;i++ ))
	do
		[ $i -le 3 ] && continue
		iterateRandomized $1 $i $2
	done
}


#Parameters
#1 Node Count
function iteratePeerCount
{
	local log=$(echo "(l($1)/l(10))^2" | bc -l)
	local log_ceiling=$(echo "($log + 1)/1" | bc)
	#echo "Node $1 HTL = $log_ceiling"
	iterateHTLCount $1 $log_ceiling
}


#Parameters
function iterateNodeCount
{
	local i=$_startNodeCount
	while [ $i -le $_endNodeCount ] 
	do
		iteratePeerCount $i
		let "i=$i+$_stepNodeCount"
	done
}



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

ParameterScriptWelcome "generate_topologies_only.sh"
ParameterScriptWelcomeEnd
#===================================================================================================

# initial clean up
rm -rf "$_defaultSaveDir"
mkdir -p "$_defaultSaveDir"
mkdir -p "$_defaultRunDir"

iterateNodeCount

echo "Completed"


