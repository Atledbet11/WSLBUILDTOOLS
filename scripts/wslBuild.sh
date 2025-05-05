#!/bin/bash

# Validate that we are on the sled11 buildbox.
source buildBoxValidation.sh
ret=$?

# Check the return value from the validation script
if [ $ret = 0 ]; then

	# Confirmation that we are running on the buildbox and not another distro.
        echo "Running from buildbox."

else

	# Tell the user that the environment is wrong, and exit with an error.
        echo "Wrong build environment!"
	exit 1

fi

echo "Build Script Begin"

# Source fileTools.sh
source fileTools.sh

# Adding proper argument handling into the script for those who dare to improve upon this script

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do

	case $1 in 

		# Backup flag
		-b|--backup)
			BACKUP=1
			shift
			;;

		# Skip Initialization For building From VSCODE
		-n|--noinit)
			NOINIT=1
			shift
			;;

		# Error catching
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;

		# Saves the positional argument
		*)
			POSITIONAL_ARGS+=("$1")
			shift
			;;

	esac

done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Logging
echo "Backup = ${BACKUP}"
echo "NoInit = ${NOINIT}"

# The file containing buildtime commands
fileName="../wslBuildCommands.txt"

# Declares an array to store the file contents into
declare -a FileData

# Reads the file at $fileName and stores the data into FileData
function readFile() {

	# While loop to iterate over each line in $fileName
	while IFS= read -r line
	do

		# Check to make sure the line has a valid length to simplify code below
		if [[ -z $line ]]; then

			# Display that an empty line was read
			echo "Ignoring empty line"

			# Continue and ignore this line item
			continue

		fi

		# Check to make sure this isn't commented out
		if ! [[ ${line:0:1} == "#" ]]; then

			# Add this line to the FileData Array.
			FileData+=( "$line" )

		fi

	done < "$fileName"

}

# Backup
# Saves a copy of NewServer3.tgz or NewCCL.tgz and its associated wslBuildCommands.dat and wslBuild.dat information.
function backup() {

	# Making Backup
	echo "Making Backup"

	# Current date and time.
	dateTime=$(date '+%Y-%m-%d_%H:%M:%S')

	# Current directory minus the path.
	curdir=${PWD##*/}
	curdir=${curdir:-/}

	echo "$curdir"

	# Where we will save the backup.
	backdir="${dateTime}"

	# Check to see if ../wslBuild.dat exists.
	if [ -f "../wslBuild.dat" ]; then
		md5=$(grep "MD5(" "../wslBuild.dat")
		md5=${md5: -4}

		# Add the md5 to the backup path name.
		backdir="${md5}_${dateTime}"

	fi

	# Print the backup directory name.
	echo "$backdir"

	# Create the directory to save the backups into.
	mkdir "../${backdir}"

	# If we are in a server directory.
	if [ $curdir == "server" ]; then

		# Check to see if the file NewServer3.tgz exists.
		if [ -f "NewServer3.tgz" ]; then

			# Save a copy of the code.
			scp "NewServer3.tgz" "../${backdir}"

		fi

	fi

	# If we are in a ccl directory.
	if [ $curdir == "ccl" ]; then

		# Check to see if the file NewCCL.tgz exists.
		if [ -f "NewCCL.tgz" ]; then

			# Save a copy of the code.
			scp "NewCCL.tgz" "../${backdir}"

		fi

	fi

	# If we have wslBuildCommands.txt.
	if [ -f "../wslBuildCommands.txt" ]; then

		# Save a copy of the buildCommands.
		scp "../wslBuildCommands.txt" "../${backdir}"

	fi

	# If we have wslBuild.dat.
	if [ -f "../wslBuild.dat" ]; then

		# Save a copy of the wslBuild data.
		scp "../wslBuild.dat" "../${backdir}"

	fi

	# Backup Made
	echo "Backup Made"

}

# Initialization
# Check to make sure fileName exists - create it if its not found.
#  If the file was not found open it in fileTools - basic text editor.
function init() {

	# If the file does not exist.
	if ! [ -f "$fileName" ]; then

		# Create it with fileManager.sh.
		fileEditor "$fileName"

	fi

	# Read the file.
	readFile

}



# If -b backup the old code before we continue
if [[ $BACKUP == 1 ]]; then

	# Call backup function.
	backup

fi

# If -n skip initialization
if [[ $NOINIT == 1 ]]; then

	# Skip Initialization
	echo "Skipping Initialization"

else

	# Initialization
	init

fi

# This will create the make command.
function buildCommand() {

	# Get the length of the FileData Array.
	lengthOfArray=${#FileData[@]}

	# Default value for the build command.
	buildCMD='make clean && make'

	# For each item in the FileData array.
	for i in $(seq 0 $(( lengthOfArray - 1)))
	do

		# Add the line contents to the build command.
		buildCMD="${FileData[i]} && $buildCMD"

	done

	# This serves as the return out of the function and is required for this to work.
	echo "$buildCMD"

}

# Log to the user their build command that was built.
echo "Build Command: $(buildCommand)"
eval $(buildCommand) 2>&1 | tee ../wslBuild.dat
