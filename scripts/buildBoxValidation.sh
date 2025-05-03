#!/bin/bash

checksum="921168588dfe7c12111bf16312ed9373"

file="/etc/SuSE-release"

# Check to see if the file exists
test -f $file && {

	# If the file exists, print it to the terminal.
	echo "buildBoxValidation: $file exists"

} || {

	# If the file does not exist, print it to the terminal.
	echo "buildBoxValidation: $file does not exist"

	# Fail
	return 1

}

# Check the md5sum for the file /etc/SuSE-release
md5sum $file | grep -q $checksum && {

	# If the checksum is valid, print it to the terminal.
	echo "buildBoxValidation: Valid Checksum"

} || {

	# If the checksum is invalid, print it to the terminal.
	echo "buildBoxValidation: Invalid Checksum"

	# Fail
	return 1

}

# Pass
return 0
