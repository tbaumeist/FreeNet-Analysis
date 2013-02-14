#!/bin/bash

_scriptDir=$(dirname $0)
_userDir=$(pwd)

# default values
_defaultConfigFile="$_scriptDir/config/remoteMachines.dat"
_defaultConfigFolder="$_scriptDir/config/configs/"
_defaultSaveDirLogs="$_userDir/Node_Logs/"
_defaultSaveDirTopology="$_userDir/Network_Topology/"
_defaultSaveDirGeneral="$_userDir/Freenet_Data/"


#Parameters
#1 Script name
function ParameterScriptWelcome
{
	echo "******************************************"
	echo "Starting the script $1. If any parameters were given, they will be listed below:"
}

function ParameterScriptWelcomeEnd
{
	echo "******************************************"
}

#Parameters
#1 Variable to write to
#2 Given value
function ParameterConfigurationFile
{
	local _variable=$1
	local givenValue=$2
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# use default config file
		value="$_defaultConfigFile"
	fi	

	echo -e "\tConfiguration File=$value"
	eval $_variable="'$value'"
}


#Parameters
#1 Variable to write to
#2 Given value
function ParameterConfigurationFolder
{
	local _variable=$1
	local givenValue=$2
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# use default config file
		value="$_defaultConfigFolder"
	fi	

	echo -e "\tConfiguration Folder=$value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#2 Given value
function ParameterPassword
{
	local _variable=$1
	local givenValue=$2
	local value

	if [[ -n "$givenValue" ]]
	then
		# password was given
		value="$givenValue"
	else
		# ask for password
		echo -n "Enter password:"
		stty -echo
		read value
		stty echo
		echo ""
	fi	

	echo -e "\tPassword=********"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#2 Question
#3 Given value
function ParameterRandomCount
{
	local _variable=$1
	local givenValue=$3
	local value

	if [[ -n "$givenValue" ]]
	then
		# count was given
		value="$givenValue"
	else
		# ask for count
		echo -n "$2"
		read value
		echo ""
	fi	

	echo -e "\tNumber=$value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#2 Question
#3 Given value
function ParameterEnterHost
{
	local _variable=$1
	local givenValue=$3
	local value

	if [[ -n "$givenValue" ]]
	then
		# host was given
		value="$givenValue"
	else
		# ask for count
		echo -n "$2"
		read value
		echo ""
	fi	

	echo -e "\tHost to insert=$value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#3 Given value
function ParameterSaveDirectoryLogs
{
	local _variable=$1
	local givenValue=$2
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# use default config file
		value="$_defaultSaveDirLogs"
	fi	

	echo -e "\tLog Save Directory=$value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#3 Given value
function ParameterSaveDirectoryTopology
{
	local _variable=$1
	local givenValue=$2
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# use default config file
		value="$_defaultSaveDirTopology"
	fi	

	echo -e "\tLog Save Directory=$value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#2 Default Value
#3 Given value
function ParameterFileName
{
	local _variable=$1
	local defaultValue=$2
	local givenValue=$3
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# use default config file
		value="$defaultValue"
	fi	

	echo -e "\tFile name=$value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#2 Question
#3 Default Value
#4 Given value
function ParameterRandomQuestion
{
	local _variable=$1
	local question=$2
	local defaultValue=$3
	local givenValue=$4
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# ask question
		echo -n "$question"
		read value
		echo ""
		if [[ -n "$value" ]]
		then
			#use input value
			echo -n "" #bogus command
		else
			# use default config file
			value="$defaultValue"
		fi
	fi	

	echo -e "\t$question = $value"
	eval $_variable="'$value'"
}

#Parameters
#1 Variable to write to
#3 Given value
function ParameterSaveDirectoryGeneral
{
	local _variable=$1
	local givenValue=$2
	local value

	if [[ -n "$givenValue" ]]
	then
		# config file was given
		value="$givenValue"
	else
		# use default config file
		value="$_defaultSaveDirGeneral"
	fi	

	echo -e "\tGeneral Save Directory=$value"
	eval $_variable="'$value'"
}

