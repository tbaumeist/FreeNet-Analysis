
About Freenet Testbed Management Scripts
----------------------------------------

Author: Todd Baumeister
Date: May 2011
===============================================================================

General Script Notes
--------------------

All of the scripts described here can be run without supplying any parameters. 
The scripts will prompt the user for any needed information, or they will use a 
default value. The default values used are specified for each of the scripts 
below.

The configuration file parameter that can be found in all of the scripts 
specifies a file location. This file has all of the machine configuration 
settings for the Freenet nodes in the testbed. Detailed information on the 
configuration file can be found below in the "Configuration File" section.

Addition high level descriptions of the Freenet testbed maintenance scripts 
can be found in the document "Freenet Testbed Setup". Examples of these scripts 
being used can be found in the document "Freenet: Setup Experiments on the 
Testbed".

Definitions
-----------

Testbed Machine - This is a VM running in our testbed. It is used to emulate a 
physical machine that a typical Freenet user would have. The testbed machine is 
used to run the Freenet software.

Freenet Node - This is an instance of the Freenet software running on a testbed 
machine. Each of the Freenet nodes connected together form a Freenet network. 

===============================================================================

Folders
-------

./common - Contains sub scripts that are called from the four main testbed
		maintenance scripts.
./config - Contains testbed machine configurations
./logging - Contains data logging related scripts
./server - Contains scripts related to setting up the VM servers

===============================================================================

Scripts
-------

Clean
*****

File: clean.sh
Parameters:
	[Optional] Configuration File (Default: ./config/remoteMachines.dat)
	[Optional] Password (prompt user if not given)
Purpose:
This script will clean all of the Freenet node run data. After the script has 
completed running the nodes will be in a state like they were just freshly 
installed and never been run yet. This script can be used between experiment 
iterations when old experiment data needs to be purged.

Update
******

File: update.sh
Parameters:
	[Optional] Configuration File (Default: ./config/remoteMachines.dat)
	[Optional] Password (prompt user if not given)
Purpose:
The update script is used to push any changed files out to all of the Freenet 
nodes. This script will also reset the testbed to an initial state. The script 
performs several steps to accomplish this. First, the clean script is called. 
Next, the update script calls the assign locations script to assign each 
Freenet node with a random address (distributed hash location). The update 
script will then copy any files located in the "master folder" to the "Freenet 
install folder" on the testbed machines (see the Configuration File section 
for "* folder" definitions).

Run
***

File: runRemote.sh
Parameters:
	[Optional] Configuration File (Default: ./config/remoteMachines.dat)
	[Optional] Password (prompt user if not given)
	[Prompt] Start Freenet nodes (s) / Stop Freenet nodes (x)
Purpose:
The run script will start and stop the Freenet nodes on the testbed machines. 
This script also serves a second purpose of starting the data logging process. 
The data logging process will collect log files from all of the Freenet nodes, 
merge their data, and processes that data.

Network Topology
****************

File: networkTopology.sh
Parameters:
	[Optional] Configuration File (Default: ./config/remoteMachines.dat)
	[Optional] Password (prompt user if not given)
	[Optional] Save location (Default: 
			~/Desktop/Freenet_Data/Network_Topology/)
Purpose:
The network topology script will take a snapshot of the current network 
topology in the Freenet testbed. This script can be run at any time when the 
Freenet nodes are running. 

===============================================================================

Configuration File
------------------

File: (typically) ./config/remotemachines.dat
Purpose:
The configuration file is used by all of the Freenet maintenance scripts. This
file contains all of the testbed machine information that is needed by the 
scripts to run.

Format
******
IP,Node Type,User,Freenet Install Folder, Master Folder
IP,Node Type,User,Freenet Install Folder, Master Folder
IP,Node Type,User,Freenet Install Folder, Master Folder
IP,Node Type,User,Freenet Install Folder, Master Folder
IP,Node Type,User,Freenet Install Folder, Master Folder
...
...


IP - 	The IP address of the testbed machine.

Node Type - 	The type of Freenet node running on the testbed machine. Either SEED
	(a seed node) or NODE (regulare Freenet node).

User - 	The user name on the testbed machine that Freenet is running as.

Freenet Install Folder - The folder on the testbed machine where Freenet is installed.

Master Folder - The folder on the machine running the script that is used to push
	files out to testbed machines. Any files in the master folder will be copied
	to the testbed machines Freenet install folder when the update script is run.


===============================================================================

References
----------

Freenet Testbed Setup - "https://github.com/tbaumeist/FreeNet-Analysis/blob/
master/Documents/FreeNetTestBedSetup.pdf"

Freenet: Setup Experiments on the Testbed - "https://github.com/tbaumeist/
FreeNet-Analysis/blob/master/Documents/FreenetSetupExperimentsontheTestbed.pdf"


