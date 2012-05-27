#!/bin/bash

# Variables
_telS=../Scripts/common/telnet.exp

_simJars="bin/*"
_defaultSaveDir=~/Desktop/Sim/rti_params/
_masterCVS="$_defaultSaveDir/_masterRTIanalysis.cvs"
_defaultRunDir=/tmp/freenetSim/
_machineName="localhost"
_defaultPort=5200

_rtiExDir=~/FreeNet-Analysis/eclipse_workspace/Freenet-RoutePrediction/bin

_startNodeCount=25
_endNodeCount=250
_stepNodeCount=25

_startPeerCount=4
_endPeerCount=20
_stepPeerCount=2

_startHTL=4
_endHTL=14
_stepHTL=2


#Parameters
#1 Node Count
#2 Peer Count
#3 HTL
#4 Output File Name
function mergeMaster
{
	local i="0"
	while read line
	do
		let "i=$i+1"
		[ $i -eq 1 ] && continue
		[ "$line" == "" ] && continue
		echo "$1,$2,$3,$line" >> "$_masterCVS"
	done < "$4"
}


#Parameters
#1 Node Count
#2 Peer Count
#3 HTL
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
	GetTopologyGraph "$_telS" "$_machineName" "$_defaultPort" "$_defaultSaveDir/$1-$2-top.dot" || reportErrorExit "Unable to get topology"

	# Stop the simulation environment
	StopSimulation "$_telS" "$_machineName" "$_defaultPort" || reportErrorExit "Unable to close simulation environment"
}


#Parameters
#1 Node Count
#2 Peer Count
function iterateHTLCount
{
	local i=$_startHTL
	while [ $i -le $_endHTL ] 
	do
		echo "Topology- node count: $1, peer count: $2, HTL: $i"

		# Analyse the resulting topology
		java -Xms100m -Xmx2048m -XX:-UseGCOverheadLimit -cp "./bin/RTIEval.jar" frp.main.rti.analysis.RTIAnalysis -t "$_defaultSaveDir/$1-$2-top.dot" -o "$_defaultSaveDir/$1-$2-$i-output" -htl "$i" -dhtl 0

		mergeMaster $1 $2 $i "$_defaultSaveDir/$1-$2-$i-output"

		let "i=$i+$_stepHTL"
	done
}


#Parameters
#1 Node Count
function iteratePeerCount
{
	local i=$_startPeerCount
	while [ $i -le $_endPeerCount ] 
	do
		generateTopology $1 $i $_startHTL
		iterateHTLCount $1 $i
		let "i=$i+$_stepPeerCount"
	done
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

ParameterScriptWelcome "rti_parameters.sh"
ParameterScriptWelcomeEnd
#===================================================================================================

# initial clean up
rm -rf "$_defaultSaveDir"
mkdir -p "$_defaultSaveDir"
mkdir -p "$_defaultRunDir"

echo "Node Count,Peer Count,HTL,Subset Size/Total Node Count,Subset Size,# Min Targets,# Max Targets,Runtime (ms),Min Attack Node Set,Max Attack Node Set" > "$_masterCVS"

iterateNodeCount

echo "Completed"


