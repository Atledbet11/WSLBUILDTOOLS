#!/bin/bash

# This file is meant to be sourced, not executed.

# Only runs if the script is being directly executed.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

        echo "fileTools.sh: Script is being executed directly"
	echo "Do not execute this script, use source fileTools.sh"

	exit 255

# Only runs if the script is being sourced.
else
	echo "fileTools.sh: Script is being sourced."
fi

source userInputValidation.sh
source userInterface.sh

# Create file
#  Parameters
#  -f|--filename  = Name for the file
#  -p|--perm      = File permission value for chmod
#  -d|--debug     = Debug enable
# arguments that are not parameters will be interpreted as filenames
# Usage:
#	createFile filename.txt
#	createFile -f filename.txt
#	createFile -f filename.txt -p 777
function createFile() {

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# File
			-f|--filename)
				local CREATEFILENAME="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Permission
			-p|--perm)
				local PERM="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Debug
			-d|--debug)
				local DEBUG=1
				shift # Past argument
				;;

			# Default
			*)
				if [[ -z "${CREATEFILENAME}" ]]; then
					local CREATEFILENAME="${1}"
				fi
				shift # Past value
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:createFile() Invalid parameter ${1}"
				return 255
				;;

		esac

	done

	# Make sure that a file was provided
	if [[ -z "${CREATEFILENAME}" ]]; then
		echo "fileTools.sh:createFile() File parameter required!"
		return 255
	fi

	# Make sure the permissions are valid
	if [[ -n "${PERM}" ]]; then

		# Validate this will work as a chmod permission
		userInputValidation.sh -u "${PERM}" --chmod

		# Check the return code on userInputValidation.sh
		# 0 was a pass 255 was a fail
		if [[ "${?}" == 255 ]]; then

			echo "fileTools.sh:createFile() Invalid file permissions!"
			return 255

		fi
	# Otherwise set default permissions to 755
	else

		local PERM=755

	fi

	if [[ -n "${DEBUG}" ]]; then echo "fileTools.sh: Creating file ${CREATEFILENAME} with permissions (${PERM})"; fi

	touch "${CREATEFILENAME}"

	chmod "${PERM}" "${CREATEFILENAME}"

	# Return with no error
	return 0

}

# Backup the file.
#  Parameters
#  -f|--filename  = Name for the file
#  -d|--debug     = Debug enable
# arguments that are not parameters will be interpreted as filenames
# Usage:
#	backupFile filename.txt
#	backupFile -f filename.txt
function backupFile() {

	local POSITIONAL_ARGS=()

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# File
			-f|--filename)
				local FILENAME="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Debug
			-d|--debug)
				local DEBUG=1
				shift # Past argument
				;;

			# Default
			*)
				if [[ -z "${FILENAME}" ]]; then
					local FILENAME="${1}"
				fi
				shift # Past value
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:backupFile() Invalid parameter ${1}"
				return 255
				;;

		esac

	done

	# Restore positional parameters - although this shouldnt have any
	set -- "${POSITIONAL_ARGS[@]}"

	# Make sure that a file was provided
	if [[ -z "${FILENAME}" ]]; then
		echo "fileTools.sh:backupFile() File parameter required!"
		return 255
	fi

	# If the file did not exist
	if ! [[ -f "${FILENAME}" ]]; then

		# Error logging
		echo "fileTools.sh:backupFile() File did not exist to backup!"

		# return code
		return 255

	fi

	if [[ -n "${DEBUG}" ]]; then echo "fileTools.sh Making backup of file ${FILENAME}"; fi

	# Copy a backup of the file
	cp "${FILENAME}" "${FILENAME}.bak"

	# Return without error
	return 0

}

# Reads the contents of the FILENAME into FILEARRAY
#  Parameters
#  -f|--filename  = File to be read into filearray
#  -a|--filearray = Array name to store file contents
# arguments that are not parameters will be interpreted as filenames
# Usage:
#	readFile filename.txt -a ARRAY
#	readFile -f filename.txt -a ARRAY
function readFile() {

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# FILE
			-f|--filename)
				local FILENAME="${2}"
				shift # Past argument
				shift # Past value
				;;

			-a|--filearray)
				local -n READARRAY="${2}"
				shift # Past argument
				shift # Past value
				;;

			*)
				local FILENAME="${1}"
				shift # Past argument
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:readFile() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	if [[ -n "${FILENAME}" ]]; then  echo "fileTools.sh:readFile() FILENAME  = ${FILENAME}"; fi
	if [[ -n "${READARRAY}" ]]; then echo "fileTools.sh:readFile() FILEARRAY = ${READARRAY[@]}"; fi

	# Check to see if the file exists
	if ! [[ -f "${FILENAME}" ]]; then

		echo "fileTools.sh:readFile() ${FILENAME} does not exist!"
		return 255

	fi

	# Clear the FILEARRAY
	READARRAY=()

	# While loop to read the file
	while IFS= read -r LINE; do

		# Add the line to the FILEARRAY
		READARRAY+=( "${LINE}" )

	done < "${FILENAME}"

	# Return true
	return 0

}

# Saves the file
#  Parameters
#  -f|--filename  = Name of the file
#  -a|--filearray = Contents to save to the file
#  -n|--nobackup  = Disable backup functionality
# Usage
#	saveFile -f FILENAME -a ARRAY
#	saveFile -f FILENAME -a ARRAY -n
function saveFile() {

	local LINE

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Filename
			-f|--filename)
				local FILENAME="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Filearray
			-a|--filearray)
				local -n SAVEARRAY="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Disable Backup
			-n|--nobackup)
				local NOBACKUP=1
				shift # Past argument
				;;

			# Error Handling
			*)
				echo "fileTools.sh:saveFile() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	# Make sure we have a filename and file array
	if [[ -z "${FILENAME}" || -z "${SAVEARRAY}" ]]; then

		# We require both of the above.
		echo "fileTools.sh:saveFile() You must supply a filename and contents to write!"
		return 255

	fi

	if [[ -z "${NOBACKUP}" ]]; then

		backupFile -f "${FILENAME}"

	fi

	# Get the length of the array
	local LENGTH="${#SAVEARRAY}"

	# Overwrite the file with the first line from the array
	echo "${SAVEARRAY[0]}" > "${FILENAME}"

	# For each remaining line in the array
	for LINE in "${SAVEARRAY[@]:1}"; do

		# Add the line to the end of the file
		echo "${LINE}" >> "${FILENAME}"

	done

	# Return
	return 0

}

# Prints the file array
#  Parameters
#  -f|--filename  = File to be printed
#  -a|--filearray = Array to be printed
function printFile() {

	local LINENUM=0
	local LINE
	local MUTUALLY_EXCLUSIVE=0

	function exclusivity() {

		# Check if MUTUALLY_EXCLUSIVE is set
		if [[ "${MUTUALLY_EXCLUSIVE}" == 1 ]]; then

			# return with error
			echo "fileTools.sh:printFile() To many parameters!"
			return 255

		fi

		MUTUALLY_EXCLUSIVE=1

	}

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# For printing file at filename
			-f|--filename)
				local PRINTFILENAME="${2}"
				exclusivity
				shift # Past argument
				shift # Past value
				;;

			# For printing file array
			-a|--filearray)
				local -n PRINTARRAY="${2}"
				exclusivity
				shift # Past argument
				shift # Past value
				;;

			# Error Handling
			*)
				echo "fileTools.sh:printFile() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	# Make sure a parameter was provided
	if [[ "${MUTUALLY_EXCLUSIVE}" -ne 1 ]]; then

		# Error
		echo "fileTools.sh:printFile() You must supply a valid parameter"
		return 255

	fi

	# If FILENAME was specified, then we read the file first into local array
	if [[ -n "${PRINTFILENAME}" ]]; then

		PRINTARRAY=()

		readFile -f "${PRINTFILENAME}" -a PRINTARRAY

	fi

	# Now we can print from the FILEARRAY
	# For each line in the array
	for LINE in "${PRINTARRAY[@]}"; do

		echo "${LINENUM}: ${LINE}"

		let LINENUM++

	done

	return 0

}

# Adds the line into the file or filearray provided
#  Parameters
#  -f|--filename  = File to add the line to
#  -a|--filearray = Array to add the line to
#  -l|--line      = Line to add to the array
# arguments that are not parameters will be interpreted as lines to add to the array
# Usage:
#	addLine -a ARRAY -l "export SITECON_IP=192.168.1.100"
#	addLine "export SITECON_IP=192.168.1.100" -a ARRAY
function addLine() {

	local MUTUALLY_EXCLUSIVE=0

	function exclusivity() {

		# Check if MUTUALLY_EXCLUSIVE is set
		if [[ "${MUTUALLY_EXCLUSIVE}" == 1 ]]; then

			# return with error
			echo "fileTools.sh:addLine() To many parameters!"
			return 255

		fi

		MUTUALLY_EXCLUSIVE=1

	}

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# File to add the line to
			-f|filename)
				local READFILENAME="${2}"
				exclusivity
				shift # Past argument
				shift # Past value
				;;

			# Array to add the line to
			-a|--filearray)
				local -n ADDARRAY="${2}"
				exclusivity
				shift # Past argument
				shift # Past value
				;;

			# Line to add to the array
			-l|--line)
				local LINE="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Catch line without parameter
			*)
				local LINE="${1}"
				shift # Past value
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:addLine() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	if [[ -n "${READFILENAME}" ]]; then echo "FILENAME: ${READFILENAME}"; fi

	if [[ "${MUTUALLY_EXCLUSIVE}" -ne 1 ]]; then

		# Error
		echo "fileTools.sh:addLine() You must supply a valid parameter!"
		return 255

	fi

	# If we have a filename, and not a file array, read in the array.
	if [[ -n "${READFILENAME}" ]]; then

		# Read in the file
		readFile -f "${READFILENAME}" -a "${SAVEARRAY}"

	fi

	# Now we can add the line to the ADDARRAY
	ADDARRAY+=( "${LINE}" )

	# If we have a filename, we need to save the changes to the file.
	if [[ -n "${READFILENAME}" ]]; then

		# Save to the file
		saveFile -f "${READFILENAME}" -a "${SAVEARRAY}"

	fi

	# Return
	return 0

}

# Toggle the comment on the line number in the array.
#  Parameters
#  -a|--filearray = Array to be edited
#  -n|--number    = Line number to be commented
# arguments that are not parameters will be interpreted as line numbers
# Usage
#	commentLine -a ARRAY -n 3
#	commentLine -a ARRAY 3
function commentLine() {

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Filearray
			-a|--filearray)
				local -n COMMENTARRAY="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Line Number
			-n|--number)
				local COMMENTLINE="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Default
			*)
				local COMMENTLINE="${1}"
				shift # Past argument
				shift # Past value
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:commentLine() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	# Make sure that we have an array and a number
	if [[ -z "${COMMENTARRAY}" || -z "${COMMENTLINE}" ]]; then

		echo "fileTools.sh:commentLine() Must provide an array and number!"
		return 255

	fi

	# Make sure that lineNumber is a valid integer
	userInputValidation -u "${COMMENTLINE}" -i
	if [[ "${?}" -ne 0 ]]; then

		# Invalid integer
		echo "fileTools.sh:commentLine() ${COMMENTLINE} is not a valid integer!"
		return 255

	fi

	# Make sure that lineNumber is within the contents of array.
	if [[ "${COMMENTLINE}" -ge "${#COMMENTARRAY[@]}" ]]; then

		echo "LN: ${COMMENTLINE} LEN: ${#COMMENTARRAY[@]}"

		# Invalid line number
		echo "fileTools.sh:commentLine() The array does not have a line ${COMMENTLINE}"
		return 255

	fi

	# LINEVALUE
	local LINEVALUE="${COMMENTARRAY[${COMMENTLINE}]}"

	# Now we should be safe to comment the line.
	# If the line was already commented out
	if [[ "${LINEVALUE:0:1}" == "#" ]]; then

		# Debug
		echo "fileTools.sh:commentLine() Uncommenting line ${COMMENTLINE}"

		# Overwrite the line in the file array
		COMMENTARRAY["${COMMENTLINE}"]="${LINEVALUE:1}"

	# We need to comment out the line
	else

		# Debug
		echo "fileTools.sh:commentLine() Commenting line ${COMMENTLINE}"

		# Overwrite the line in the file array
		COMMENTARRAY["${COMMENTLINE}"]="#${LINEVALUE}"

	fi

	return 0

}

# Prompts the user to edit the line specified in the array
#  Parameters
#  -a|--filearray = Array to be edited
#  -n|--number    = Linenumber in the array to be edited
#  -i|--inline    = Provides line value for ease of editing
#                 # Note: This may not work on older bash versions
# arguments that are not parameters will be interpreted as linenumber
# Usage:
# 	editLine -a ARRAY -n 2
#	editLine -a ARRAY -n 0 -i
function editLine() {

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# FILE ARRAY
			-a|--filearray)
				local -n EDITARRAY="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Line Number
			-n|--number)
				local EDITLINE="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Inline
			-i|--inline)
				local INLINE=1
				shift # Past argument
				;;

			# Default
			*)
				local EDITLINE="${1}"
				shift # Past argument
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:editLine() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	# Make sure they provide an array and linenumber
	if [[ -z "${EDITARRAY}" || -z "${EDITLINE}" ]]; then

		echo "fileTools.sh:editLine() You must provide an array and line number!"
		return 255

	fi

	echo "Line Number: ${EDITLINE}"

	# Make sure that the line number is a valid integer
	userInputValidation -u "${EDITLINE}" -i
	if [[ "${?}" -ne 0 ]]; then

		echo "fileTools.sh:editLine() ${EDITLINE} is not an integer!"
		return 255

	fi

	# Make sure that the index is valid
	if [[ "${EDITLINE}" -ge "${#EDITARRAY[@]}" ]]; then

		echo "fileTools.sh:editLine() Invalid line number!"
		return 255

	fi

	# Read in the line that the user wishes to edit
	local LINEVALUE=$(echo "${EDITARRAY[${EDITLINE}]}" | tr -d '\r')

	echo "LINEVALUE: ${LINEVALUE}"

	# Check if we are editing inline or not
	if [[ "${INLINE}" == 1 ]]; then

		# Read in the user's edits with inline allowed
		read -re -i "${LINEVALUE}" LINEVALUE

	else

		# Read in the user's edits without inline allowed
		read -re LINEVALUE

	fi

	# Update this line in the file array
	EDITARRAY["${EDITLINE}"]="${LINEVALUE}"

	# Return
	return 0

}

# Deletes the line number from the file array
#  Parameters
#  -a|--filearray = Array to delete the line from
#  -n|--number    = Line number to be deleted
# arguments that are not parameters will be interpreted as line numbers
# Usage:
#	deleteLine -a ARRAY -n 3
#	deleteLine -a ARRAY 3
function deleteLine() {

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Filearray
			-a|--filearray)
				local -n DELETEARRAY="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Line Number
			-n|--number)
				local DELETELINE="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Default
			*)
				local DELETELINE="${1}"
				shift # Past argument
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:deleteLine() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	# Make sure they provide an array and linenumber
	if [[ -z "${DELETEARRAY}" || -z "${DELETELINE}" ]]; then

		echo "fileTools.sh:deleteLine() You must provide an array and linenumber!"
		return 255

	fi

	# Make sure that the line number is a valid integer
	userInputValidation -u "${DELETELINE}" -i
	if [[ "${?}" -ne 0 ]]; then

		echo "fileTools.sh:deleteLine() ${DELETELINE} is not an integer!"
		return 255

	fi

	# Make sure that the index is valid
	if [[ "${DELETELINE}" -ge "${#DELETEARRAY[@]}" ]]; then

		echo "fileTools.sh:deleteLine() Invalid line number!"
		return 255

	fi

	echo "DELETELINE: ${DELETELINE}"

	local DELLEN="${#DELETEARRAY[@]}"

	# Simply unsetting the index does not reflect desired behaviour
	# Because of this we will iterate through the list
	# Moving item n+1 to overwrite item n starting at index "DELETELINE"
	# Once we are at the end, then we unset the last index in the array
	for i in $(seq "$(( ${DELETELINE} + 1 ))" $(( DELLEN - 1 ))); do

		# Overwrite the line in the array with its next index
		DELETEARRAY[$(( i - 1 ))]="${DELETEARRAY[${i}]}"

	done

	# Unset the last index of the array
	unset 'DELETEARRAY[$DELLEN-1]'

	return 0

}


# While loop to interface these functions to the user.
#  Parameters
#  -f|--filename = File to be edited
#  -i|--inline   = Enables Inline line editor
# arguments that are not parameters will be interpreted as filename
# Usage:
#	fileEditor -f FILENAME -i
#	fileEditor FILENAME
function fileEditor() {

	local MUTUALLY_EXCLUSIVE=0

	function exclusivity() {

		# Check if MUTUALLY_EXCLUSIVE is set
		if [[ "${MUTUALLY_EXCLUSIVE}" == 1 ]]; then

			# return with error
			echo "fileTools.sh:fileEditor() To many parameters!"
			return 255

		fi

		MUTUALLY_EXCLUSIVE=1

	}

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Filename
			-f|--filename)
				local FILENAME="${2}"
				exclusivity
				shift # Past argument
				shift # Past value
				;;

			# Inline line editor
			-i|--inline)
				local FINLINE=1
				shift # Past argument
				;;

			# Default
			*)
				local FILENAME="${1}"
				exclusivity
				shift # Past argument
				;;

			# Error Handling
			-*|--*)
				echo "fileTools.sh:fileEditor() Invalid parameter ${1}!"
				return 255
				;;

		esac

	done

	if [[ "${MUTUALLY_EXCLUSIVE}" -ne 1 ]]; then

		# Error
		echo "fileTools.sh:fileEditor() You must supply a filename!"
		return 255

	fi

	# If the file does not exist, create it
	if ! [[ -f "${FILENAME}" ]]; then

		createfile -f "${FILENAME}"

	fi

	# We need to read the file into an array
	FILEARRAY=()

	# Read the file into the array
	readFile -f "${FILENAME}" -a FILEARRAY

	local OPTIONS=( "add" "comment" "edit" "delete" "save" "exit" )

	# User interface
	while true; do

		# Prompt the user with the contents of the file
		userInterface -a FILEARRAY -o OPTIONS

		# Switch case for the return value from the user
		case "${?}" in

			0) # Add

				# Prompt the user for the new line
				echo "What would you like to add to the file?"
				read FILEUSERINPUT

				# Add the line to the array
				addLine -a FILEARRAY -l "${FILEUSERINPUT}"

				;;

			1) # Comment

				# Prompt the user for what line to comment
				userInterface -a FILEARRAY -n

				local LINENUMBER="${?}"

				# Comment the line on the array
				commentLine -a FILEARRAY -n "${LINENUMBER}"

				;;

			2) # Edit

				# Prompt the user for what line to edit
				userInterface -a FILEARRAY -n

				local LINENUMBER="${?}"

				# Edit the line on the array
				if [[ -n "${FINLINE}" ]]; then

					editLine -a FILEARRAY -n "${LINENUMBER}" -i

				else

					editLine -a FILEARRAY -n "${LINENUMBER}"

				fi

				;;

			3) # Delete

				# Prompt the user for what line to delete
				userInterface -a FILEARRAY -n

				local LINENUMBER="${?}"

				# Delete the line from the array
				deleteLine -a FILEARRAY -n "${LINENUMBER}"

				;;

			4) # Save

				# Save the file
				saveFile -f "${FILENAME}" -a FILEARRAY

				;;

			5) # Exit

				# Break out of the while loop
				break

				;;

		esac

		sleep 1s

	done

}
