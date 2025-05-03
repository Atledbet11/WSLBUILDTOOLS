#!/bin/bash

# This file should be sourced, not executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	echo "Script was directly executed!"
	echo "use source userInterface.sh"
	exit 255

fi

# We need to source userInputValidation.sh
source userInputValidation.sh

# User interface
#  Parameters
#  -p|--prompt      = Prompt for the user
#  -a|--promptarray = Nameref to array to prompt the user
#  -o|--options     = Nameref to array for valid options
#  -n|--number      = Enable number mode User must supply valid index
#  -d|--debug       = Debug enabled
function userInterface {

	local LB='\033[1;31m'
	local NC='\033[0m'

	local POSITIONAL_ARGS=()
	local SHORTHAND=()
	local MUTUALLY_EXCLUSIVE=0
	local MUTUALLY_EXCLUSIVE_MODE=0
	local COLUMNS=$(tput cols)
	local SEPARATOR="#"

	function exclusivity() {

		local -n MUTEX="${1}"

		# Check if MUTUALLY_EXCLUSIVE is set
		if [[ "${MUTEX}" == 1 ]]; then

			# return with error
			echo "To many parameters!"
			return 255

		fi

		MUTEX=1

	}

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Prompt
			-p|--prompt)
				local PROMPT=( "${2}" )
				local -n PRINTARRAY=PROMPT
				exclusivity MUTUALLY_EXCLUSIVE
				shift # Past argument
				shift # Past value
				;;

			# PROMPT Array
			-a|--promptarray)
				local -n PRINTARRAY="${2}"
				exclusivity MUTUALLY_EXCLUSIVE
				shift # Past argument
				shift # Past value
				;;

			# Options
			-o|--options)
				local -n UIOPTION="${2}"
				exclusivity MUTUALLY_EXCLUSIVE_MODE
				shift # Past argument
				shift # Past value
				;;

			# Number
			-n|--number)
				local NUMBER=1
				exclusivity MUTUALLY_EXCLUSIVE_MODE
				shift # Past argument
				;;

			# Debug
			-d|--debug)
				DEBUG=1
				shift # Past argument
				;;

			# Invalid arguments
			-*|--*)
				echo "Unknown option ${1}"
				return 255
				;;

			# Save positional arg
			*)
				echo "${1}"
				POSITIONAL_ARGS+=("${1}")
				shift # Past argument
				;;

		esac

	done

	# Restore positional parameters
	set -- "${POSITIONAL_ARGS[@]}"

	# Make sure an option for prompting was supplied
	if [[ "${MUTUALLY_EXCLUSIVE}" -le 0 ]]; then

		# Error
		echo "userInterface() You must supply a prompt parameter!"
		return 255

	fi

	# Make sure a valid mode for prompting was supplied
	if [[ "${MUTUALLY_EXCLUSIVE_MODE}" -le 0 ]]; then

		# Error
		echo "userInterface() You must supply a prompting option!"
		return 255

	fi

	# Make sure some prompt was supplied
	if [[ "${#PRINTARRAY[@]}" -le 0 ]]; then

		# Error
		echo "userInterface() You must supply a prompt for the user!"
		return 255

	fi

	# Make sure the list of options has a valid length too
	if [[ "${#UIOPTION[@]}" -le 0 && "${NUMBER}" == 0 ]]; then

		# Error
		echo "userInterface() You must supply options for the user!"
		return 255

	fi

	if [[ -n "${DEBUG}" ]]; then
		if [[ -n "${PROMPT}" ]]; then echo "PROMPT = ${PROMPT[@]}"; fi
		if [[ -n "${UIOPTION}" ]]; then echo "OPTION = ${UIOPTION[@]}"; fi
	fi

	# Init columns and char separator
	# Format #-----------------#
	function buildSeparator() {

		SEPARATOR="#"

		# For loop through the length of columns - 2
		for (( i=1; i <= (( "${COLUMNS}" - 2 )); i++)); do

			# Add dashes between the #'s
			SEPARATOR="${SEPARATOR}-"

		done

		# Add the ending #
		SEPARATOR="${SEPARATOR}#"

	}

	# Debug printing function
	function debug() {

		# Check if debug is enabled
		if [[ -n "${DEBUG}" ]]; then

			# Print the debug text
			echo -e "DEBUG: ${1}"

		fi

	}

	# Build Shorthand Function
	function buildShorthand() {

		# Debug that we are building the shorthnd
		debug "Building Shorthand"

		# Clear the Shorthand list
		SHORTHAND=()

		# For each value in the options list
		for i in "${UIOPTION[@]}"; do

			# Debug the word in scope
			debug "Word: ${i}"

			# Lowercase the string
			i=${i,,}

			# Init the position field
			POS=0

			while true
			do

				# Sanity Check
				if [[ "${POS}" -ge "${#i}" ]]; then
					debug "Could not make a shorthand for ${i}"
					SHORTHAND+=( "${i}" )
					break
				fi

				# Char to look for
				local CHAR="${i:${POS}:1}"

				# Init the exists field
				EXISTS=false

				# For each shorthand
				for j in "${SHORTHAND[@]}"; do

					# Check if the character from 0 to position match
					if [[ "${CHAR}" = "${j}" ]]; then

						# If we find a match this shorthand is not valid
						EXISTS=true

					fi

				done

				# If the shorthand did not already exist
				if [[ "${EXISTS}" == false ]]; then

					# Add it to the list and continue to the next index
					SHORTHAND+=( "${CHAR}" )
					debug "Adding (${CHAR}) for word ${i}"
					break

				fi

				# Increment POS
				let POS++

			done

		done

		# Debug the shorthand list generated
		debug "${SHORTHAND[@]}"

	}

	# Print the options list to the user
	function printOptions() {

		# Print user options below this point
		PRINTLINE=""

		# For each value in the options list
		for i in "${!UIOPTION[@]}"; do

			# These are used to build the print string for the option
			OPT="${UIOPTION[i]}"
			REP="${SHORTHAND[i],,}"
			CHAR="(${SHORTHAND[i]})"
			CHAR="${CHAR^^}"

			debug "OPTION ${OPT}"
			debug "REP    ${REP}"
			debug "SHORT  ${CHAR}"

			# Creates the string for the option
			STR="${OPT/${REP}/${CHAR}}"

			# If there is enough space to add it to the printline
			if [[ $(( "${#PRINTLINE}" + "${#STR}" + 5 )) -lt "${COLUMNS}" ]]; then

				# Check if the printline is empty
				if [[ "${#PRINTLINE}" -ne 0 ]]; then
					# If it's not empty, add the index with a space
					PRINTLINE="${PRINTLINE} ${STR}"
				else
					# If it's empty, add the index without a space
					PRINTLINE="${STR}"
				fi

			# Else there is not enough space to add it to the printline
			else

				# Print and overwrite the printline with the index
				printFormat "${PRINTLINE}"
				PRINTLINE="${STR}"

			fi

		done

		# If data remains on the printline
		if [[ "${#PRINTLINE}" -gt 0 ]]; then

			# Print the printline
			printFormat "${PRINTLINE}"

		fi

	}

	# Prints an array stored in PROMPTARRAY
	function printPromptArray() {

		# Make sure we have a valid array
		if [[ "${#PRINTARRAY[@]}" -le 0 ]]; then

			echo "userInterface:printPromptArray() Invalid array size!"
			return 255

		fi

		# Line number
		local NUM=0
		local LINE=""

		# If the length of the array is 1
		if [[ "${#PRINTARRAY[@]}" == 1 ]]; then

			printFormat "${PRINTARRAY[0]}"
			return 0

		fi

		# For each line in the array
		for LINE in "${PRINTARRAY[@]}"; do

			# Print the line number, and the array index
			printFormat "${NUM}: ${LINE}"

			# Increment Line Number
			let NUM++

		done

	}

	# Formatted print for strings
	# Formatting is # Some text                       #
	function printFormat() {

		# Local variables
		local PRINTSTRING=""
		local INPUTSTRING="${1}"
		local STRLENGTH="${#INPUTSTRING}"
		local MAXLEN=$(( "${COLUMNS}" - 4 ))
		local STRINGS=()
		local STRING=""

		# If the string is too long to print on one line
		if [[ "${STRLENGTH}" -gt "${MAXLEN}" ]]; then

			# While the INPUTSTRING length is > MAXLEN
			while [[ "${#INPUTSTRING}" -gt "${MAXLEN}" ]]; do

				local POS=0

				# For each character
				# Starting at MAXLEN
				# Working backwards to 0
				for (( i="${MAXLEN}"; i>= 0; i-- )); do

					# If the character at [i] is a " "
					if [[ "${INPUTSTRING:$i:1}" == " " ]]; then

						# Set the POS value
						POS="${i}"

						# Break out of the for loop
						break

					fi

				done

				# If we found a spot to split the string
				if [[ "${POS}" -gt 0 ]]; then

					# Split at the space and add to the array
					STRINGS+=( "${INPUTSTRING:0:${POS}}" )

					# Increment POS to remove the space
					let POS++

					# Remove the split from inputstring
					INPUTSTRING="${INPUTSTRING:${POS}}"

				# No space was found
				# Split at MAXLEN
				else

					# Split at MAXLEN and add to the array
					STRINGS+=( "${INPUTSTRING:0:${MAXLEN}}" )

					# Remove the spli from inputstring
					INPUTSTRING="${INPUTSTRING:0:${MAXLEN}}"

				fi

			done

			# Add the remaining piece to the list
			STRINGS+=( "${INPUTSTRING}" )

		# String fits on one line
		else

			# Add string to the stringlist
			STRINGS+=( "${INPUTSTRING}" )

		fi

		# For each string in the list
		for STRING in "${STRINGS[@]}"; do

			local SPACES="$(( ${MAXLEN} - ${#STRING} ))"

			# For each empty space we have room for
			for (( j=0; j < "${SPACES}"; j++ )); do

				# Fill the empty spaces with spaces
				STRING+=" "

			done

			# Now we can print the string :)
			echo "# ${STRING} #"

		done

	}

	# Print the whole UI
	function printUI() {

		# Clear the display
		clear -x

		# Print the separator line
		echo "${SEPARATOR}"

		# Print the prompt to the user
		printPromptArray

		# Print another separator line
		echo "${SEPARATOR}"

		# If using options
		if [[ -n "${UIOPTION}" ]]; then

			# Print the options to the user
			printOptions

		else

			printFormat "Enter index"

		fi

		# Print a final separator line
		echo "${SEPARATOR}"

	}

	function userInterfaceLoop() {

		local USERINPUT=""

		buildSeparator

		# If using options
		if [[ -n "${UIOPTION}" ]]; then

			# Build shorthand notation for the options
			buildShorthand

		fi

		# While loop
		while true; do

			USERINPUT=""

			# Rebuild the separator incase the window resized
			buildSeparator

			# Print the ui to the user.
			printUI

			read USERINPUT

			# Lowercase the userinput
			USERINPUT="${USERINPUT,,}"

			# If using options list
			if [[ -n "${UIOPTION}" ]]; then

				# Validate that the response is in the option list
				userInputValidation -u "${USERINPUT}" -o UIOPTION >/dev/null
				local RET="${?}"

				# Check the return value
				if [[ "${RET}" -lt 255 ]]; then

					# Return the index the user selected
					return "${RET}"

				fi

				# Validate that the response is in the shorthand list
				userInputValidation -u "${USERINPUT}" -o SHORTHAND >/dev/null
				RET="${?}"

				if [[ "${RET}" -lt 255 ]]; then

					# Return the index the user selected
					return "${RET}"

				fi

			else

				debug "Number Check"

				# Validate that the response is a valid number
				userInputValidation -u "${USERINPUT}" -i >/dev/null

				debug "${?}"

				# If the number was an integer
				if [[ "${?}" == 0 ]]; then

					# We want to make sure it is positive
					# And less than the length of PROMPTARRAY
					if [[ "${USERINPUT}" -ge 0 && "${USERINPUT}" -lt "${#PRINTARRAY[@]}" ]]; then

						# Return the number
						return "${USERINPUT}"

					fi

				fi


			fi

			echo "Invalid response!"

		done

	}

	userInterfaceLoop

}
