#!/bin/bash

# Variables
_scriptDir=`dirname ${BASH_SOURCE[0]}`
_userDir=$(pwd)
_telS=$_scriptDir../common/telnet.exp

_simJars="$_scriptDir/../../bin/*"
_defaultrunDir="/tmp/freenet_simulation/"
_machineName="localhost"
_defaultPort=4600


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Port to use for simulator
# 2 Directory to store run files

#source
source $_scriptDir/simulationControl.sh
source $_scriptDir/simulatedNodeControl.sh
source $_scriptDir/../common/parameters.sh

declare port
declare runDir
declare mode

ParameterScriptWelcome "test_simulator.sh"
ParameterRandomQuestion port "Simulator port? Default:[$_defaultPort]" "$_defaultPort" $1
ParameterRandomQuestion runDir "Directory to save run data? Default:[$_defaultrunDir]" "$_defaultrunDir" $2
ParameterRandomQuestion mode "Test mode? Quick[q], Full[f]. Default:[q]" "q" $3
ParameterScriptWelcomeEnd
#===================================================================================================

# initial clean up
rm -rf "$runDir"


declare tmpPort
declare tmpLoc
declare tmpKey

echo "::Simple Control Tests::"

# No connection
StopSimulation "$_telS" "$_machineName" "$port" && echo "FAILED: No connection" || echo "PASSED: No connection"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/console0.dat" "$runDir/prot0.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Shutdown
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Shutdown" || echo "FAILED: Shutdown"


#########################################################################################
#########################################################################################

echo "::Small Network- All Functions::"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/console1.dat" "$runDir/prot1.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Start second simulation environment same port
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/console2.dat" "$runDir/prot2.trac" && echo "FAILED: Don't Start Second Simulation" || echo "PASSED: Don't Start Second Simulation"

# Get the network state no network
declare stateNo
GetNetworkState "$_telS" "$_machineName" "$port" stateNo && echo "FAILED: Get network state no network" || echo "PASSED: Get network state no network"
#echo "State No network: $stateNo"

# Get the topology no network
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/topno.dat" && echo "FAILED: Get topology no network" || echo "PASSED: Get topology no network"

# Get the stored data no network
GetStoredData "$_telS" "$_machineName" "$port" "$runDir/datno.dat" && echo "FAILED: Get stored data no network" || echo "PASSED: Get stored data no network"

# Get node info no network
GetNodeInfo "$_telS" "$_machineName" "$port" && echo "FAILED: Get node information no network" || echo "PASSED: Get node information no network"

# Check node info is empty
[ ${#_sim_control_node_ids[@]} -eq 0 ] && echo "PASSED: Node info check" || echo "FAILED: Node info check"
[ ${#_sim_control_node_TMCI[@]} -eq 0 ] && echo "PASSED: Node info check" || echo "FAILED: Node info check"

# Put data no network
let "tmpPort=$port+3"
PutData "$_telS" "$_machineName" "$tmpPort" "5" "Test data dude" tmpKey tmpLoc && echo "FAILED: Put data no network" || echo "PASSED: Put data no network"

# check Put Data return values
[ "$tmpKey" == "" ] && echo "PASSED: Check put data" || echo "FAILED: Check put data"
[ "$tmpLoc" == "" ] && echo "PASSED: Check put data" || echo "FAILED: Check put data"

# Get data no network
GetData "$_telS" "$_machineName" "$tmpPort" "notarealkey" && echo "FAILED: Get data no network" || echo "PASSED: Get  data no network"


##########################################################################################
##########################################################################################

# Create small network, 10 nodes, 5 peers, 4 HTL
CreateNetwork "$_telS" "$_machineName" "$port" "10" "5" "4" && echo "PASSED: Created small network" || echo "FAILED: Created small network"

# Get the network state
declare stateOne
GetNetworkState "$_telS" "$_machineName" "$port" stateOne && echo "PASSED: Get network state" || echo "FAILED: Get network state"
#echo "StateOne: $stateOne"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top1.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Get the stored data
GetStoredData "$_telS" "$_machineName" "$port" "$runDir/data1.dat" && echo "PASSED: Get Stored Data" || echo "FAILED: Get Stored Data"

# Get node info
GetNodeInfo "$_telS" "$_machineName" "$port" && echo "PASSED: Get node information" || echo "FAILED: Get node information"

# Check node info is not empty
[ ${#_sim_control_node_ids[@]} -eq 10 ] && echo "PASSED: Node info check" || echo "FAILED: Node info check"
[ ${#_sim_control_node_TMCI[@]} -eq 10 ] && echo "PASSED: Node info check" || echo "FAILED: Node info check"

# Put data
tmpPort=${_sim_control_node_TMCI[1]}
PutData "$_telS" "$_machineName" "$tmpPort" "5" "Test data dude" tmpKey tmpLoc && echo "PASSED: Put data" || echo "FAILED: Put data"

# check Put Data return values
[ "$tmpKey" == "" ] && echo "FAILED: Check put data" || echo "PASSED: Check put data"
[ "$tmpLoc" == "" ] && echo "FAILED: Check put data" || echo "PASSED: Check put data"
#echo "key=$tmpKey"
#echo "loc=$tmpLoc"

# Get data fake key
tmpPort=${_sim_control_node_TMCI[2]}
GetData "$_telS" "$_machineName" "$tmpPort" "CHK@jdMUOYBNGwOth~PF3O3bnbnA9SE9AeR3ApuWvrtUwgE,2IpwxlSbRF3n8Ola8SJBgiP7Pgd-Ja2xaz6~SE01zdY,AAIA--8" && echo "FAILED: Get data fake key" || echo "PASSED: Get data fake key"

# Get data real key
GetData "$_telS" "$_machineName" "$tmpPort" "$tmpKey" && echo "PASSED: Get data" || echo "FAILED: Get data"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"

# Exit if running quick tests
[ "$mode" == "q" ] && exit



##########################################################################################
##########################################################################################



echo "::Small Network- Restore::"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/console3.dat" "$runDir/prot3.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

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



##########################################################################################
##########################################################################################



echo "::Medium Network Topology Only::"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/consoleMedTop.dat" "$runDir/protMedTop.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

# Start medium network, 50 nodes, 8 peers, 4 HTL
CreateTopologyOnly "$_telS" "$_machineName" "$port" "50" "8" "4" && echo "PASSED: Topology only medium network" || echo "FAILED: Topology only medium network"

# Get the topology
GetTopologyGraph "$_telS" "$_machineName" "$port" "$runDir/top3top.dat" && echo "PASSED: Get topology" || echo "FAILED: Get topology"

# Check topologies do not match
diff "$runDir/top1.dat" "$runDir/top3top.dat" >/dev/null && echo "FAILED: Topologies do not match" || echo "PASSED: Topologies do not match"

# Stop the simulation environment
StopSimulation "$_telS" "$_machineName" "$port" && echo "PASSED: Stop Simulation" || echo "FAILED: Stop Simulation"



##########################################################################################
##########################################################################################



echo "::Medium Network::"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/consoleMed.dat" "$runDir/protMed.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

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



##########################################################################################
##########################################################################################



echo "::Large Network::"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/consoleLarge.dat" "$runDir/protLarge.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

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



##########################################################################################
##########################################################################################



echo "::Very Large Network::"

# Start the simulation environment
StartSimulation "$_simJars" "$port" "$runDir" "$runDir/consoleVeryLarge.dat" "$runDir/protVeryLarge.trac" && echo "PASSED: Start Simulation" || echo "FAILED: Start Simulation"

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

