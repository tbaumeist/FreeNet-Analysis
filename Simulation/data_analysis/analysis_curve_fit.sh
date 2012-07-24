#!/bin/bash

# Variables
_bestFitScript="./_best_fit_algorithm.sh"
_functionSolver="./_function_x_solver.sh"

# Parameters
# 1 base file name
# 2 file postfix
# 3 output file name
function getFileName
{
	local _variable=$3
	local name=$1
	local postfix=$2
	local value

	local count=1
	while [ 0 ]
	do
		value="$name-$count$postfix"
		if [ -e "$value" ]
		then
			let "count=$count+1"
		else
			break
		fi
	done

	eval $_variable="'$value'"
}


# Parameters
# 1 tmp data file name (low)
# 2 tmp data file name (high)
# 3 output file name (master file)
# 4 output file base name
# 5 node count
# 6 peer count
# 7 HTL
# 8 last x min
# 9 last x max
function runDataSet
{
	local outFileNameLow
	getFileName "$4$5_$6_$7_min" ".png" outFileNameLow
	local outFileNameHigh
	getFileName "$4$5_$6_$7_max" ".png" outFileNameHigh

	local title="Node $5, Degree $6, HTL $7"

	local resultLowest=$($_bestFitScript 4 "$1" "$outFileNameLow" "$title, Minimum")
	local resultHighest=$($_bestFitScript 4 "$2" "$outFileNameHigh" "$title, Maximum")

	local straightLow=$(echo $resultLowest | cut -d'|' -f3)
	local fLow=$(echo $resultLowest | cut -d'|' -f2 | cut -d'=' -f2)
	local rLow=$(echo $resultLowest | cut -d'|' -f1 | cut -d'=' -f2)
	local straightHigh=$(echo $resultHighest | cut -d'|' -f3)
	local fHigh=$(echo $resultHighest | cut -d'|' -f2 | cut -d'=' -f2)
	local rHigh=$(echo $resultHighest | cut -d'|' -f1 | cut -d'=' -f2)

	# solve the equation
	local solutionLow=$($_functionSolver "$fLow" "$straightLow")
	local solutionHigh=$($_functionSolver "$fHigh" "$straightHigh")

	local low25=$(echo $solutionLow | cut -d',' -f1 | cut -d'=' -f2)
	local low50=$(echo $solutionLow | cut -d',' -f2 | cut -d'=' -f2)
	local low75=$(echo $solutionLow | cut -d',' -f3 | cut -d'=' -f2)
	local low100=$(echo $solutionLow | cut -d',' -f4 | cut -d'=' -f2)
	local high25=$(echo $solutionHigh | cut -d',' -f1 | cut -d'=' -f2)
	local high50=$(echo $solutionHigh | cut -d',' -f2 | cut -d'=' -f2)
	local high75=$(echo $solutionHigh | cut -d',' -f3 | cut -d'=' -f2)
	local high100=$(echo $solutionHigh | cut -d',' -f4 | cut -d'=' -f2)

	#error correction
	local smallestPossible=$(echo "2/$5*100" | bc -l)
	[ $(echo "$low25 < $smallestPossible" | bc) -ne 0 ] && low25=$smallestPossible
	[ $(echo "$low50 < $smallestPossible" | bc) -ne 0 ] && low50=$smallestPossible
	[ $(echo "$low75 < $smallestPossible" | bc) -ne 0 ] && low75=$smallestPossible
	[ $(echo "$low100 < $smallestPossible" | bc) -ne 0 ] && low100=$smallestPossible
	if [ $(echo "$low100 > $8" | bc) -ne 0 ] 
	then
		echo "Correcting 100% low"		
		low100=$8
	fi
	[ $(echo "$high25 < $smallestPossible" | bc) -ne 0 ] && high25=$smallestPossible
	[ $(echo "$high50 < $smallestPossible" | bc) -ne 0 ] && high50=$smallestPossible
	[ $(echo "$high75 < $smallestPossible" | bc) -ne 0 ] && high75=$smallestPossible
	[ $(echo "$high100 < $smallestPossible" | bc) -ne 0 ] && high100=$smallestPossible
	if [ $(echo "$high100 > $9" | bc) -ne 0 ]
	then
		echo "Correcting 100% high"		
		high100=$9
	fi

	# save results
	echo "$5,$6,$7,$fLow,$rLow,$fHigh,$rHigh,$low25,$low50,$low75,$low100,$high25,$high50,$high75,$high100" >> "$3"
	echo -e "MIN:\t$low25,$low50,$low75,$low100\t\tMAX:\t$high25,$high50,$high75,$high100"
}

# Parameters
# 1 tmp data file name (low)
# 2 tmp data file name (high)
# 3 output file name (master file)
# 4 output file base name
# 5 node count
# 6 peer count
# 7 HTL
# 8 last x min
# 9 last x max
function newDataSet
{
	[ -e "$1" ] && runDataSet "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
	rm "$1" >& /dev/null
	rm "$2" >& /dev/null
}

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Port to use for simulator
# 2 Directory to store run files

#source
source ../../Scripts/common/parameters.sh

declare inputFile
declare outputDirectory
declare outputFile

ParameterScriptWelcome "analysis_curve_fit.sh"
ParameterRandomQuestion inputFile "Input data file name?" "./data.dat" $1
ParameterRandomQuestion outputDirectory "Output data file directory [Default=./experiment_functions]" "./experiment_functions" $2
ParameterRandomQuestion outputFile "Output data file basename? [Default=ex_f_]" "ex_f_" $3
ParameterScriptWelcomeEnd
#===================================================================================================

rm -rf "$outputDirectory" >& /dev/null
mkdir -p "$outputDirectory"

tmpDataFileLow="$outputDirectory/tmpDataLow.dat"
tmpDataFileHigh="$outputDirectory/tmpDataHigh.dat"


rm "$tmpDataFileLow" >& /dev/null
rm "$tmpDataFileHigh" >& /dev/null

# setup master data file
masterDataFile="$outputDirectory/$outputFile.csv"
echo "Node Count,Peer Count,HTL,Min Function,Min R^2,Max Function,Max R^2,Attack Size for Min Victims 25%,Attack Size for Min Victims 50%,Attack Size for Min Victims 75%,Attack Size for Min Victims 100%,Attack Size for Max Victims 25%,Attack Size for Max Victims 50%,Attack Size for Max Victims 75%,Attack Size for Max Victims 100%" > "$masterDataFile"

# process the data
nodes=0
peerCount=0
HTL=0
attackSetSize=0
startNewDataSet=1

count=0
min100Count=0
max100Count=0
x_lastMin=0
x_lastMax=0
while read line
do
	let "count=$count+1"
	# skip headers
	[ $count -le 1 ] && continue
	
	newNodes=$(echo $line | cut -d',' -f1)
	newPeerCount=$(echo $line | cut -d',' -f2)
	newHTL=$(echo $line | cut -d',' -f3)
	newAttackSetSize=$(echo $line | cut -d',' -f4)

	attackSetSizeActual=$(echo $line | cut -d',' -f9)
	minCoverage=$(echo $line | cut -d',' -f5)
	maxCoverage=$(echo $line | cut -d',' -f6)

	# skip the entries with attack set size less than 2
	[ $attackSetSizeActual -lt 2 ] && continue

	# only need to check if the attack set size reset, if so its a new data set
	if [ $(echo "$attackSetSize > $newAttackSetSize" | bc) -ne 0 ] 
	then
		min100Count=0
		max100Count=0
		newDataSet "$tmpDataFileLow" "$tmpDataFileHigh" "$masterDataFile" "$outputDirectory/$outputFile" "$nodes" "$peerCount" "$HTL" "$x_lastMin" "$x_lastMax"
		x_lastMin=0
		x_lastMax=0
		x_delta=0
	fi
	
	# count how many 100 % coverage we have seen, stop after seeing two consequitive 100s
	if [  $(echo "$minCoverage == 100" | bc) -ne 0 ]
	then
		let "min100Count=$min100Count + 1"
	else
		min100Count=0
	fi
	if [  $(echo "$maxCoverage == 100" | bc) -ne 0 ]
	then
		let "max100Count=$max100Count + 1"
	else
		max100Count=0
	fi

	nodes=$newNodes
	peerCount=$newPeerCount
	HTL=$newHTL

	# build up the data files
	attackSetSize=$newAttackSetSize
	minTargetSize=$(echo $line | cut -d',' -f5)
	maxTargetSize=$(echo $line | cut -d',' -f6)

	#echo -e "$attackSetSize\t$minTargetSize" >> "$tmpDataFileLow"
	#echo -e "$attackSetSize\t$maxTargetSize" >> "$tmpDataFileHigh"	

	# only write data points if we have seen less than 3 consequtive 100s
	if [ $min100Count -le 4 ]
	then
		x_lastMin=$attackSetSize
		echo -e "$attackSetSize\t$minTargetSize" >> "$tmpDataFileLow"
	fi
	
	if [ $max100Count -le 4 ]
	then
		x_lastMax=$attackSetSize
		echo -e "$attackSetSize\t$maxTargetSize" >> "$tmpDataFileHigh"
	fi
	
done < "$inputFile"

# run one more time for the last data set
newDataSet "$tmpDataFileLow" "$tmpDataFileHigh" "$masterDataFile" "$outputDirectory/$outputFile" "$nodes" "$peerCount" "$HTL" "$x_lastMin" "$x_lastMax"

echo "Complete"


