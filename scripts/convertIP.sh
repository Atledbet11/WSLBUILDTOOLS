#!/bin/bash

# This function Converts a given partial IP into a full IPV4 address.

gateway=1

function convertIP() {

	# This counts the number of periods in the string provided to the function.
	len=$(echo $1 | tr -dc '.' | wc -c)

	# This sets appends the rest of the IP to the front of the provided string.
	if [ $len -gt 1 ]; then

		# If there are two periods in the string, append "192." to the front of it.
		if [ $len == 2 ]; then
			convertedIP="192."$1
			
		# Else there would have to be at most 3 periods and no change is needed.
		elif [ $len == 3 ]; then
			convertedIP=$1
			
		## NEEDS TESTING ##
		# If too many periods detected, then the ip is invalid.
		else
			echo "Invalid IP"
			break
		fi
	else

		# If there is only one period in the provided string, then append "192.168." to the front of it.
		if [ $len == 1 ]; then
			convertedIP="192.168."$1
			
		# Else the converted IP does not have a period provided, And we have to append "192.168." and the $gateway "." to the front of the string.
		else
			convertedIP="192.168."$gateway"."$1
		fi
	fi
	
	echo $convertedIP

}

# Return the converted IP.
convertIP $1
