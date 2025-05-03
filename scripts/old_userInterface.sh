#!/bin/bash

# First Init the options and shorthand list
options=()
shorthand=()
prompt=$1

# Init columns and char separator
columns=$(tput cols)
separator=""
for (( i=1; i <= (( $columns / 5 )); i++)); do

	separator="$separator =-= "

done

for item in "${@:2}"; do

	options+=( "$item" )

done

function buildShorthand() {

	# First clear the shorthand list
	shorthand=()

	# For each value in the options list
	for i in "${options[@]}"; do

		# Lowercase the string
		i=${i,,}

		# Init the position field
		pos=0

		while true
		do

			# For each iteration increment pos
			((pos++))

			# Sanity Check
			if [ $pos -gt ${#i} ]; then
				echo "Could not make a shorthand for $i"
				shorthand+=( "$i" )
				break
			fi

			# Init the exists field
			exists=false

			# For each shorthand that exists
			for j in "${shorthand[@]}"; do

				# Check if the characters from 0 to position match
				if [ "${i:0:$pos}" = "$j" ]; then

					# If we find a match this shorthand is not valid
					exists=true

				fi

			done

			# If the shorthand did not already exist
			if [ "$exists" = false ]; then

				# Add it to the list and continue to the next index
				shorthand+=( ${i:0:$pos} )
				break

			fi

		done

	done

	# For each index in the shorthand list
	for i in "${!shorthand[@]}"; do

		# If the length is more than one character
		if [ "${#shorthand[i]}" -gt 1 ]; then

			# For each character in this index
			for (( j=0; j<${#shorthand[i]}; j++ )); do

				# Set the character that we are looking for
				char="${shorthand[i]:$j:1}"

				# Bool to keep check of whether or not it existed
				exists=false

				# For each index in the shorthand list
				for k in "${shorthand[@]}"; do

					# If the current character matches
					if [ "$char" = "$k" ]; then

						# It existed
						exists=true

					fi

				done

				# If the character did not exist
				if [ "$exists" = false ]; then

					# Overwrite this index with the character
					shorthand[i]="$char"

				fi

			done

		fi

	done

}

function findMatch() {

	str="${1,,}"

	# First check through the shorthand list
	for i in "${!shorthand[@]}"; do

		# If the string provided matches this index shorthand
		if [ "$str" = "${shorthand[i]}" ]; then

			# We found a match, return the index.
			return $i

		fi

		# Since the lists are the same size
		# We can check both in the same loop
		# If the string provided matches this index option
		if [ "$str" = "${options[i]}" ]; then

			# We found a match, return the index.
			return $i

		fi

	done

	return -1

}

function printOptions() {

	# Print user options below this point
	printline=""

	# For each value in the options list
	for i in "${!options[@]}"; do

		# These are used to build the print string for the option
		opt="${options[i]}"
		rep="${shorthand[i],,}"
		char="(${shorthand[i]})"
		char="${char^^}"

		# Creates the string for the option
		str="${opt/$rep/$char}"

		# If there is enough space to add it to the printline
		if [ $((${#printline} + ${#str} + 1 )) -lt $columns ]; then

			# Check if the printline is empty
			if [ ${#printline} -ne 0 ]; then
				# If it's not empty, add the index with a space
				printline="$printline $str"
			else
				# If it's empty, add the index without a space
				printline="$str"
			fi

		# Else there is not enough space to add it to the printline
		else

			# Print and overwrite the printline with the index
			echo "$printline"
			printline="$str"

		fi
	done

	# If data remains on the printline
	if [ ${#printline} -gt 0 ]; then

		# Print the prinline
		echo "$printline"

	fi
}

buildShorthand

# User interface
while true
do

	echo "$separator"

	echo "$prompt"

	echo "$separator"

	printOptions

	echo "$separator"

	# Read the user input.
	read userInput

	# Tells us how many columns exist in the terminal window.
	if [ $columns -ne $(tput cols) ]; then

		echo "Columns updated"
		echo "New Print Line Separator"

		columns=$(tput cols)
		separator=""

		for (( i=1; i <= (( $columns / 5 )); i++)); do

			separator="$separator =-= "

		done

	fi

	findMatch $userInput
	index=$?

	#echo "$index"

	if [ "$index" -ne 255 ]; then

		exit "$index"
		break

	else

		echo "Invalid Input!"
		sleep 1
		clear -x
		continue

	fi

	clr=true

done
