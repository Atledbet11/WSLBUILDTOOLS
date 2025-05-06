#!/bin/bash


# I am re-writing this script to address issues with "local -n" in older bash releases
#  -n is not recognized as a valid option for local variable declarations
#  And thus fileTools.sh and userInterface.sh will not work on sled11 buildbox
#  These commands will have to be executed in another distro to work properly.

source fileTools.sh

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

		# nodiff
		--nodiff)
			NODIFF=1
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
	if [[ -n "${NOOPT}" ]]; then    echo "NOOPT    = ${NOOPT}"; fi
	if [[ -n "${NOINIT}" ]]; then   echo "NOINIT   = ${NOINIT}"; fi
	if [[ -n "${NODIFF}" ]]; then   echo "NODIFF   = ${NODIFF}"; fi
	if [[ -n "${UNITTEST}" ]]; then echo "UNITTEST = ${UNITTEST}"; fi

fi

# Before we do anything, we need to make sure we are in a server or ccl directory
CURDIR=${PWD##*/}
CURDIR=${CURDIR:-/}

# If the current directory is not server or ccl
if ! [[ "${CURDIR}" == "server" || "${CURDIR}" == "ccl" ]]; then

	# The directory was not server or ccl
	echo "Current Directory: ${CURDIR} was invalid."
	exit 255

fi

# Variables
BUILDFILE="../wslBuild.dat"
COMMANDFILE="../wslBuildCommands.dat"
DIFFFILE="../wslDiff.dat"
DIFFFILES=()

# I am changing the backup routine.
# The new backup routine will save off a backup upon a successful build
# To figure out if we have a successful build, we will grep the file
# ../wslBuild.dat for the md5 sum.

# IF the md5 sum is there, then we know we made it though the build process
function backup() {

	debug "Making Backup"

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
		local BACKDIR="../backups/${MD5}_${DATETIME}/"

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
		scp "${CODE}" "${BACKDIR}"

		# If wslBuildCommands.dat exists
		if [[ -f "${COMMANDFILE}" ]]; then

			# Save a copy of it too
			scp "${COMMANDFILE}" "${BACKDIR}"

		fi

		# If wslDiff.dat exists
		if [[ -f "${DIFFFILE}" ]]; then

			# Save a copy of it too
			scp "${DIFFFILE}" "${BACKDIR}"

		fi

		# Save a copy of wslBuild.dat
		scp "${BUILDFILE}" "${BACKDIR}"

		debug "Backup made at ${BACKDIR}"

		# If the user has diff enabled
		if [[ "${NODIFF}" != 1 ]]; then

			# For each file in array DIFFFILES
			for FILE in "${DIFFFILES[@]}"; do

				debug "Backing up file ${FILE}"

				# Backup the file that had differences
				scp "${FILE}" "${BACKDIR}"

			done

		fi

	else

		debug "File ../wslBuild.dat did not exist!"

	fi

}

# Differences
# This will run a cvs diff and populate DIFFFILES with the files
#  That were edited.
function diffRepo() {

	# Tell the user we are doing a CVS diff
	echo "wslBuild.sh: Doing CVS diff"
	echo "Please provide CVS Passcode"
	echo "--nodiff will disable this."

	# Create the wslDiff.dat
	cvs diff > "${DIFFFILE}"

	# At this point we should have a DIFFFILE
	# grep for "Index: "
	#  This will return lines that contain diffed filenames
	RESULTS=$(grep "^Index: " "${DIFFFILE}")

	# Split the results from grep at '\n' and store results into DIFFFILES
	IFS=$'\n' read -r -d '' -a DIFFFILES <<< "${RESULTS}" || true

	debug "${DIFFFILES[@]}"

	# For each file that had differences
	for i in $( seq 0 "${#DIFFFILES[@]}"); do

		# Strip off the "Index: " part from the file
		DIFFFILES["${i}"]=${DIFFFILES["${i}"]//"Index: "/}

	done

	# Check to see if the last index is a blank line
	if [[ "${#DIFFFILES[-1]}" == 0 ]]; then

		# Unset the last index from DIFFFILES
		unset 'DIFFFILES[-1]'

	fi

	# Now DIFFFILES will contain all the filenames that had differences

}

# Initialization
# this will initialize wslBuildCommands.txt if it did not exist
# Checks to make sure NOINIT=0
function init() {

	debug "Doing init"

	# If the file does not exist
	if ! [[ -f "${COMMANDFILE}" ]]; then

		# Create the file, and let the user populate it
		fileEditor "${COMMANDFILE}" -i

	fi

}

# Make sure init is enabled
if [[ "${NOINIT}" != 1 ]]; then

	# Initialize the COMMANDFILE
	init

fi

# directory we are to return to
CODEDIR=$(pwd)

# Change to a windows directory
# This is in order to avoid errors with path parsing
cd "/mnt/c"

# Now we can call sled11Build.sh in its wsl environment.
wsl.exe -d sled11 cd ${CODEDIR} \&\& sled11Build.sh

cd "${CODEDIR}"

# Perform a DIFF into wslDiff.dat if the user wishes to
if [[ "${NODIFF}" != 1 ]]; then

	# Runn the Diff function
	diffRepo

fi

# Now that the command has been run we can try making a backup
if [[ "${NOBACKUP}" != 1 ]]; then

	# Backup the files
	backup

fi