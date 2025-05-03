#!/bin/bash

source bBoxValidation.sh
ret=$?

if [ $ret = 0 ]; then
	echo "Pass"
else
	echo "Fail"
fi
