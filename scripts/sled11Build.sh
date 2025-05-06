#!/bin/bash

# This script will execute the commands needed to build the code
#  We need to read the contents of ../wslBuildCommands.txt and batch
#  those commands into the make clean && make call.

# Build script begin

# optional parameters
while [[ "${#}" -gt 0 ]]; do

	case "${1}" in

		# no-opt - Ignores wslBuildCommands.txt
		-n|--noopt)
			NOOPT=1
			shift # Past argument
			;;

		# debug
		-d|--debug)
			DEBUG=1
			shift # Past argument
			;;

		# unittest
		--unittest)
			UNITTEST=1
			shift # Past argument
			;;

		# Error Handling
		*)
			echo "sled11Build.sh: Invalid Parameter ${1}"
			shift # Past argument
			exit 255
			;;

	esac

done

function debug() {

	if [[ -n "${DEBUG}" ]]; then

		echo -e "sled11Build.sh: DEBUG: ${1}"

	fi

}

# Debug logging
if [[ -n "${DEBUG}" ]]; then
	echo "DEBUG ENABLED"
	if [[ -n "${NOOPT}" ]]; then    echo "NOOPT    = ${NOOPT}"; fi
	if [[ -n "${UNITTEST}" ]]; then echo "UNITTEST = ${UNITTEST}"; fi
fi

# First thing's first, we need to make sure this script is called in
#  The sled11 suse buildbox. We do this by checking the md5sum of the
#  file "/etc/SuSE-release"

source buildBoxValidation.sh >/dev/null
RET="${?}"

# Check the value returned from buildBoxValidation.sh
if [[ "${RET}" == 0 ]]; then

	# Confirmation that we are on sled11
	debug "We are running on the sled11 buildBox."

else

	if [[ -z "${UNITTEST}" ]]; then

		# Tell the user that the environment is wrong
		echo "sled11Build.sh: Running on wrong build environment!"

		# Only exit if we're not unittesting
		exit 255

	fi

fi

BUILDFILE="../wslBuildCommands.dat"
BUILDCOMMANDS=()
OUTFILE="../wslBuild.dat"

debug "CWD: $(pwd)"

# We only read the entries if NOOPT Is not set
# And if the file exists
if [[ -z "${NOOPT}" && -f "${BUILDFILE}" ]]; then

	debug "Reading ${BUILDFILE}."

	# Read the contents of BUILDFILE into BUILDCOMMANDS

	# While loop to iterate over each line in BUILDFILE
	while IFS= read -r LINE; do

		debug "Line: ${LINE}"

		# Check line length
		if [[ -z "${LINE}" ]]; then

			# Debug that an empty line was read
			debug "Line was empty."

			# Continue past this line item
			continue

		fi

		# Check to make sure it isn't commented out
		if ! [[ "${LINE:0:1}" == "#" ]]; then

			# Add this line to the BUILDCOMMANDS array.
			BUILDCOMMANDS+=( "${LINE}" )

		fi

	done < "${BUILDFILE}"

fi

debug "Build Commands: ${BUILDCOMMANDS[@]}"

# Function to call below
function buildCommand() {

	# Create the buildCommand
	BUILDCMD='make clean && make'

	# If length of BUILDCOMMANDS is greater than 0
	if [[ "${#BUILDCOMMANDS[@]}" -gt 0 ]]; then

		# For each command in the array
		for CMD in "${BUILDCOMMANDS[@]}"; do

			# Add the CMD to BUILDCMD
			BUILDCMD="${CMD} && ${BUILDCMD}"

			debug "${BUILDCMD}"

		done

	fi

	echo "${BUILDCMD}"

}

# If unittesting is enabled
if [[ -n "${UNITTEST}" ]]; then

	# We want to echo the command not execute it
	echo "$(buildCommand)"

else

	# We want to execute the command
	eval $(buildCommand) 2>&1 | tee "${OUTFILE}"

fi
