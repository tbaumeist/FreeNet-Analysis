#!/bin/bash

# Variables
_sshScript=../common/sshlogin.exp
_scpScriptCopyFrom=../common/scplogin_copyFrom.exp
_startDirectory=./

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password
# 3 Working in directory
# 4 Save to directory

declare configFile
declare password
declare startDirectory
declare folderRootName

# check if start directory was supplied
if [[ -n "$3" ]]
then
	# was given
	startDirectory="$3"
else
	# use default dir
	startDirectory="$_startDirectory"
fi
echo "generalLogProcessor.sh Working in directory :$startDirectory"

source $startDirectory../common/parameters.sh


ParameterScriptWelcome "generalLogProcessor.sh"
ParameterConfigurationFile configFile $1
ParameterPassword password $2
ParameterSaveDirectoryLogs folderRootName $4
ParameterScriptWelcomeEnd
#===================================================================================================

folderNameRawData=$folderRootName"raw_data/"
folderNameProcessedData=$folderRootName"processed_data/"
folderNameInterView=$folderRootName"intermediate_view/"

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

	xsltproc --output "$unCompressed.generalCommonUID.xml" $startDirectory"generalCommonUID.xslt" $unCompressed

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
xsltproc --output "$comdFileName.generalCommonUID.xml" $startDirectory"generalCommonUID.xslt" $comdFileName
rm $comdFileName

echo "Generating simple message trace"
java -jar $startDirectory"SimpleMessageParser.jar" "$comdFileName.generalCommonUID.xml" "$comdFileName.generalSimpleTrace.xml"

mv "$comdFileName.generalSimpleTrace.xml" $folderNameInterView
mv "$comdFileName.generalCommonUID.xml" $folderNameInterView

echo "********** Complete ***************"
