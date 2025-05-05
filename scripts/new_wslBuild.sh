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
			;;

		# noopt
		--noopt)
			;;

		# noinit
		--noinit)
			;;

		# unit testing
		--unittest)
			;;

		# debug enable
		-d|--debug)
			;;

done