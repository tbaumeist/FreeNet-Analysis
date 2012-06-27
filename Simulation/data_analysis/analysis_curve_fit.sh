#!/bin/bash

# Variables
_bestFitScript="./best_fit_algorithm.sh"
_functionSolver="./function_x_solver.sh"


# Parameters
# 1 tmp data file name (low)
# 2 tmp data file name (high)
# 3 output file name (master file)
# 4 output file base name
# 5 node count
# 6 peer count
# 7 HTL
function runDataSet
{
	local outFileNameLow="$4$5_$6_$7_min"
	local outFileNameHigh="$4$5_$6_$7_max"
	local title="Node $5, Degree $6, HTL $7"

	#local resultLowest=""
	#local resultHighest=""
	#local rLowest=0
	#local rHighest=0

	#for i in {2..10}
	#do
	#	# fit the equation
	#	local resultLow=$($_bestFitScript "$i" "$1" "$outFileNameLow$i.png" "$title, Minimum")
	#	local resultHigh=$($_bestFitScript "$i" "$2" "$outFileNameHigh$i.png" "$title, Maximum")

	#	local rL=$(echo $resultLow | cut -d'|' -f1 | cut -d'=' -f2)
	#	local rH=$(echo $resultHigh | cut -d'|' -f1 | cut -d'=' -f2)

	#	if [ $(echo "$rL > $rLowest"|bc) ]
	#	then
	#		rLowest=$rL
	#		resultLowest=$resultLow
	#	fi
	#	if [ $(echo "$rH > $rHighest"|bc) ]
	#	then
	#		rHighest=$rH
	#		resultHighest=$resultHigh
	#	fi
	#	echo "$resultLow"
	#	echo "$resultLowest"
	#done

	local resultLowest=$($_bestFitScript 6 "$1" "$outFileNameLow.png" "$title, Minimum")
	local resultHighest=$($_bestFitScript 6 "$2" "$outFileNameHigh.png" "$title, Maximum")

	local fLow=$(echo $resultLowest | cut -d'|' -f2 | cut -d'=' -f2)
	local rLow=$(echo $resultLowest | cut -d'|' -f1 | cut -d'=' -f2)
	local fHigh=$(echo $resultHighest | cut -d'|' -f2 | cut -d'=' -f2)
	local rHigh=$(echo $resultHighest | cut -d'|' -f1 | cut -d'=' -f2)

	# solve the equation
	local solutionLow=$($_functionSolver "$fLow")
	local solutionHigh=$($_functionSolver "$fHigh")

	local low25=$(echo $solutionLow | cut -d',' -f1 | cut -d'=' -f2)
	local low50=$(echo $solutionLow | cut -d',' -f2 | cut -d'=' -f2)
	local low75=$(echo $solutionLow | cut -d',' -f3 | cut -d'=' -f2)
	local low100=$(echo $solutionLow | cut -d',' -f4 | cut -d'=' -f2)
	local high25=$(echo $solutionHigh | cut -d',' -f1 | cut -d'=' -f2)
	local high50=$(echo $solutionHigh | cut -d',' -f2 | cut -d'=' -f2)
	local high75=$(echo $solutionHigh | cut -d',' -f3 | cut -d'=' -f2)
	local high100=$(echo $solutionHigh | cut -d',' -f4 | cut -d'=' -f2)

	# save results
	echo "$5,$6,$7,$fLow,$rLow,$fHigh,$rHigh,$low25,$low50,$low75,$low100,$high25,$high50,$high75,$high100" >> "$3"
}

# Parameters
# 1 tmp data file name (low)
# 2 tmp data file name (high)
# 3 output file name (master file)
# 4 output file base name
# 5 node count
# 6 peer count
# 7 HTL
function newDataSet
{
	[ -e "$1" ] && runDataSet "$1" "$2" "$3" "$4" "$5" "$6" "$7"
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

mkdir -p "$outputDirectory"

tmpDataFileLow="$outputDirectory/tmpDataLow.dat"
tmpDataFileHigh="$outputDirectory/tmpDataHigh.dat"

# setup master data file
masterDataFile="$outputDirectory/$outputFile.csv"
echo "Node Count,Peer Count,HTL,Min Function,Min R^2,Max Function,Max R^2,Attack Size for Min Victims 25%,Attack Size for Min Victims 50%,Attack Size for Min Victims 75%,Attack Size for Min Victims 100%,Attack Size for Max Victims 25%,Attack Size for Max Victims 50%,Attack Size for Max Victims 75%,Attack Size for Max Victims 100%" > "$masterDataFile"

# process the data
nodes=0
peerCount=0
HTL=0
startNewDataSet=1

count=0
while read line
do
	let "count=$count+1"
	# skip headers
	[ $count -le 1 ] && continue
	
	newNodes=$(echo $line | cut -d',' -f1)
	newPeerCount=$(echo $line | cut -d',' -f2)
	newHTL=$(echo $line | cut -d',' -f3)

	# only need to check if last parameter HTL changed (it changes the most frequent)
	[ "$newHTL" != "$HTL" ] && newDataSet "$tmpDataFileLow" "$tmpDataFileHigh" "$masterDataFile" "$outputDirectory/$outputFile" "$nodes" "$peerCount" "$HTL"
	
	nodes=$newNodes
	peerCount=$newPeerCount
	HTL=$newHTL

	# build up the data files
	attackSetSize=$(echo $line | cut -d',' -f4)
	minTargetSize=$(echo $line | cut -d',' -f5)
	maxTargetSize=$(echo $line | cut -d',' -f6)
	
	echo -e "$attackSetSize\t$minTargetSize" >> "$tmpDataFileLow"
	echo -e "$attackSetSize\t$maxTargetSize" >> "$tmpDataFileHigh"
	
done < "$inputFile"

# run one more time for the last data set
newDataSet "$tmpDataFileLow" "$tmpDataFileHigh" "$masterDataFile" "$outputDirectory/$outputFile" "$nodes" "$peerCount" "$HTL"

echo "Complete"


