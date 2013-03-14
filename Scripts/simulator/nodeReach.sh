#!/bin/bash

_scriptDir=`dirname ${BASH_SOURCE[0]}`
_userDir=$(pwd)
_firstRun=0
_firstRunInner=0
_output="$_userDir/counterMeasure.dat.txt"
_log="$_userDir/counterMeasure.log"

source $_scriptDir/../common/general.sh

echo "" > "$_log"

#Parameters
#1 sub-command
#2 list of values
function run 
{
  echo "$2"
  #echo "$1"
  local command="$1 --graph-save-dot $3"

  local count=0
  local innerHeader=""
  local innerResult=""
  while read line
  do
    let count=count+1
	
	#echo "java -cp $_scriptDir/../../bin/freenet-route-prediction.jar  frp.gephi.rti.AttackNodeAnalysisSingle -t $3 -n $networkSize -p $degree -htl 6 -ds 0 -o graph.analysis.dat -maxhtl 6"
	#echo "sim out"
	#echo "$line"
	#echo "sim out: end"
	
	if [ "$line" = "" ]
	then
		echo "Error generating graph"
		continue
	fi
	
    if [ $count -eq 1 ]
    then 
		local innerCount=0
		echo "" > graph.analysis.dat	
		#echo "sleeping..."
		#sleep 20
		
		java -cp "$_scriptDir/../../bin/freenet-route-prediction.jar"  frp.gephi.rti.AttackNodeAnalysisSingle -t $3 -n $networkSize -p $degree -htl 4 -ds 0 -o graph.analysis.dat -maxhtl 4 2>>"$_log"
		while read innerLine
		do
 			let innerCount=innerCount+1
		
			# only run this once
			if [ $_firstRunInner -eq 0 ] 
			then
			  innerHeader=${innerLine// /-}
			  innerHeader=${innerHeader//,/ }
			  _firstRunInner=1
			fi 
			 #skip over firt line it is just the headers
			if [ $innerCount -eq 1 ]
			then 
			  continue
			fi
			innerResult=${innerLine//,/ }
			
		done < <(cat graph.analysis.dat)
    fi
	
	
    # only run this once
    if [ $_firstRun -eq 0 ] 
    then
      # setup the output data file column headers
      echo "$_outputHeader $line $innerHeader" > "$_output"
      _firstRun=1
    fi 

    #skip over firt line it is just the headers
    if [ $count -eq 1 ]
    then 
      continue
    fi
	
    # save values to data file
    echo "$2 $line $innerResult" >> "$_output"

    
  done < <(java -Xms2500m -jar "$_scriptDir/../../bin/freenet-simulator.jar" $command 2>>"$_log")
}

#Main entry point

# constant run sub command
#constCommand="--route 500000 --route-hops 10000 --script-output "
#constCommand+="--route-fold-policy NONE --graph-lattice --route-bootstrap "
#constCommand+="--route-policy PRECISION_LOSS"
constCommand="--graph-lattice --script-output "
constCommand+="--route-policy PRECISION_LOSS"

#variables to loop over
networkSizes="1000 3000 5000 8000 10000"
degrees="8 11 15 19 26 34 40"
degreeDists="--degree-fixed"
topTypes="--link-flat --link-ideal"
lookAheads="1"
lookPrecisLosses="0"
randomRoutingChances="0"
#end variables to loop over

#none-looped variables
_experimentNum=2
_outputHeader="experimentNumber networkSize degree degreeDist topType "
_outputHeader+="lookAhead lookAheadPrecisionLoss randomRoutingPrecisionChance"

#end none-loop variables


for lookAhead in $lookAheads
do
  for degree in $degrees
  do
    for networkSize in $networkSizes
    do
      for degreeDist in $degreeDists
      do
        for topType in $topTypes
        do
          for lookPrecisLoss in $lookPrecisLosses
          do
            for randomRoutingChance in $randomRoutingChances
            do
	      command="--graph-size $networkSize $degreeDist $degree "
              command+="$topType --route-look-ahead $lookAhead  "
              command+="--route-look-precision $lookPrecisLoss "
              command+="--route-random-chance $randomRoutingChance "
              command+="$constCommand"

              values="$_experimentNum $networkSize $degree $degreeDist "
              values+="$topType $lookAhead $lookPrecisLoss $randomRoutingChance"

              run "$command" "$values" "$networkSize.$degree.$topType.dot"
            done
          done
        done
      done
    done
  done
done


