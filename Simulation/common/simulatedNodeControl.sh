#!/bin/bash

# Variables
_prompt_node="TMCI> "

source ./common/depCheck.sh

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 HTL
#5 Data
#6 RETURN: Key
#7 RETURN: Location
function PutData
{
	local _key=$6
	local _loc=$7
	eval $_key="''"
	eval $_loc="''"
	
	local returned=$($1 "$2" "$3" "$_prompt_node" "PUTHTL:$4:$5" | egrep "URI:|Double:")
	#$1 "$2" "$3" "$_prompt_node" "PUTHTL:$4:$5"
	if [[ -n "$returned" ]]
	then
		local doctored=$(echo $returned | sed -e 's/URI//g' -e 's/Double//g' -e 's/\r//g' -e 's/ //g')
		local loc=$(echo $doctored | cut -d':' -f3)
		local key=$(echo $doctored | cut -d':' -f2)
		eval $_key="'$key'"
		eval $_loc="'$loc'"
		return 0
	fi
	return 1
}

#Parameters
#1 telnet script
#2 machine ip
#3 port
#4 Key
function GetData
{
	local returned=$($1 "$2" "$3" "$_prompt_node" "GET:$4" | grep "Content MIME type:")
	if [[ -n "$returned" ]]
	then
		return 0
	fi
	return 1
}

