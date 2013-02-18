#!/bin/bash

_scriptDir=$(dirname $0)
_userDir=$(pwd)
_firstRun=0
_output="$_userDir/counterMeasure.csv"
_log="$_userDir/counterMeasure.log"

source $_scriptDir/../common/general.sh

#Parameters
#1 sub-command
#2 list of values
function run 
{
  echo "$2"
  #echo "$1"

  local count=0
  while read line
  do
    let count=count+1

    # only run this once
    if [ $_firstRun -eq 0 ] 
    then
      # setup the output data file column headers
      echo "$_outputHeader $line" > "$_output"
      _firstRun=1
    fi 

    #skip over firt line it is just the headers
    if [ $count -eq 1 ]
    then 
      continue
    fi
	
    # save values to data file
    echo "$2 $line" >> "$_output"

    
  done < <(java -jar "$_scriptDir/../../bin/freenet-simulator.jar" $1 2>>"$_log")
}

#Main entry point

# constant run sub command
constCommand="--route 500000 --route-hops 10000 --script-output "
constCommand+="--route-fold-policy NONE --graph-lattice --route-bootstrap "
constCommand+="--route-policy PRECISION_LOSS"

#variables to loop over
networkSizes="1000 3000 5000"
degrees="8 15 26 40"
degreeDists="--degree-fixed"
topTypes="--link-flat --link-ideal"
lookAheads="1 2 3"
lookPrecisLosses="0.125 0.25 0.5"
randomRoutingChances="0 0.05 0.075 0.1"
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

              run "$command" "$values"
            done
          done
        done
      done
    done
  done
done


