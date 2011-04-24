#!/bin/bash

# default values
_defaultConfigFile=./config/remoteMachines.dat
_defaultSaveDirLogs=~/Desktop/Freenet_Data/Node_Logs/
_defaultSaveDirTopology=~/Desktop/Freenet_Data/Network_Topology/


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
#3 Given value
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

