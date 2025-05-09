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

		# Help
		-h|--help)
			HELP=1
			shift # Past argument
			;;

		# debug enable
		-d|--debug)
			DEBUG=1
			shift # Past argument
			;;

		# Auto deploy
		-a|--autodeploy)
			AUTODEPLOY=1
			shift # Past argument
			;;

		# Error Handling
		*)
			echo "wslBuild.sh: Invalid Parameter ${1}!"
			shift # Past argument
			exit 255
			;;

	esac

done

# If the user requested help
if [[ -n "${HELP}" ]]; then

	# Log the filename
	echo "Help page for wslBuild.sh"

	# Log the purpose of each argument/parameter
	echo "PARAMETER    : FUNCTIONALITY"
	echo "--nobackup   : Disables backup functionality"
	echo "--noinit     : Will not create ../wslBuildCommands.dat"
	echo "--nodiff     : Disables diff functionality"
	echo "--autodeploy : Will deploy and verify this code was loaded"
	echo "             : Requires SITECON_IP in ../wslBuildCommands.dat"
	echo "--unittest   : For unittesting only"
	echo "--debug      : Enables debug printing"

	# Exit without error
	exit 0

fi

function debug() {

	if [[ -n "${DEBUG}" ]]; then

		echo -e "wslBuild.sh: DEBUG: ${1}"

	fi

}

if [[ -n "${DEBUG}" ]]; then

	# Debug logging
	if [[ -n "${NOBACKUP}" ]]; then   echo "NOBACKUP   = ${NOBACKUP}"; fi
	if [[ -n "${NOINIT}" ]]; then     echo "NOINIT     = ${NOINIT}"; fi
	if [[ -n "${NODIFF}" ]]; then     echo "NODIFF     = ${NODIFF}"; fi
	if [[ -n "${UNITTEST}" ]]; then   echo "UNITTEST   = ${UNITTEST}"; fi
	if [[ -n "${AUTODEPLOY}" ]]; then echo "AUTODEPLOY = ${AUTODEPLOY}"; fi

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
CHECKSUM=""
MD5=""

# I am changing the backup routine.
# The new backup routine will save off a backup upon a successful build
# To figure out if we have a successful build, we will grep the file
# ../wslBuild.dat for the md5 sum.

# IF the md5 sum is there, then we know we made it though the build process
function backup() {

	debug "Making Backup"

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

		# We need to source fileTools.sh
		source fileTools.sh

		# Create the file, and let the user populate it
		fileEditor "${COMMANDFILE}" -i

	fi

}

# Auto Deploy
# This will run an exit3 and look for the results in the log
function autoDeploy() {

	# Make sure that we have a SITECON_IP to deploy to.
	#  First make sure the file ../wslBuildCommands.dat exists
	if ! [[ -f "${COMMANDFILE}" ]]; then

		# Tell the user the file did not exist
		echo "wslBuild.sh: The file ${COMMANDFILE} does not exist!"

		# Return with error
		return 255

	fi

	#  If the file exists, grep it for the SITECON_IP value
	local RESULT=$(grep "^export SITECON_IP=" "${COMMANDFILE}")

	if [[ -z "${RESULT}" ]]; then

		# Tell the user to provide a SITECON_IP
		echo "wslBuild.sh: SITECON_IP missing from ${COMMANDFILE}"

		# Return with error
		return 255

	fi

	# Now we want to split the line at "=" and take the second half.
	SITECONIP=$(echo "${RESULT}" | cut -d '=' -f2- )

	debug "SITECON IP: ${SITECONIP}"

	# We need to source userInputValidation.sh
	source userInputValidation.sh

	# Validate that the IP is valid.
	userInputValidation -u "${SITECONIP}" -ip
	RET="${?}"

	# RET will be 0 if the IP is valid
	if [[ "${RET}" != 0 ]]; then

		# Tell the user the IP is invalid
		echo "IP: ${SITECONIP} was invalid!"

		# Return with error
		return 255

	fi

	# Initialize exit3 Command
	local EXIT3COMMAND=()

	# Initialize validation Command
	local VALIDATIONCOMMAND=()

	# Commands will differ between the SC and CCL
	if [[ "${CURDIR}" == "server" ]]; then

		# Exit 3 Command
		EXIT3COMMAND+=( "cd /home/sitecon/sc" ) 
		EXIT3COMMAND+=( "./supportConsole 127.0.0.1 exit3" )

		# Grep command for the CHECKSUM
		VALIDATIONCOMMAND+=( "grep -i ${CHECKSUM} /home/sitecon/sc/Syslog.dat" )

		# Set validation user incase there are file permission issues
		VALIDATIONUSER="-s"

		# Set the sleeptime to 20s for SC code
		SLEEPTIME=20s

	elif [[ "${CURDIR}" == "ccl" ]]; then

		# Exit 3 Command
		EXIT3COMMAND+=( "cd /home/sitecon/sc" ) 
		EXIT3COMMAND+=( "./supportConsole 127.0.0.1 -noauth -port 4557 exit3" )

		# Grep command for the CHECKSUM
		VALIDATIONCOMMAND+=( "grep -i ${CHECKSUM} /home/ccl/ccl/CCLlog.dat" )

		# Set validation user incase there are file permission issues
		VALIDATIONUSER="-c"

		# Set the sleeptime to 5s for CCL code
		SLEEPTIME=5s

	fi

	# We need to source auto.sh
	source auto.sh

	# Run the exit 3 command using auto
	auto "${SITECONIP}" -s --cmd EXIT3COMMAND

	# Sleep for 10s to give the code a chance to load
	sleep "${SLEEPTIME}"

	# Run the validation command using auto
	RESULT=$(auto "${SITECONIP}" "${VALIDATIONUSER}" --cmd VALIDATIONCOMMAND)

	# Now we should make sure that the Validation was successful and notify the user.
	if [[ -n $(echo "${RESULT}" | grep ${CHECKSUM}) ]]; then

		# Notify the user that the code was loaded successfully
		echo "The code with checksum (${CHECKSUM}) is loaded on sitecontroller ${SITECONIP}."

	else

		# Notify the user that the code may not be loaded
		echo "Unable to verify that the code with checksum (${CHECKSUM}) was loaded!"

		# Return with error
		return 255

	fi

	return 0

}

# Make sure init is enabled
if [[ "${NOINIT}" != 1 ]]; then

	debug "Running init."

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

# Look for the file "../wslBuild.dat"
if [[ -f "${BUILDFILE}" ]]; then

	# If the file did not contain an md5
	if [[ -z $(grep "MD5(" "${BUILDFILE}") ]]; then

		echo "wslBuild.sh: Build failed - No MD5 found!"
		exit 255

	fi

	# We should have a valid MD5 to use
	MD5=$(grep "^MD5(" "${BUILDFILE}")
	
	# Split the MD5 line at " " and return the data after the " "
	# This checksum is used in the auto deploy routine
	CHECKSUM=$(echo "${MD5}" | cut -d ' ' -f2- )
	echo "CHECKSUM: ${CHECKSUM}"
	
	# This value is used in the backup routine
	MD5=${MD5: -4}

else

	# There was no wslBuild.dat
	echo "wslBuild.sh: ${BUILDFILE} not found!"
	exit 255

fi

# Perform a DIFF into wslDiff.dat if the user wishes to
if [[ "${NODIFF}" != 1 ]]; then

	debug "Running diffRepo."

	# Runn the Diff function
	diffRepo

fi

# Now that the command has been run we can try making a backup
if [[ "${NOBACKUP}" != 1 ]]; then

	debug "Running backup."

	# Backup the files
	backup

fi

# If autodeploy is enabled
if [[ -n "${AUTODEPLOY}" ]]; then

	debug "Running autoDeploy."

	# AutoDeploy
	autoDeploy

fi
