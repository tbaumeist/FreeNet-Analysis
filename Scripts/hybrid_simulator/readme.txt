This document describes how to use the Freenet simulator.
-----------------------------------------------------------------------

See the file test_simulator.sh for an example on how to script
simulation executions.

-----------------------------------------------------------------------
Overview
-----------------------------------------------------------------------
The Freenet simulator is designed to run a large number of nodes in
a single process. Each node started will be spawned in a seperate
thread under the same process. Each node will be assigned a unique
port number that it can use to communicate with.

Currently the simulation is designed to only communicate with the nodes
in the same process. 

The largest network size that has been tested and worked successfully
is 200 nodes.

-----------------------------------------------------------------------
Locations:
-----------------------------------------------------------------------
	FreeNet-Analysis/Simulation
	FreeNet-Analysis/Simulation/common
	FreeNet-Analysis/Simulation/bin

-----------------------------------------------------------------------
FreeNet-Analysis/Simulation
-----------------------------------------------------------------------
This directory contains all of the scripts for performing specific 
simulation tasks. This is were custom scripts will be placed.

	test_simulator.sh
This script can be used to test that the simulation environment is
capable of performing the basic operations. This script can also
be used as an example script to see how to script a simulation 
execution.

-----------------------------------------------------------------------
FreeNet-Analysis/Simulation/common
-----------------------------------------------------------------------
Any common script files will be placed in this directory.

	SimulationControl.sh
This script has all of the functions for controlling the simulation
environment.

-----------------------------------------------------------------------
FreeNet-Analysis/Simulation/bin
-----------------------------------------------------------------------
This directory contains all of the executables and libraries needed
to run the simulation environment.
