#!/bin/bash

# Only runs if the script is being directly executed.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

        echo "Script is being directly executed!"
	echo "Source this script using 'source userInputValidation.sh'"
	exit 255

# Only runs if the script is being sourced.
else
	if [[ -n SOURCE_USERINPUTVALIDATION ]]; then
		SOURCE_USERINPUTVALIDATION=1
	else
		echo "File was already sourced!"
		exit 255
	fi
fi


function userInputValidation() {

	# This script will take in a few arguments
	# -u  --uinput   # value # User Input
	# -o  --option   # value # Valid options as a list
	# -i  --integer  # value # Validate type is integer
	# -n  --number   #       # Validate type is number
	# -a  --alpha    #       # Validate type is letter only
	# -an --alphanum #       # Validate type is letters or numbers
	# -ip --ip       #       # Validate type is an IP or IP shorthand
	#     --chmod    #       # Validate type is a CHMOD permission value

	local POSITIONAL_ARGS=()
	local MUTUALLY_EXCLUSIVE=0

	function exclusivity() {

		# Check if MUTUALLY_EXCLUSIVE is set
		if [[ "${MUTUALLY_EXCLUSIVE}" == 1 ]]; then

			# return with error
			echo "To many parameters!"
			return 255

		fi

		MUTUALLY_EXCLUSIVE=1

	}

	function debug() {

		if [[ -n "${DEBUG}" ]]; then

			echo -e "${1}"

		fi

	}

	while [[ "${#}" -gt 0 ]]; do
		case "${1}" in

			# USERINPUT
			-u|--uinput)
				local USERINPUT="${2}"
				shift # Past argument
				shift # Past value
				;;

			# OPTION
			-o|--option)
				local -n OPTION="${2}"
				# Make sure the user supplied valid options
				if [[ "${#OPTION[@]}" == 0 ]]; then
					echo "Invalid Options List Length!"
					return 255
				fi
				shift # Past argument
				shift # Past value
				exclusivity
				;;

			# INTEGER
			-i|--integer)
				local INTEGER=1
				exclusivity
				shift # Past argument
				;;

			# NUMBER
			-n|--number)
				local NUMBER=1
				exclusivity
				shift # Past argument
				;;

			# ALPHA
			-a|--alpha)
				local ALPHA=1
				exclusivity
				shift # Past argument
				;;

			# ALPHANUMERIC
			-an|--alphanum)
				local ALPHANUMERIC=1
				exclusivity
				shift # Past argument
				;;

			# IP
			-ip|--ip)
				local IP=1
				exclusivity
				shift # Past argument
				;;

			# CHMOD
			--chmod)
				local CHMOD=1
				exclusivity
				shift # Past argument
				;;

			# DEBUG
			-d|--debug)
				local DEBUG=1
				shift # Past argument
				;;

			# Error catching
			-*|--*)
				echo "Unknown option ${1}"
				return 255
				;;

			# Save positional arg
			*)
				local POSITIONAL_ARGS+=("${1}")
				shift # Past argument
				;;

		esac
	done

	# Restore positional parameters
	set -- "${POSITIONAL_ARGS[@]}"

	# Make sure an option for validation was supplied
	if [[ "${MUTUALLY_EXCLUSIVE}" == 0 ]]; then

		# Error
		echo "You must supply a validation parameter"
		return 255

	fi

	if [[ -n "${DEBUG}" ]]; then
		echo "USERINPUT    = ${USERINPUT}"
		if [[ -n "${OPTION}" ]];       then echo "OPTION       = ${OPTION[@]}"; fi
		if [[ -n "${INTEGER}" ]];      then echo "INTEGER      = ${INTEGER}"; fi
		if [[ -n "${NUMBER}" ]];       then echo "NUMBER       = ${NUMBER}"; fi
		if [[ -n "${ALPHA}" ]];        then echo "ALPHA        = ${ALPHA}"; fi
		if [[ -n "${ALPHANUMERIC}" ]]; then echo "ALPHANUMERIC = ${ALPHANUMERIC}"; fi
		if [[ -n "${IP}" ]];           then echo "IP           = ${IP}"; fi
		if [[ -n "${CHMOD}" ]];        then echo "CHMOD        = ${CHMOD}"; fi
	fi

	# Validate that USERINPUT was supplied
	if [[ -z "${USERINPUT}" ]]; then

		# Error handling
		echo "-u is required"
		return 255

	fi

	if [[ -n "${OPTION}" ]]; then

		# Option handling
		# Returns the index from the list that matches, or 255 for nomatch
		debug "Handling option parameter"

		# Get length of option list
		local LENGTH="${#OPTION[@]}"

		# For each index in the list
		for (( i=0; i<"${LENGTH}"; i++ ))
		do

			debug "${OPTION[${i}]}"

			# If the option matches the userinput
			if [[ "${OPTION[$i]}" == "${USERINPUT}" ]]; then

				# Echo that we had a match, and return with the index
				debug "${USERINPUT} matched index ${i} - ${OPTION[${i}]}"
				return "${i}"

			fi

		done

		# Could not find a match
		echo "Could not find a match for ${USERINPUT}"

		return 255

	fi

	if [[ -n "${INTEGER}" ]]; then

		# Integer handling
		# Returns 0 for pass, 255 for fail
		if [[ "${USERINPUT}" =~ ^[0-9]+$ ]]; then

			# A valid Integer
			debug "${USERINPUT} is valid."
			return 0

		else

			# Not a valid Integer
			echo "${USERINPUT} is not a valid Integer!"
			return 255

		fi

	fi

	if [[ -n "${NUMBER}" ]]; then

		# Number handling
		# Returns 0 for pass, 255 for fail
		if [[ "${USERINPUT}" =~ ^[+-]?[0-9]+([.][0-9]*)?$ ]]; then

	                # A valid Number
	                debug "${USERINPUT} is valid."
	                return 0

	        else

	                # Not a valid Number
	                debug "${USERINPUT} is not a valid Number!"
	                return 255

	        fi

	fi

	if [[ -n "${ALPHA}" ]]; then

		# Alhpa handling
		# Returns 0 for pass, 255 for fail
	        if [[ "${USERINPUT}" =~ ^[a-zA-Z]+$ ]]; then

	                # A valid Alpha String
	                debug "${USERINPUT} is valid."
	                return 0

	        else

	                # Not a valid Alpha String
	                echo "${USERINPUT} is not a valid Alpha String!"
	                return 255

	        fi

	fi

	if [[ -n "${ALPHANUMERIC}" ]]; then

		# Alphanumeric handling
		# Returns 0 for pass, 255 for fail
	        if [[ "${USERINPUT}" =~ ^[a-zA-Z0-9]+$ ]]; then

	                # A valid Alphanumeric String
			debug "${USERINPUT} is valid."
	                return 0

	        else

	                # Not a valid Alphanumeric String
	                echo "${USERINPUT} is not a valid Alphanumeric String!"
	                return 255

	        fi

	fi

	if [[ -n "${IP}" ]]; then

		# IP handling
		# Returns 0 for pass, 255 for fail

		# Create octet regex check
		local OCTET="(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])"

		# Create the full ip check
		local IP4="^${OCTET}\\.${OCTET}\\.${OCTET}\\.${OCTET}$"

		if [[ "${USERINPUT}" =~ ${IP4} ]]; then

			# A valid IP
			debug "${USERINPUT} is valid."
			return 0

		else

			# Not a valid IP
			echo "${USERINPUT} is not a valid IP"
			return 255

		fi

	fi

	if [[ -n "${CHMOD}" ]]; then

		# CHMOD Permissions are 000-777
		# Returns 0 for pass, 255 for fail

		if [[ "${USERINPUT}" =~ ^[0-7]{3}$ ]]; then

			# A Valid CHMOD Permission
			debug "${USERINPUT} is valid."
			return 0

		else

			# Invalid CHMOD Permission
			echo "${USERINPUT} is not a valid CHMOD permission"
			return 255

		fi

	fi

}
