#!/bin/bash


# I am re-writing this script to address issues with "local -n" in older bash releases
#  -n is not recognized as a valid option for local variable declarations
#  And thus fileTools.sh and userInterface.sh will not work on sled11 buildbox
#  These commands will have to be executed in another distro to work properly.


# At build time, this script will execute another script "sled11Build.sh" that will
#  Handle building the code itself from the sled11 environment

# Argument handling

while [[ "${#}" -gt 0 ]]; do

	case "${1}" in

		# nobackup
		--nobackup)
			NOBACKUP=1
			shift # Past argument
			;;

		# noopt
		--noopt)
			NOOPT=1
			shift # Past argument
			;;

		# noinit
		--noinit)
			NOINIT=1
			shift # Past argument
			;;

		# unit testing
		--unittest)
			UNITTEST=1
			shift # Past argument
			;;

		# debug enable
		-d|--debug)
			DEBUG=1
			shift # Past argument
			;;

	esac

done

function debug() {

	if [[ -n "${DEBUG}" ]]; then

		echo -e "wslBuild.sh: DEBUG: ${1}"

	fi

}

if [[ -n "${DEBUG}" ]]; then

	# Debug logging
	if [[ -n "${NOBACKUP}" ]]; then echo "NOBACKUP = ${NOBACKUP}"; fi
	if [[ -n "${NOOPT}" ]]; then echo "NOOPT = ${NOOPT}"; fi
	if [[ -n "${NOINIT}" ]]; then echo "NOINIT = ${NOINIT}"; fi
	if [[ -n "${UNITTEST}" ]]; then echo "UNITTEST = ${UNITTEST}"; fi

fi

# Before we do anything, we need to make sure we are in a server or ccl directory
CURDIR=${pwd##*/}
CURDIR=${CURDIR:-/}

# If the current directory is not server or ccl
if ! [[ "${CURDIR}" == "server" || "${CURDIR}" == "ccl" ]]; then

	# The directory was not server or ccl
	debug "Current Directory: ${CURDIR} was invalid."
	exit 255

fi

# I am changing the backup routine.
# The new backup routine will save off a backup upon a successful build
# To figure out if we have a successful build, we will grep the file
# ../wslBuild.dat for the md5 sum.

# IF the md5 sum is there, then we know we made it though the build process
function backup() {

	debug "Making Backup"

	local BUILDFILE="../wslBuild.dat"

	# Look for the file "../wslBuild.dat"
	if [[ -f "${BUILDFILE}" ]]; then

		# If the file did not contain an md5
		if [[ -z $(grep "MD5(" "${BUILDFILE}") ]]; then

			echo "wslBuild.sh: Backup failed - No MD5 found!"
			exit 255

		fi

		# We should have a valid MD5 to use
		local MD5=$(grep "MD5(" "${BUILDFILE}")
		MD5=${MD5: -4}

		# Get the current date and time.
		local DATETIME=$(date '+%Y-%m-%d_%H-%M')

		# Build the directory name for this backup
		local BACKDIR="../backups/${MD5}_${DATETIME}"

		debug "Backup directory: ${BACKDIR}"

		# Make the directory for the backup
		mkdir -p "${BACKDIR}"

		# Code variable
		local CODE=""

		# If we are in the server directory
		if [[ "${CURDIR}" == "server" ]]; then

			# Set the code variable to "NewServer3.tgz"
			CODE="NewServer3.tgz"

		# If we are in the ccl directory
		elif [[ "${CURDIR}" == "ccl" ]]; then

			# Set the code variable to "NewCCL.tgz"
			CODE="NewCCL.tgz"

		fi

		# Save a copy of the tgz in the backup dir
		scp "${CODE}" "${BACKUPDIR}"

		# If wslBuildCommands.txt exists
		if [[ -f "../wslBuildCommands.txt" ]]; then

			# Save a copy of it too
			scp "../wslBuildCommands.txt" "${BACKUPDIR}"

		fi

		# Save a copy of wslBuild.dat
		scp "$PBUILDFILE}" "${BACKUPDIR}"

		debug "Backup made at ${BACKUPDIR}"	

	fi


}
