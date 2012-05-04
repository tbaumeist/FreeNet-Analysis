#!/bin/bash

# Variables
_telS=../Scripts/common/telnet.exp

_simJars="bin/*"
_defaultrunDir="/tmp/freenet_simulation/"
_machineName="127.0.0.1"
_defaultPort=5200


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Port to use for simulator
# 2 Directory to store run files

#source
source ./common/simulationControl.sh
source ../Scripts/common/parameters.sh

declare port
declare runDir

ParameterScriptWelcome "test_simulator.sh"
ParameterRandomQuestion port "Simulator port? Default:[5200] " "$_defaultPort" $1
ParameterRandomQuestion runDir "Directory to save run data? Default:[$_defaultrunDir] " "$_defaultrunDir" $2
ParameterScriptWelcomeEnd
#===================================================================================================

# No connection
StopSimulation "$_telS" "$_machineName" "$port" && echo "FAILED: No connection" || echo "PASSED: No connection"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Start second simulation environment same port
StartSimulation "$_simJars" "$port" "$runDir" && echo "FAILED: Don't Start Second Simulation" || echo "PASSED: Don't Start Second Simulation"

# Get the network state no network
declare stateNo
GetNetworkState "$_telS" "$_machineName" "$port" stateNo && echo "FAILED: Get network state no network" || echo "PASSED: Get network state no network"
#echo "State No network: $stateNo"

# Get the topology no network
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/topno.dat" && echo "FAILED: Get topology no network" || echo "PASSED: Get topology no network"

# Create small network, 10 nodes, 5 peers, 4 HTL
CreateNetwork "$_telS" "$_machineName" "$port" "10" "5" "4" && echo "PASSED: Created small network" || echo "FAILED: Created small network"

# Get the network state
declare stateOne
GetNetworkState "$_telS" "$_machineName" "$port" stateOne && echo "PASSED: Get network state" || echo "FAILED: Get network state"
#echo "StateOne: $stateOne"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top1.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"



# give time between shutdown and startup
echo "    cooling down..."
sleep 20



# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# restore small network, 10 nodes, 5 peers, 4 HTL
RestoreNetwork "$_telS" "$_machineName" "$port" "10" "5" "4" "$stateOne" && echo "PASSED: Restored small network" || echo "FAILED: Restored small network"

# Get the network state
declare stateTwo
GetNetworkState "$_telS" "$_machineName" "$port" stateTwo && echo "PASSED: Get network state" || echo "FAILED: Get network state"
#echo "StateTwo: $stateTwo"

# Check network states match
#echo "$stateOne equals $stateTwo"
[ "$stateOne" == "$stateTwo" ] && echo "PASSED: Same network state" || echo "FAILED: Same network state"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top2.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Check topologies match
diff "$runDir/top1.dat" "$runDir/top2.dat" >/dev/null && echo "PASSED: Topologies match" || echo "FAILED: Topologies match"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"



# give time between shutdown and startup
echo "    cooling down..."
sleep 20



# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Start medium network, 50 nodes, 8 peers, 4 HTL
CreateNetwork "$_telS" "$_machineName" "$port" "50" "8" "4" && echo "PASSED: Start medium network" || echo "FAILED: Start medium network"

# Get the network state
declare stateMedium
GetNetworkState "$_telS" "$_machineName" "$port" stateMedium && echo "PASSED: Get network state" || echo "FAILED: Get network state"
#echo "StateMedium: $stateMedium"

# Check network states do not match
[ "$stateOne" == "$stateMedium" ] && echo "FAILED: Different network state" || echo "PASSED: Different network state"
[ "$stateTwo" == "$stateMedium" ] && echo "FAILED: Different network state" || echo "PASSED: Different network state"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top3.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Check topologies do not match
diff "$runDir/top1.dat" "$runDir/top3.dat" >/dev/null && echo "FAILED: Topologies do not match" || echo "PASSED: Topologies do not match"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"



# give time between shutdown and startup
echo "    cooling down..."
sleep 20



# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Start large network, 100 nodes, 10 peers, 5 HTL
CreateNetwork "$_telS" "$_machineName" "$port" "100" "10" "5" && echo "PASSED: Start large network" || echo "FAILED: Start large network"

# Get the network state
declare stateLarge
GetNetworkState "$_telS" "$_machineName" "$port" stateLarge && echo "PASSED: Get network state" || echo "FAILED: Get network state"
#echo "StateLarge: $stateLarge"

# Check network states do not match
[ "$stateOne" == "$stateLarge" ] && echo "FAILED: Different network state" || echo "PASSED: Different network state"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top4.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Check topologies do not match
diff "$runDir/top1.dat" "$runDir/top4.dat" >/dev/null && echo "FAILED: Topologies do not match" || echo "PASSED: Topologies do not match"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"



# give time between shutdown and startup
echo "    cooling down..."
sleep 20



# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Start very large network, 200 nodes, 10 peers, 5 HTL
CreateNetwork "$_telS" "$_machineName" "$port" "200" "10" "5" && echo "PASSED: Start very large network" || echo "FAILED: Start very large network"

# Get the network state
declare stateVeryLarge
GetNetworkState "$_telS" "$_machineName" "$port" stateVeryLarge && echo "PASSED: Get network state" || echo "FAILED: Get network state"
#echo "StateVeryLarge: $stateVeryLarge"

# Check network states do not match
[ "$stateOne" == "$stateVeryLarge" ] && echo "FAILED: Different network state" || echo "PASSED: Different network state"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top5.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Check topologies do not match
diff "$runDir/top4.dat" "$runDir/top5.dat" >/dev/null && echo "FAILED: Topologies do not match" || echo "PASSED: Topologies do not match"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"

