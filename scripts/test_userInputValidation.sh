#!/bin/bash

source unitTestTools.sh
source userInputValidation.sh

# FILE LOG
titleLog "UNIT TESTING: userInputValidation"

# Error Conditions
titleLog "Error Conditions"

#  No User Input
unitTest --test "No User Input" -c "userInputValidation -u -n" -e 255

#  Mutual Exclusivity
unitTest --test "Mutual Exclusivity" -c "userInputValidation -u someData -a -n" -e 255

#  No Validation
unitTest --test "No Validation" -c "userInputValidation -u someData" -e 255

# Unrecognized Input Flag
unitTest --test "Unrecognized Input Flag" -c "userInputValidation -u someData -qwerty" -e 255

successLog

# Option Conditions
titleLog "Option Conditions"

opt=("So" "first" "thing" "you" "want" "to" "do" "is" "get" "out" "of" "your" "wheelchair" "and" "into" "the" "walker")

#  Item In List
unitTest --test "Item In List" -c "userInputValidation -u wheelchair -o opt" -e 12

#  Item Not In List
unitTest --test "Item Not In List" -c "userInputValidation -u MOO -o opt" -e 255

opt=()

#  Mising List Values
unitTest --test "Missing List Values" -c "userInputValidation -u walker -o opt" -e 255

successLog

# Integer Conditions
titleLog "Integer Conditions"

#  Typical Use
unitTest --test "Typical Use" -c "userInputValidation -u 9876543210 -i" -e 0

#  Float Point Error
unitTest --test "Float Point Error" -c "userInputValidation -u 99.99 -i" -e 255

#  Alpha Error
unitTest --test "Alpha Error" -c "userInputValidation -u 99a -i" -e 255

successLog

# Numeric Conditions
titleLog "Numeric Conditions"

#  Typical Use
unitTest --test "Typical Use" -c "userInputValidation -u 9876543210.0123456789 -n" -e 0

#  Typical Use 2
unitTest --test "Typical Use 2" -c "userInputValidation -u 9876543210 -n" -e 0

#  Alpha Error
unitTest --test "Alpha Error" -c "userInputValidation -u 987654321o -n" -e 255

successLog

# Alpha Conditions
titleLog "Alpha Conditions"

#  Typical Use
unitTest --test "Typical Use" -c "userInputValidation -u abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -a" -e 0

#  Numeric Error
unitTest --test "Numeric Error" -c "userInputValidation -u 4lph4t35t -a" -e 255

#  Space Error
unitTest --test "Space Error" -c 'userInputValidation -u "Alpha Test" -a' -e 255

#  Underscore/Punctuation Error
unitTest --test "Underscore/Punctuation Error" -c 'userInputValidation -u AL-pha_Test.!@#$%^&*()=+,? -a' -e 255

successLog

# Alphanumeric Conditions
titleLog "Alphanumeric Conditions"

#  Typical use
unitTest --test "Typical Use" -c "userInputValidation -u abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ9876543210 -an" -e 0

#  Space Error
unitTest --test "Space Error" -c 'userInputValidation -u "4lph4num3r1c T35t" -an' -e 255

#  Underscore/Punctuation Error
unitTest --test "Underscore/Punctuation Error" -c 'userInputValidation -u "4lph4num3r1c_T35t-=!@#$%^&*()_+,.?:;" -an' -e 255

successLog

# IP Conditions
titleLog "IP Conditions"

#  Typical use
unitTest --test "Typical Use" -c "userInputValidation -u 192.168.101.201 -ip" -e 0

#  Max Value
unitTest --test "Max Value" -c "userInputValidation -u 255.255.255.255 -ip" -e 0

#  Min Value
unitTest --test "Min Value" -c "userInputValidation -u 000.000.000.000 -ip" -e 0

#  Single Digit
unitTest --test "Single Digit" -c "userInputValidation -u 0.0.0.0 -ip" -e 0

#  Max Value Error
unitTest --test "Max Value Error" -c "userInputValidation -u 256.256.256.256 -ip" -e 255

#  Extra Quartet Error
unitTest --test "Extra Quartet Error" -c "userInputValidation -u 192.168.1.1.95 -ip" -e 255

#  Alpha Error
unitTest --test "Alpha Error" -c "userInputValidation -u 192.168.oo1.o95 -ip" -e 255

successLog

# CHMOD Conditions
titleLog "CHMOD Conditions"

#  Typical use
unitTest --test "Typical Use" -c "userInputValidation -u 755 --chmod" -e 0

#  Value too high
unitTest --test "Value Too High" -c "userInputValidation -u 800 --chmod" -e 255

#  Too many digits
unitTest --test "Too Many Digits" -c "userInputValidation -u 7777 --chmod" -e 255

#  Alpha Test
unitTest --test "Alpha Test" -c "userInputValidation -u 7oo --chmod" -e 255

successLog

successInt
