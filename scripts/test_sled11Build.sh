#!/bin/bash

source unitTestTools.sh

# File Log
titleLog "UNIT TESTING: sled11Build"

# Error Conditions
titleLog "Error Conditions"

# Invalid parameter
unitTest --test "Invalid Parameter" -c "sled11Build.sh -g --unittest" -e 255

# Invalid build environment
unitTest --test "Invalid build environment" -c "sled11build.sh" -e 255

successLog

# Build file test
# Uses the file wslBuildCommands in ./unittest/sled11Build
# Executes from ./unittest/sled11Build/ccl

# Store the CWD so we can return after execution
CWD=$(pwd)

# CD to $WSLROOT/unittest/sled11Build/ccl
cd "${WSLROOT}/unittest/sled11Build/ccl"

titleLog "Build File"

# Export check
unitTest --test "Export Check" -c "sled11Build.sh --unittest" -e 0 -t "export VER_TAG=_SLED11BUILD && export MAKEOPT=\"-DEMV_DEV_TESTING=1\" && export SITECON_IP=192.168.1.100 && make clean && make"

# NO OPT
unitTest --test "NO OPT" -c "sled11Build.sh -n --unittest" -e 0 -t "make clean && make"

# Restore CWD
cd "${CWD}"

successLog

successInt
