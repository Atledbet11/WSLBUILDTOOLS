#!/bin/bash

# Only runs if the script is being directly executed.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

        echo "Script is being directly executed!"
	echo "Source this script using 'source auto.sh'"
	exit 255

# Only runs if the script is being sourced.
#else
fi

# This script will auto type out ssh commands for the SC/CCL/LPT/MWS/POS

# So the first thing you want to do is get out of your wheelchair, and into your walker.
source userInputValidation.sh

# Wrapping script into a function for sourcing
function auto() {

	# Adding proper argument handling into the script for those who dare to improve upon this script

	local POSITIONAL_ARGS=()
	local MUTUALLY_EXCLUSIVE=0

	local VALMODE=( "c" "command" "d" "default" "l" "less" "t" "tail" )

	# Localize variables
	local USER
	local DIRECTORY
	local LOG
	local STORE
	local REG
	local MODE
	local UNITTEST
	local NEWTAB
	local TITLE
	local DISTRO
	local IP
	local FSEP=";"
	local RET
	local UIP
	local LINES
	local CMD

	# Nameref variables
	local -n COMMAND

	function exclusivity() {

	        # Check if MUTUALLY_EXCLUSIVE is set
	        if [[ "${MUTUALLY_EXCLUSIVE}" == 1 ]]; then

	                # return with error
	                echo "To many parameters!"
	                return 255

	        fi

	        MUTUALLY_EXCLUSIVE=1

	}

	while [[ "${#}" -gt 0 ]]; do

		case "${1}" in

			# Sitecontroller
			-s|--sitecon)
				USER="sitecon"
				DIRECTORY="/home/sitecon/sc/"
				LOG="Syslog.dat"
				exclusivity
				shift # Past argument
				;;

			# Credit Card Library?
			-c|--ccl)
				USER="ccl"
				DIRECTORY="/home/ccl/ccl/"
				LOG="CCLlog.dat"
				exclusivity
				shift # Past argument
				;;

			# Linux Payment Terminal?
			-l|--lpt)
				USER="lpt"
				DIRECTORY="/home/lpt/"
				LOG="lptlog.dat"
				exclusivity
				shift # Past argument
				;;

			# Managers Workstation
			-m|--mws)
				MWS=1
				USER="fiscal"
				DIRECTORY="/usr/fiscal/data/"
				exclusivity
				shift # Past argument
				;;

			# MWS STORE
			--store)
				STORE="$2"
				shift # Past argument
				shift # Past value
				;;

			# MWS REG
			--register)
				REG="$2"
				shift # Past argument
				shift # Past value
				;;

			# Point of Sale
			-p|--pos)
				USER="fiscaluser"
				DIRECTORY="/cygdrive/c/program\ files/fiscal/"
				LOG="Poslog.dat"
				exclusivity
				shift # Past argument
				;;

			# IFSF Translator
			-i|--ifsf)
				USER="scifsf"
				DIRECTORY="/home/scifsf/"
				LOG="IFSFlog.dat"
				exclusivity
				shift # Past argument
				;;

			# Mode
			--mode)
				MODE="$2"
				shift # Past argument
				shift # Past value
				;;

			# Command
			--cmd|--command)
				COMMAND="$2"
				shift # Past argument
				shift # Past value
				;;

			# Test
			--test|--unittest)
				UNITTEST=1
				shift # Past argument
				;;

			# New Tab
			-n|--newtab)
				NEWTAB=1
				shift # Past argument
				;;

			# Title
			--title)
				TITLE="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Distro
			-d|--distro)
				DISTRO="${2}"
				shift # Past argument
				shift # Past value
				;;

			# IP Catch
			--ip)
				IP="${2}"
				shift # Past argument
				shift # Past value
				;;

			# Default
			*)
				IP="${1}"
				shift # Past value
				;;

			# Error catching
			-*|--*)
				echo "Unknown option $1"
				return 255
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

	# Make sure an option for validation was supplied
	if [[ "${MUTUALLY_EXCLUSIVE}" == 0 ]]; then

	        # Error
	        echo "You must supply a validation parameter"
	        return 255

	fi

	# If distro is not set, set it to the current distro
	if [[ -z "${DISTRO}" ]]; then DISTRO="${WSL_DISTRO_NAME}"; fi

	# If mode is not set, set it to default
	if [[ -z "${MODE}" ]]; then
		if [[ -n "${COMMAND}" ]]; then
			MODE="c"
		else
			MODE="d"
		fi
	fi

	# If NEWTAB is set we need to insert a field separator
	if [[ -n "${NEWTAB}" ]]; then FSEP=" &&"; fi

	# echo suppression for unittesting
	if [[ -z "${UNITTEST}" ]]; then
		# Logging
		if [[ -n "${IP}" ]]; then        echo "IP        = ${IP}"; fi
		if [[ -n "${USER}" ]]; then      echo "USER      = ${USER}"; fi
		if [[ -n "${DIRECTORY}" ]]; then echo "DIRECTORY = ${DIRECTORY}"; fi
		if [[ -n "${LOG}" ]]; then       echo "LOG       = ${LOG}"; fi
		if [[ -n "${MODE}" ]]; then      echo "MODE      = ${MODE}"; fi
		if [[ -n "${COMMAND}" ]]; then   echo "COMMAND   = ${COMMAND[@]}"; fi
		if [[ -n "${NEWTAB}" ]]; then    echo "NEWTAB    = ${NEWTAB}"; fi
		if [[ -n "${DISTRO}" ]]; then    echo "DISTRO    = ${DISTRO}"; fi
		if [[ -n "${STORE}" ]]; then     echo "STORE     = ${STORE}"; fi
		if [[ -n "${REG}" ]]; then       echo "REGISTER  = ${REG}"; fi
		if [[ -n "${TITLE}" ]]; then     echo "TITLE     = ${TITLE}"; fi
		if [[ -n "${IP}" ]]; then        echo "IP        = ${IP}"; fi
	fi

	# Validate inputs
	userInputValidation -u "$IP" -ip >/dev/null
	RET="${?}"
	if [[ "${RET}" == 255 ]]; then echo "$IP Is not a valid IP!"; return 255; fi

	userInputValidation -u "$MODE" -o VALMODE
	RET="${?}"
	if [[ "${RET}" == 255 ]]; then echo "$MODE Is not a valid mode!"; return 255; fi

	# Set the User@IP variable
	UIP="${USER}@${IP}"

	# Number of lines to tail
	LINES=1000

	# Switch case for each mode
	case "${MODE}" in
		c|command)
			# We will need to parse the command and add in field separators

			CMD="${COMMAND[0]}"

			for cmd in "${COMMAND[@]:1}"; do

				CMD="${CMD}${FSEP} ${cmd}"

			done

			;;

		d|default)
			# Set the command
			CMD="cd ${DIRECTORY}${FSEP} bash"
			;;

		# Less Routine
		l|less)
			# MWS is weird
			if [[ -n "${MWS}" ]]; then
				# Make sure we have a valid store and register
				if [[ -z "${STORE}" || -z "${REG}" ]]; then echo "Must provide Store and Register"; return 255; fi
				CMD="cd ${DIRECTORY}${FSEP} ejrl50 -s -w ejrl${STORE}${REG}${FSEP} bash"
			else
				CMD="cd ${DIRECTORY}${FSEP} less ${LOG}${FSEP} bash"
			fi
			;;

		# Tail Routine
		t|tail)
			# MWS is weird
			if [[ -n "${MWS}" ]]; then
				# Make sure we have a valid store and register
				if [[ -z "${STORE}" || -z "${REG}" ]]; then echo "Must provide Store and Register"; return 255; fi
				CMD="cd ${DIRECTORY}${FSEP} ejrl50 -s -w ejrl${STORE}${REG}${FSEP} bash"
			else
				CMD="cd ${DIRECTORY}${FSEP} tail -f -n ${LINES} ${LOG}${FSEP} bash"
			fi
			;;
	esac

	if [[ -z "${NEWTAB}" ]]; then
		if [[ -z "${UNITTEST}" ]]; then ssh -t "${UIP}" "${CMD}"; else echo ssh -t "${UIP}" "${CMD}" ; fi
	else
		if [[ -z "${TITLE}" ]]; then TITLE="${UIP}"; fi
		if [[ -z "${UNITTEST}" ]]; then wt.exe -w 0 new-tab --title "${TITLE}" wsl.exe -d "${DISTRO}" -- ssh -t "${UIP}" "${CMD}"; else echo wt.exe -w 0 new-tab --title "${TITLE}" wsl.exe -d "${DISTRO}" -- ssh -t "${UIP}" "${CMD}"; fi
	fi

	return 0

}
