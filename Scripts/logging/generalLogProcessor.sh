#!/bin/bash

# Variables
_sshScript=../common/sshlogin.exp
_scpScriptCopyFrom=../common/scplogin_copyFrom.exp
_defaultConfigFile=../config/remoteMachines.dat
_defaultDirectory=~/Desktop/Freenet_Data/Node_Logs/

#===================================================================================================
#===================================================================================================
# parameters
# 1 Configuration file [optional]
# 2 password [optional, must supply parameter 1]

# check if config file was supplied
if [[ -n "$1" ]]
then
	# config file was given
	configFile="$1"
else
	# use default config file
	configFile="$_defaultConfigFile"
	echo "Using default configuration file :$configFile"
fi

# check if directory was supplied
if [[ -n "$2" ]]
then
	# config file was given
	folderName="$2"
else
	# use default config file
	folderName="$_defaultDirectory"
	echo "Working in directory :$folderName"
fi

# password check code
if [[ -n "$3" ]]
then
	# password was given
	password="$3"
else
	# ask for password
	echo -n "Enter password:"
	stty -echo
	read password
	stty echo
	echo ""
fi

folderNameRawData=$folderName"raw_data/"
folderNameProcessedData=$folderName"processed_data/"
folderNameInterView=$folderName"intermediate_view/"

mkdir -p $folderNameProcessedData
mkdir -p $folderNameInterView

for file in $folderNameRawData*
do
	echo "\nExtracting $file"
	unCompressed="$file.log"
	gzip -c -d $file > $unCompressed
	
	mv $file $folderNameProcessedData
	
	echo "Formatting file"
	( echo "<Log>"; cat ${unCompressed} ) > ${unCompressed}.new && mv ${unCompressed}.new ${unCompressed}
	echo "</Log>" >> $unCompressed

	echo "Processing file"

	xsltproc --output "$unCompressed.generalCommonUID.xml" ./generalCommonUID.xslt $unCompressed

	rm $unCompressed
done

echo "Combining intermediate data ..."
comdFileName=$folderNameRawData"$(date --rfc-3339=seconds)"
comdFileName=$(echo $comdFileName | sed -e 's/ /_/g' -e 's/:/\-/g')

echo "<MessageTraces>" > $comdFileName
for interFile in $folderNameRawData*.generalCommonUID.xml
do
	
	cat ${interFile} >> $comdFileName
	rm $interFile
done
echo "</MessageTraces>" >> $comdFileName


echo "Processing intermediate file"
xsltproc --output "$comdFileName.generalCommonUID.xml" ./generalCommonUID.xslt $comdFileName
rm $comdFileName

echo "Generating simple message trace"
java -jar SimpleMessageParser.jar "$comdFileName.generalCommonUID.xml" "$comdFileName.generalSimpleTrace.xml"

mv "$comdFileName.generalSimpleTrace.xml" $folderNameInterView
mv "$comdFileName.generalCommonUID.xml" $folderNameInterView

echo "********** Complete ***************"
