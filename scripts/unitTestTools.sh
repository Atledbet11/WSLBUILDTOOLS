#!/bin/bash

RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

PASS="UNIT TEST: ${BLUE}Pass${NC}"
FAIL="UNIT TEST: ${RED}Fail${NC}"

RAN=0
PASSED=0

COLS=$(tput cols)

# Title Logging
function titleLog() {

	# Set TITLE value to $1
	TITLE="${1}"

	# Default width
	WIDTH=75

	# IF the screen is bigger, update the width
	if [[ "${COLS}" -gt "${WIDTH}" ]]; then
		WIDTH="${COLS}"
	fi

	# length to print
	STRLEN="${#TITLE}"

	# Prepare for filler
	FILLER=""

	# Build the filler
	for (( i=0; i < (( "${WIDTH}" - "${STRLEN}" - 5 )); i++ )); do

		# Add dash to filler
		FILLER="${FILLER}-"

	done

	# Build this printstring
	PRINTSTR="# ${BLUE}${TITLE}${NC} #${FILLER}#"

	# Print the string
	echo -e "${PRINTSTR}"

}

# Test Logging
function testLog() {

	# Just add a space to the front of the title.
	titleLog " ${1}"

}

# Error logging
function err() {
	echo -e "UNIT TEST: Expect: ${BLUE}${1}${NC}"
	echo -e "UNIT TEST: Actual: ${RED}${2}${NC}"
}

# Unit Test
#  Usage: unitTest $CMD $EXPECT $EXPTEXT
function unitTest() {

	# Array to hold positional arguments
	POSITIONAL_ARGS=()

	# We require atleast one check condition
	REQUIRED=0

	# RESET VARIABLES
	CMD=""
	EXPECT=""
	EXPTEXT=""
	TITLE=""
	PRINT=""
	DEBUG=""


	# While loop through provided arguments
	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Command to be evaluated
			-c|--cmd)
				CMD="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Expected exit code
			-e|--expect)
				EXPECT="${2}"
				REQUIRED=1
				shift # Past argument
				shift # Past value
				;;

			# Expected text returned
			-t|--exptext)
				EXPTEXT="${2}"
				REQUIRED=1
				shift # Past argument
				shift # Past value
				;;

			# Test Title
			--test|--title)
				TITLE="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Print title
			-p|--print)
				PRINT=1
				shift # Past argument
				;;

			# DEBUG
			-d|--debug)
				DEBUG=1
				shift # Past argument
				;;

			# Default value will be enterpreted as CMD or ignored if CMD was already set
			*)
				# Make sure CMD was not already set
				if [[ -z "${CMD}" ]]; then CMD="${1}"; fi
				POSITIONAL_ARGS+=( "${1}" )
				shift # Past argument
				;;

			-*|--*)
				# Tell the user this parameter was unexpected
				echo "Unrecognized parameter ${1}"
				exit 255
				;;

		esac

	done

	if [[ -n "${DEBUG}" ]]; then   echo "DEBUG   = ${DEBUG}";

		if [[ -n "${CMD}" ]]; then     echo "COMMAND = ${CMD}"; else echo "COMMAND REQUIRED!"; exit 255; fi
		if [[ "${REQUIRED}" == 0 ]]; then echo "VALIDATION REQUIRED"; exit 255; fi
		if [[ -n "${EXPECT}" ]]; then  echo "EXPECT  = ${EXPECT}"; fi
		if [[ -n "${EXPTEXT}" ]]; then echo "EXPTEXT = ${EXPTEXT}"; fi
		if [[ -n "${TITLE}" ]]; then   echo "TITLE   = ${TITLE}"; fi
		if [[ -n "${PRINT}" ]]; then   echo "PRINT   = ${PRINT}"; fi

	fi

	if [[ -n "${PRINT}" && -n "${TITLE}" ]]; then testLog "${TITLE}"; fi

	if [[ -n "${DEBUG}" ]]; then
		echo "Warning Debug enabled, Tests will Fail!"
		TEXT=$(${CMD})
		ACTUAL=${?}
		echo "TEXT: ${TEXT}"
		echo "ACTUAL: ${ACTUAL}"
	else
		# Suppress output so the tests will pass
		TEXT=$(${CMD}) >/dev/null
		ACTUAL=${?}

	fi

	if [[ -n "${EXPECT}" ]]; then
		let RAN+=1
		if [[ "${EXPECT}" == "${ACTUAL}" ]]; then
			echo -e "${PASS}"
			let PASSED+=1
		else
			if [[ -z "${PRINT}" ]]; then testLog "${TITLE}"; fi
			echo -e "${FAIL}"
			err "${EXPECT}" "${ACTUAL}"
		fi

	fi

	if [[ -n "${EXPTEXT}" ]]; then
		let RAN+=1
		if [[ "${EXPTEXT}" == "${TEXT}" ]]; then
			echo -e "${PASS}"
			let PASSED+=1
		else
			if [[ -z "${PRINT}" ]]; then testLog "${TITLE}"; fi
			echo -e "${FAIL}"
			err "${EXPTEXT}" "${TEXT}"
		fi

	fi

}

# Success Logging
function successLog() {

	if [[ "${PASSED}" == "${RAN}" ]]; then
		echo -e "Success Rate: ${BLUE}${PASSED}/${RAN}${NC}"
	else
		echo -e "Success Rate: ${RED}${PASSED}/${RAN}${NC}"
	fi

}

# Calculate Int From Pass Ratio
function successInt() {

	if [ "${RAN}" -eq 0 ]; then
		echo "Error: Division by zero!"
		return 1
	fi

	PERCENT=$(( PASSED * 100 / RAN ))

	if [[ "${PERCENT}" == 100 ]]; then
		echo -e "Success Percentage: ${BLUE}${PERCENT}${NC}"
	else
		echo -e "Success Percentage: ${RED}${PERCENT}${NC}"
	fi

	exit "${PERCENT}"

}
