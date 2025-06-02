#!/bin/bash

source fileTools.sh
source userInterface.sh
source userInputValidation.sh

function newSetup() {

	# Parameter handling
	
	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Setup name
			-n|--name)
				SETUPNAME="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Invalid arguments
			-*|--*)
				echo "Unknown option ${1}"
				return 255
				;;
			
			# Default setupname
			*)
				NAME="${1}"
				shift # Past value
				;;

		esac

	done

	echo "Creating setup"

	if ! [[ -n "${SETUPNAME}" ]]; then
		echo "SetupName Required!"
		return 255
	fi

	echo "Name = ${SETUPNAME}"

	userInputValidation -u "$SETUPNAME" -an >/dev/null
	RET="${?}"

	if [[ "${RET}" -ne 0 ]]; then
		echo "Invalid SetupName!"
		echo "Alphanumeric characters only!"
	fi

}

function editSetup() {
	echo "Edit Setup"
}

function deleteSetup() {
	echo "Delete Setup"
}

function renameSetup() {
	echo "Rename Setup"
}


# Setup manager:
# Parameter handling
while [[ "${#}" -gt 0 ]]; do

	case "${1}" in

		# Setup name
		-d|--debug)
			DEBUG=1
			shift # Past argument
			shift # Past value
			;;

		# Invalid arguments
		*)
			echo "Unknown option ${1}"
			return 255
			;;

	esac

done

if [[ -n "${DEBUG}" ]]; then echo "Debug enabled!"; fi

while true; do

	FILENAME="../setup_"
	CMD="ls ${FILENAME}*.dat"

	FILES=($(${CMD}))
	OPTIONS=( "new" "edit" "delete" "rename" "exit" )

	SETUPS=()

	# Populate setups array
	for FILE in "${FILES[@]}"; do

		SETUPS+=( "${FILE/${FILENAME}/}" )

	done

	# Prompt the user for what they intend to do
	(userInterface -a SETUPS -o OPTIONS)

	# Switch case for user response.
	case "${?}" in

		0) # Create new setup file
			# Prompt the user for a valid filename
			echo "Create new setup file"

			echo "Enter a name for the setup:"
			read USERINPUT

			newSetup -n ${USERINPUT}
			;;
		1) # Edit existing setup file
			# Prompt the user for which setup to edit
			echo "Edit existing setup file"
			;;
		2) # Delete existing setup file
			# Prompt the user for which setup to delete
			echo "Delete existing setup file"
			;;
		3) # Rename existing setup file
			# Prompt the user for which setup to rename
			echo "Rename existing setup file"
			;;
		4) # Exit setupManager
			break
			;;

	esac

	sleep 3

done


