#!/bin/bash

# Check that all of the dependant programs are installed

#Parameters
#1 Error message
function reportErrorExit
{
	echo "ERROR: $1"
	exit 1
}
