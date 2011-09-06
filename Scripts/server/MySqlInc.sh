#!/bin/bash

_defaultPort=2323

#===================================================================================================
# Main Entry Point
#===================================================================================================
# parameters
# 1 Configuration file
# 2 Password

source ./../common/parameters.sh

declare password
declare randomCount
declare randomLength
declare calcHost

ParameterScriptWelcome "mysql.sh"
ParameterPassword password $1
ParameterRandomCount randomCount "How many random words to insert? " $2
ParameterEnterHost calcHost "Enter host name to perform location and key calculation: " $3
ParameterScriptWelcomeEnd
#===================================================================================================

for i in `seq $randomCount`
	do
		word=""
		word="testdata$i"

		returned=$(expect -c "
		spawn telnet $calcHost $_defaultPort
		match_max 100000
		expect \"*TMCI>*\"
		send -- \"GETCHK:$word\r\"
		expect eof
		send -- \"QUIT\r\"
		interact timeout 30 return 
		" | egrep "URI:|Double:")
		
		doctored=$(echo $returned | sed -e 's/URI://g' -e 's/Double//g' -e 's/\r//g' -e 's/ //g')
		
		location=$(echo $doctored | cut -d':' -f2)
		key=$(echo $doctored | cut -d':' -f1)
		echo "Inserting $word $location $key"

		mysql -u freenetscript -p$password freenet -Bse "insert into RandomData values (\"$word\",$location,\"$key\");"
		
	done
echo "********** Data Insert Complete ***************"
