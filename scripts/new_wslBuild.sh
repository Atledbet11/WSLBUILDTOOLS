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

done


