#!/bin/bash

# Variables
_insertRandomWord=./insertRandomData.sh
_netTopology=./networkTopology.sh
_wordInserted="_randomFreenetWords.dat"
_telnetPort=8887
_telnetScript=./common/telnet.exp
_netTopology=./networkTopology.sh
_topCheckInterval=5


#Parameters
#1 Archive file name
function reset
{
	$_telnetScript "localhost" $_telnetPort "CMD>" "reset"
	$_telnetScript "localhost" $_telnetPort "CMD>" "archivechks $1"
}


#Parameters
#1 count
function saveTopology
{
	#save topology
	$_netTopology $configFile $password "$saveDir" "top-$1.dot"
	let "prev=$1-$_topCheckInterval"
	if [ $prev -gt 0 ]
	then
		local dif=$(diff "$saveDir""top-$prev.dot" "$saveDir""top-$1.dot" | wc -m)
		if [ $dif -eq 0 ]
		then
			rm "$saveDir""top-$prev.dot"
			rm "$saveDir""top-$prev.dot.png"
		fi
	fi
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

wordCount=1

for i in `seq $lineCount`
do
	line=$(sed -n "$i p" $configFile)
	remoteMachine=$(echo $line | cut -d',' -f1)

	
	for h in `seq $randomCount`
	do
		let "saveCheck=$h%$_topCheckInterval"
		if [ $saveCheck -eq 0 ]
		then
			saveTopology $wordCount

			# insert the random word
			$_insertRandomWord $_topCheckInterval $remoteMachine  $saveDir $_wordInserted
		fi
		let "wordCount=$wordCount+1"
	done
	
	# process the data to find the final path taken
	grep "message_chk:freenet.keys.nodechk" $archiveFile > $archiveFile"-$wordCount" 

	reset $archiveFile
	
#################################################################################
	prevKey=""
	fromNode=""
	toNode=""
	count=0
	ignoreKey=""
	outputLine=""
	location=-1
	grep "Sent" "$archiveFile-$wordCount" > "$archiveFile-tmp"

	while read archiveLine
	do
		let "count=$count+1"

		currentKey=$(echo $archiveLine | cut -d'@' -f3 | cut -d':' -f1)
		htl=$(echo $archiveLine | cut -d':' -f8 | cut -d',' -f1)
		
		# new key
		if [ "$currentKey" != "$prevKey" ]
		then
			echo $outputLine >> $fullFileName
			echo $outputLine
			location=$(cat "$saveDir$_wordInserted" | grep -i "$currentKey" | cut -d':' -f3)
			if [ "$location" = "" ]
			then
				outputLine="UNKNOWN $currentKey "
			else
				outputLine="$location "
			fi
			
			fromNode=""
			toNode=""
			ignoreKey=""
			prevhtl=$htl
		fi
		prevKey=$currentKey

		# repeat section of the data file
		if [ $htl -gt $prevhtl ]
		then
			#echo "ignoring a key"
			if [ "$ignoreKey" != "$currentKey" ]
			then
				outputLine="$outputLine $toNode 0 "
			fi
			ignoreKey=$currentKey
		fi

		if [ "$ignoreKey" = "$currentKey" ]
		then
			#echo "ignored entry"
			continue
		fi

		fromNode=$(echo $archiveLine | cut -d' ' -f1)
		toNode=$(echo $archiveLine | cut -d':' -f8 | cut -d' ' -f5)

		outputLine="$outputLine $fromNode $htl "

		prevhtl=$htl

	done < "$archiveFile-tmp"
	rm "$archiveFile-tmp"

	echo $outputLine >> $fullFileName
	echo $outputLine
#################################################################################

	
done
echo "********** Experiment Complete ***************"
