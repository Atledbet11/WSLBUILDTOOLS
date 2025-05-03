#!/bin/bash

source fileTools.sh
source userInputValidation.sh

FILENAME="../setup.dat"
FILECONTENTS=( "MOO" "SHROOM" )

#createFile "${FILENAME}" -p 666 -d

#readFile -f "${FILENAME}" -a FILECONTENTS

#echo "${FILECONTENTS[@]}"


PROMPT="PROMPT"
OPTIONS=( "new" "edit" "delete" "comment" )

userInputValidation -u "ne" -o OPTIONS

echo "UserRET: ${?}"

#userInterface.sh  "${PROMPT}" "${OPTIONS[@]}"
#RET="${?}"

echo "${RET}"

