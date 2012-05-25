#!/bin/bash

source ./common/general.sh

# Check that all of the dependant programs are installed

#Parameters
#1 Program name
function missingProgram
{
	reportErrorExit "The program: $1 is not installed. Please install."
}

#Parameters
#1 Program name
function commandExists
{
	hash "$1" &> /dev/null
	return $?
}

####################################################################################################
####################################################################################################
####################################################################################################

# Telnet
commandExists "telnet"
[ $? -eq 0 ] || missingProgram "telnet"

# lsof
commandExists "lsof"
[ $? -eq 0 ] || missingProgram "lsof"

# Expect
commandExists "expect"
[ $? -eq 0 ] || missingProgram "expect"

