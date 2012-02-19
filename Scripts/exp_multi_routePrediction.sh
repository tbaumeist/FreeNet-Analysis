#!/bin/bash

# Variables
_updateScript=./update.sh
_runScript=./runRemote.sh
_expScript=./exp_routePrediction.sh
_sshScript=./common/sshlogin.exp
_startUpNetwork=./startRandomNetwork.sh

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters

source ./common/parameters.sh

declare configFile
declare password
declare randomCount
declare repeatCount
declare htlCount
declare saveDir
declare fileName

declare configFolder

ParameterScriptWelcome "exp_routePrediction.sh"
ParameterRandomCount randomCount "How many random words to insert at each node? " $1
ParameterRandomCount htlCount "Max HTL? " $2
ParameterRandomCount repeatCount "Number of time to run exp? " $3
ParameterConfigurationFolder configFolder $4
ParameterPassword password $5
ParameterSaveDirectoryGeneral saveDir $6
ParameterFileName fileName $_wordInserted $7
ParameterScriptWelcomeEnd
#===================================================================================================

for file in $configFolder*.dat
do
	for i in `seq $repeatCount`
	do
		configName=$(basename $file | cut -d'.' -f1)
		outputFolder="$saveDir$configName/$i/"
		echo "Setting up output folder $outputFolder"	
		
		$_startUpNetwork "$file" "$password"

		$_expScript $randomCount $htlCount "$file" "$password" "$outputFolder" "$fileName"

		#shut down
		$_runScript "$file" "$password" "x"
	done
done

echo "********** Running Experiments Complete ***************"
