#! /bin/bash

function traverse
{
	local fileBase=$(basename "$1")
	local htl=$2
	local peers=$3
	local nodes=$4

	if [[ "$fileBase" == htl_* ]]
	then
	  	htl=$(echo $fileBase | cut -d'_' -f2)
		peers=$(echo $fileBase | cut -d'_' -f4)
		echo "setting htl = $htl, peers = $peers"
	fi

	if [[ "$fileBase" == *_remoteMachines ]]
	then
	  	nodes=$(echo $fileBase | cut -d'_' -f1)
		echo "setting nodes = $nodes"
	fi

	if [ -e $1/top*.dot ]; then
		echo ""
		echo "$1 contains experiment data. Processing ..."
		process $1 $htl $peers $nodes
		return
	fi

	for folder in $1/*
	do
		if [ -d $folder ]; then
			#echo "Searching sub folder $folder ..."
			traverse $folder $htl $peers $nodes
		fi
	done
}

function process
{
	local htl=$2
	local peers=$3
	local nodes=$4

	mv $1/map-random*.dat "$1/$mapRW"
	mv $1/map-random*.map "$1/$mapRW"
	mv $1/_randomFr*.dat "$1/$randWords"
	mv $1/top*.dot "$1/$top"
	mv $1/top*.png "$1/$topPng"
	mv $1/debugFiles*.dat "$1/$comm"
	mv $1/debugFiles*.log "$1/$comm"

	#clean up
	rm $1/results.out*

	#create empty log file if absent
	if [ ! -e "$1/$comm" ]; then
		echo "creating empty log file"
		echo "" > "$1/$comm"
	fi

	workDir="/home/user/FreeNet-Analysis/eclipse_workspace/Freenet-RoutePrediction/bin"

	echo "java -cp $workDir frp.fileConverters.GraphFileConverter -i $1/$top"
	java -cp "$workDir" frp.fileConverters.GraphFileConverter -i "$1/$top"

	echo "java -cp $workDir frp.predModelEval.ModelEvaluator -o $1/results.out -t $1/$top -map $1/$mapRW -words $1/$randWords -htl $htl -comm $1/$comm"
	java -cp "$workDir" frp.predModelEval.ModelEvaluator -o "$1/results.out" -t "$1/$top" -map "$1/$mapRW" -words "$1/$randWords" -htl $htl -comm $1/$comm
	echo ""
	echo ""
	
	local record="false"
	while read line
	do
		if [[ $record = "true" ]]
		then
			echo "$nodes,$peers,$htl,$line" >> $output			
		fi
		if [[ $line = "Per HTL Stats" ]]
		then
			record="true";
		fi
		
	done < "$1/results.out"
}


mapRW="mapRandomWords.map"
randWords="randomFreenetWords.dat"
top="top.dot"
topPng="top.png"
comm="commLog.log"
output="results.csv"

echo "Node #,Peer #,Max HTL,HTL,Total Inserts #,Complete Hit #,Partial Hit #" > $output
traverse $PWD 4 5 6

