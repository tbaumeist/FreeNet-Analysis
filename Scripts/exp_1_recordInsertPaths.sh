#!/bin/bash

# Variables
_insertRandomWord=./insertRandomData.sh
_netTopology=./networkTopology.sh
_wordInserted="_exp_1_randomFreenetWords.dat"
_telnetPort=8887
_telnetScript=./common/telnet.exp


#Parameters
#1 Archive file name
function reset
{
	$_telnetScript "localhost" $_telnetPort "CMD>" "reset"
	$_telnetScript "localhost" $_telnetPort "CMD>" "archivechks $1"
}


#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Count
# 3 Save Directory

source ./common/parameters.sh

declare configFile
declare password
declare randomCount
declare saveDir
declare fileName
declare attackMonitorHost
declare attackCloudHost

defFileName="exp_1_recordInsertPaths $(date --rfc-3339=seconds).dat"
defFileName=$(echo $defFileName | sed -e 's/ /_/g' -e 's/:/\-/g')

ParameterScriptWelcome "exp_1_recordInsertPaths.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterRandomCount randomCount "How many random words to insert per node? " $3
ParameterSaveDirectoryGeneral saveDir $4
ParameterFileName fileName $defFileName $5
ParameterScriptWelcomeEnd
#===================================================================================================

# check if debug server running
echo -n "Checking Debug Server Running: "
if nc -zv -w30 localhost $_telnetPort <<< ” &> /dev/null
then
	echo "OK"
else
	echo "FAILED"
	echo "***************************************************************"
	echo "Please start the debug server with the ./runRemote.sh script"
	echo "***************************************************************"
	exit
fi

fullFileName=$saveDir$fileName
echo "Creating file $fullFileName"
mkdir -p $saveDir

archiveFile=$saveDir"archive.dat"

#reset the list of inserted random words
rm "$saveDir$_wordInserted"

#Number of lines in $configFile
lineCount=`awk 'NF!=0 {++c} END {print c}' $configFile`

# setup the archive file on the debug server
reset $archiveFile

for i in `seq $lineCount`
do
	line=$(sed -n "$i p" $configFile)
	remoteMachine=$(echo $line | cut -d',' -f1)

	# insert the random word
	$_insertRandomWord $randomCount $remoteMachine  $saveDir $_wordInserted

	# process the data to find the final path taken
	grep "message_chk:freenet.keys.nodechk" $archiveFile > $archiveFile"-$i" 

	reset $archiveFile
	
#################################################################################
	prevKey=""
	fromNode=""
	toNode=""
	count=0
	skipLines=0
	ignoreKey=""
	outputLine=""
	location=-1
	fromLineMod=1
	while read archiveLine
	do
		let "count=$count+1"
		let "skipLines=$skipLines-1"

		#echo "$count : $fromNode : $toNode : $outputLine"

		# line skip
		if [ $skipLines -ge 0 ]
		then
			continue
		fi

		currentKey=$(echo $archiveLine | cut -d'@' -f3 | cut -d':' -f1)
		htl=$(echo $archiveLine | cut -d':' -f8 | cut -d',' -f1)
		
		# new key
		if [ "$currentKey" != "$prevKey" ]
		then
			echo $outputLine >> $fullFileName
			echo $outputLine
			let "fromLineMod=$count%2"
			location=$(cat "$saveDir$_wordInserted" | grep -i "$currentKey" | cut -d':' -f3)
			fromNode=""
			toNode=""
			outputLine=""
			ignoreKey=""
			prevhtl=$htl
		fi
		prevKey=$currentKey

		# repeat section of the data file
		if [ $htl -gt $prevhtl ]
		then
			#echo "ignoring a key"
			ignoreKey=$currentKey
		fi

		if [ "$ignoreKey"  = "$currentKey" ]
		then
			#echo "ignored entry"
			continue
		fi

		let "countMod=$count%2"
		if [ $countMod -eq $fromLineMod ]
		then
			fromNode=$(echo $archiveLine | cut -d' ' -f1)
			if [ "$toNode" != "" ]
			then
				if [ "$toNode" != "$fromNode" ]
				then
					#let "skipLines=2"
					junk="Skipping disabled.."
				fi
			else
				if [ "$location" = "" ]
				then
					outputLine="UNKNOWN $currentKey $fromNode "
				else
					outputLine="$location $fromNode "
				fi
			fi
		else
			toNode=$(echo $archiveLine | cut -d' ' -f1)
			outputLine="$outputLine $toNode"
		fi

		prevhtl=$htl

	done < "$archiveFile-$i"

	echo $outputLine >> $fullFileName
	echo $outputLine
#################################################################################

	
done
echo "********** Experiment Complete ***************"
