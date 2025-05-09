#!/bin/bash

source fileTools.sh
source userInterface.sh
source userInputValidation.sh

FILENAME="../setup_"
CMD="ls ${FILENAME}*.dat"

FILES=($(${CMD}))

for FILE in "${FILES[@]}"; do

	echo "File found: ${FILE}"

done


PROMPT="PROMPT"
OPTIONS=( "new" "edit" "delete" "comment" )

userInputValidation -u "ne" -o OPTIONS

echo "UserRET: ${?}"

#userInterface.sh  "${PROMPT}" "${OPTIONS[@]}"
#RET="${?}"

echo "${RET}"

