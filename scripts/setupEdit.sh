#!/bin/bash

source fileTools.sh
source userInterface.sh
source userInputValidation.sh

function setupManager() {

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
		userInterface -a SETUPS -o OPTIONS

		# Switch case for user response.
		case "${?}" in

			0) # Create new setup file
				# Prompt the user for a valid filename
				echo "Create new setup file"
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

	done

	sleep 0.5

}

setupManager
