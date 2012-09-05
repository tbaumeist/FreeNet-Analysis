#!/bin/bash

# Variables
_telS=../Scripts/common/telnet.exp
_simJars="bin/*"
_defaultRunDir=/tmp/freenetSim/
_machineName="localhost"
_defaultPort=5200

_stepNodeCount=25
_stepPeerCount=1
_stepHTL=1

_defaultrunDir=~/Desktop/route_prediction


#Parameters
#1 Merge File
#2 Master File
_firstMerge=0
function mergeMaster
{
	local i="0"
	while read line
	do
		let "i=$i+1"
		[ $i -eq 1 ] && [ $_firstMerge -ne 0 ] && continue
		[ "$line" == "" ] && continue
		_firstMerge=1
		echo "$line" >> "$2"
	done < "$1"
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

declare nodeCountStart
declare nodeCountEnd
declare peerCountPlusMinus
declare htlPlusMinus
declare insertsPerNode
declare runDir

ParameterScriptWelcome "route_prediction.sh"
ParameterRandomCount nodeCountStart "Node count to start with? " $1
ParameterRandomCount nodeCountEnd "Node count to end with? " $2
ParameterRandomCount peerCountPlusMinus "Peer count +/- range? " $3
ParameterRandomCount htlPlusMinus "HTL +/- range? " $4
ParameterRandomCount insertsPerNode "Number of unique words to insert per node? " $5
ParameterRandomQuestion runDir "Directory to save run data? Default:[$_defaultrunDir]" "$_defaultrunDir" $6
ParameterScriptWelcomeEnd
#===================================================================================================

fileNameBase="$runDir/route_pred"
csvMaster="$fileNameBase.csv"

# initial clean up
rm -rf "$runDir"
mkdir -p "$runDir"
mkdir -p "$_defaultRunDir" #tmp directory

[ -d $runDir ] || reportErrorExit "Unable to create the save directory!!"

nodeCount=0
for (( nodeCount=$nodeCountStart; nodeCount <=$nodeCountEnd; nodeCount=$nodeCount+$_stepNodeCount ))
do
	log=$(echo "(l($nodeCount)/l(10))^2" | bc -l)
	log_ceiling=$(echo "($log + 1)/1" | bc)

	peerCount=0
	for (( peerCount=$log_ceiling-$peerCountPlusMinus; peerCount <= $log_ceiling+$peerCountPlusMinus; peerCount=$peerCount+$_stepPeerCount ))
	do
		[ $peerCount -le 3 ] && continue
		
		htlCount=0
		for (( htlCount=$log_ceiling-$htlPlusMinus; htlCount <= $log_ceiling+$htlPlusMinus; htlCount=$htlCount+$_stepHTL ))
		do
			[ $htlCount -le 3 ] && continue

			currentFileNameBase=$fileNameBase-$nodeCount-$peerCount-$htlCount

			echo "Node count $nodeCount, Peer count $peerCount, HTL $htlCount"

			StartSimulation "$_simJars" "$_defaultPort" "$_defaultRunDir" "$_defaultRunDir/console.dump" "$_defaultRunDir/protocal.trace" || reportErrorExit "FAILED: Start Simulation"

			CreateNetwork "$_telS" "$_machineName" "$_defaultPort" "$nodeCount" "$peerCount" "$htlCount" || reportErrorExit "FAILED: Start medium network"

			GetTopologyGraph "$_telS" "$_machineName" "$_defaultPort" "$currentFileNameBase.dot" || reportErrorExit "FAILED: Get topology"

			RoutePredictionExperimentStart "$_telS" "$_machineName" "$_defaultPort" "$insertsPerNode" "$currentFileNameBase.csv" || reportErrorExit "FAILED: Running experiment"

			# wait for the experiment to finish running
			while [ true ]
			do
				RoutePredictionExperimentDone "$_telS" "$_machineName" "$_defaultPort" && break
				echo -e "\tWaiting for experiment..."
				sleep 30
			done			

			StopSimulation "$_telS" "$_machineName" "$_defaultPort" || reportErrorExit "FAILED: Stop Simulation"

			mergeMaster "$currentFileNameBase.csv" "$csvMaster"

			rm -f "$currentFileNameBase.csv"

		done
	done
done

echo "Completed"
