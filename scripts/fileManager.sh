#!/bin/bash

fileName="$1"

spacer="--------------------------------------------------------------"

declare -a File

# Checks for wslBuildCommands.txt file.
function checkFile() {

	# If the file exists
	if [ -f "$fileName" ]; then

		# Return true
		return 0

	# If the file does not exist
	else

		# Return false
		return 1

	fi

}

# Create the file if it did not exist.
function createFile() {

	# If the file exists
	if checkFile; then

		# Debug logging
		echo "The file $fileName already exists!"

		# Return false - we dont want to overwrite the file.
		return 1

	# If the file does not exist
	fi

	# Debug logging
	echo "Creating $fileName"

	# Touch the file
	touch "$fileName"

	# Set file permissions
	chmod 666 "$fileName"

	# Return true
	return 0

}

# Backup the file.
function backupFile() {

	# If the file did not exist
	if ! [ checkFile ]; then

		# Error/Debug logging
		echo "The file did not exist to backup!"

		# Return false
		return 1

	fi

	# If the file did exist
	# Debug logging
	echo "Making backup of file $fileName."

	# Copy a backup of the file
	cp "$fileName" "$fileName.bak"

	# Debug logging
	echo "Backup created at $fileName.bak"

	# Rerturn true
	return 0

}

# Reads the wslBuildCommands.txt file in for editing.
function readFile() {

	# If the file does not exist.
	if ! checkFile; then

		# Debug logging that we will create the file
		echo "The file $fileName did not exist"
		echo "Creating $fileName"

		# If we faile to create the file.
		if ! createFile; then

			# Return false
			return 1

		fi

	fi

	# While loop to read the file
	while IFS= read -r line
	do

		# Add the line to the File declared at top of file.
		File+=( "$line" )

	done < "$fileName"

	# Return true
	return 0

}

# Prints the file out.
function printFile() {

	# Get the length of the file array
	lengthOfArray=${#File[@]}

	# A title so the user knows what file is open.
	echo "File Editor for $fileName"

	# Making things look purty
	echo $spacer

	# For each line in the file
	for i in $(seq 0 $(( lengthOfArray - 1 )))
	do

		# Print the line number, and its contents
		echo "$(( i + 1 )): ${File[$i]}"

	done

	# Making things look purty
	echo $spacer

	# Return true
	return 1

}

# Adds the line to the file.
function addLine() {

	# Debug logging
	echo "Adding $1"

	# Add the input "$1" to the File array
	File+=( "$1" )

	# Return true
	return 1

}

# Toggle the comment on the line number.
function commentLine() {

	# Read the line that the user wishes to comment
	lineValue="${File[$(($1 - 1))]}"

	# If the line was already commented out
	if [[ ${lineValue:0:1} == "#" ]]; then

		# Debug logging
		echo "Uncommenting line $1"

		# Overwrite the line in the File array
		File[$(($1 - 1))]="${lineValue:1}"

	# If the line was not already commented out
	else

		# Debug logging
		echo "Commenting line $1"

		# Overwrite the line in the File array
		File[$(($1 - 1))]="#$lineValue"

	fi

	# Return true
	return 0

}

# Prompts the user to edit the value passed into the function.
function editLine() {

	# Read in the line that the user wishes to edit
	lineValue=$(echo ${File[$(( $1 - 1))]} | tr -d '\r')

	# Debug logging
	echo "Editing line $1 - $lineValue"

	# Read the user's edits to the line
	#  Note that -r ignores '\r' chars
	#  Note that -i provides the previous linevalue for them to edit.
	read -re -i "${lineValue}" lineValue

	# Debug logging
	echo "You entered: $lineValue"

	# Overwrite the line in the File array
	File[$(( $1 - 1 ))]="$lineValue"

}

# Deletes the provided line number from the file.
function deleteLine() {

	# Ge the length of the File array
	lengthOfArray=${#File[@]}

	# Make sure the index exists
	if [ $1 -gt $lengthOfArray ]; then 

		# Debug logging.
		echo "Invalid index $1!"

		# Return false
		return 1

	fi

	# For each line in the File array
	#  Note that this starts at the index we want to delete
	#   And will overwrite that line with the next line.
	#   This process continues for the whole length of the file.
	for i in $(seq $1 $(( lengthOfArray - 1 )))
	do

		# Overwrite the line in the File array
		File[$(( i - 1 ))]=${File[$i]}

	done

	# Unset the last index of the File array
	unset 'File[$lengthOfArray-1]'

	# Return true
	return 0

}

# Saves the file
function saveFile() {

	# Before we save the changes to the file
	#  We want to backup the old file.
	backupFile

	# Get the length of the File array
	lengthOfArray=${#File[@]}

	# Overwrite the file with the first line of the File array
	echo ${File[0]} > "$fileName"

	# For each line in the File array
	#  Note that this starts with line 2
	for i in $(seq 1 $(( lengthOfArray - 1)))
	do

		# Append the line to the file
		echo ${File[$i]} >> "$fileName"

	done

	# Return true
	return 0
}

# Read the file in.
readFile

# With the above functions defined and tested, I am implementing the UI loop below.
while true
do

	clear -x

	# Display the user's line file, and prompt for modifications.
	printFile
	echo "A-Add C-Comment E-Edit D-Delete S-Save X-Exit"

	# Read the user input.
	read userInput

	# Determine what the user intends to do.
	# If the user wants to add a line.
	if [[ "$userInput" == "A" || "$userInput" == "a" ]]; then

		# Prompt the user for the new line
		echo "What would you like to add to the file?"
		read userInput2

		# Execute addLine with the users inputs.
		addLine "$userInput2"

	# If the user wants to comment a line
	elif [[ "$userInput" == "C" || "$userInput" == "c" ]]; then
		# Prompt the user for the line number they wish to comment.
		echo "Which line(#) do you wish to comment?"
		read userInput2

		# Comment the line
		commentLine "$userInput2"

	# If the user wants to edit a line.
	elif [[ "$userInput" == "E" || "$userInput" == "e" ]]; then
		# Prompt the user for the line number they wish to edit.
		echo "Which line(#) do you wish to edit?"
		read userInput2

		# edit the specified line for the user.
		editLine "$userInput2"

	# If the user wants to delete a line
	elif [[ "$userInput" == "D" || "$userInput" == "d" ]]; then
		# Prompt the user for the line number they wish to delete.
		echo "Which line(#) do you wish to delete?"
		read userInput2

		# Delete the line they want deleted.
		deleteLine "$userInput2"

	# if the user wants to save
	elif [[ "$userInput" == "S" || "$userInput" == "s" ]]; then
		# Save the line file.
		saveFile

	# If the user wants to exit
	elif [[ "$userInput" == "X" || "$userInput" == "x" ]]; then
		# Break out of the while loop.
		break

	# else the command was not recognized.
	else
		# Tell the user the command was not recognized.
		echo "The input ($userInput) was not recognized as a command."
		echo "Please try again."

	fi

	sleep 1s

done
