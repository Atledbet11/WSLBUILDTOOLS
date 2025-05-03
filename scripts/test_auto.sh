#!/bin/bash

source unitTestTools.sh
source auto.sh

# FILE LOG
titleLog "UNIT TESTING: auto"

# Error Conditions
titleLog "Error Conditions"

# Missing IP
unitTest --test "Missing IP" -c "auto -c --unittest" -e 255

# Invalid IP
unitTest --test "Invalid IP" -c "auto 192.168.1.256 -c --unittest" -e 255

# Invalid Mode
unitTest --test "Invalid Mode" -c "auto 192.168.1.100 -c --mode q --unittest" -e 255

# Mishing Machine Type
unitTest --test "Missing Type" -c "auto 192.168.1.100 --unittest" -e 255

# Mutual Exclusivity
titleLog "Mutual Exclusivity"

# SITECON AND CCL
unitTest --test "SC/CCL" -c "auto -s -c --unittest" -e 255

# SITECON AND LPT
unitTest --test "SC/LPT" -c "auto -s -l --unittest" -e 255

# SITECON AND MWS
unitTest --test "SC/MWS" -c "auto -s -m --unittest" -e 255

# SITECON AND POS
unitTest --test "SC/POS" -c "auto -s -p --unittest" -e 255

# SITECON AND IFSF
unitTest --test "SC/IFSF" -c "auto -s -i --unittest" -e 255

# CCL AND LPT
unitTest --test "CCL/LPT" -c "auto -c -l --unittest" -e 255

# CCL AND MWS
unitTest --test "CCL/MWS" -c "auto -c -m --unittest" -e 255

# CCL AND POS
unitTest --test "CCL/POS" -c "auto -c -p --unittest" -e 255

# CCL AND IFSF
unitTest --test "CCL/IFSF" -c "auto -c -i --unittest" -e 255

# LPT AND MWS
unitTest --test "LPT/MWS" -c "auto -l -m --unittest" -e 255

# LPT AND POS
unitTest --test "LPT/POS" -c "auto -l -p --unittest" -e 255

# LPT AND IFSF
unitTest --test "LPT/IFSF" -c "auto -l -i --unittest" -e 255

# MWS AND POS
unitTest --test "MWS/POS" -c "auto -m -p --unittest" -e 255

# MWS AND IFSF
unitTest --test "MWS/IFSF" -c "auto -m -i --unittest" -e 255

# POS AND IFSF
unitTest --test "POS/IFSF" -c "auto -p -i --unittest" -e 255

successLog

# SC Conditions
titleLog "SC Conditions"

# Typical Use
unitTest --test "Typical Use" -c "auto 192.168.1.100 -s --unittest" -e 0 -t "ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/; bash"

# Mode Default
unitTest --test "Mode Default" -c "auto 192.168.1.100 -s --mode d --unittest" -e 0 -t "ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/; bash"

# Mode Logging
unitTest --test "Mode Logging" -c "auto 192.168.1.100 -s --mode l --unittest" -e 0 -t "ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/; less Syslog.dat; bash"

# Mode Tail
unitTest --test "Mode Tail" -c "auto 192.168.1.100 -s --mode t --unittest" -e 0 -t "ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/; tail -f -n 1000 Syslog.dat; bash"

successLog

# CMD Conditions
titleLog "CMD Conditions"

# Prebuild Command for testing
command=( "cd /home/sitecon/sc/" "./supportConsole 127.0.0.1 d?" "bash" )

# D? Check
unitTest --test "D? Check" -c "auto 192.168.1.100 -s --cmd command --unittest" -e 0 -t "ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/; ./supportConsole 127.0.0.1 d?; bash"

successLog

# CCL Conditions
titleLog "CCL Conditions"

# Typical Use
unitTest --test "Typical Use" -c "auto 192.168.1.100 -c --unittest" -e 0 -t "ssh -t ccl@192.168.1.100 cd /home/ccl/ccl/; bash"

# Mode Default
unitTest --test "Mode Default" -c "auto 192.168.1.100 -c --mode d --unittest" -e 0 -t "ssh -t ccl@192.168.1.100 cd /home/ccl/ccl/; bash"

# Mode Logging
unitTest --test "Mode Logging" -c "auto 192.168.1.100 -c --mode l --unittest" -e 0 -t "ssh -t ccl@192.168.1.100 cd /home/ccl/ccl/; less CCLlog.dat; bash"

# Mode Tail
unitTest --test "Mode Tail" -c "auto 192.168.1.100 -c --mode t --unittest" -e 0 -t "ssh -t ccl@192.168.1.100 cd /home/ccl/ccl/; tail -f -n 1000 CCLlog.dat; bash"

successLog

# LPT Conditions
titleLog "LPT Conditions"

# Typical Use
unitTest --test "Typical Use" -c "auto 192.168.1.100 -l --unittest" -e 0 -t "ssh -t lpt@192.168.1.100 cd /home/lpt/; bash"

# Mode Default
unitTest --test "Mode Default" -c "auto 192.168.1.100 -l --mode d --unittest" -e 0 -t "ssh -t lpt@192.168.1.100 cd /home/lpt/; bash"

# Mode Logging
unitTest --test "Mode Logging" -c "auto 192.168.1.100 -l --mode l --unittest" -e 0 -t "ssh -t lpt@192.168.1.100 cd /home/lpt/; less lptlog.dat; bash"

# Mode Tail
unitTest --test "Mode Tail" -c "auto 192.168.1.100 -l --mode t --unittest" -e 0 -t "ssh -t lpt@192.168.1.100 cd /home/lpt/; tail -f -n 1000 lptlog.dat; bash"

successLog

# MWS Conditions
titleLog "MWS Conditions"

# Typical Use
unitTest --test "Typical Use" -c "auto 192.168.1.100 -m --unittest" -e 0 -t "ssh -t fiscal@192.168.1.100 cd /usr/fiscal/data/; bash"

# Mode Default
unitTest --test "Mode Default" -c "auto 192.168.1.100 -m --mode d --unittest" -e 0 -t "ssh -t fiscal@192.168.1.100 cd /usr/fiscal/data/; bash"

# Mode Logging
unitTest --test "Mode Logging" -c "auto 192.168.1.100 -m --mode l --store 100 --register 50 --unittest" -e 0 -t "ssh -t fiscal@192.168.1.100 cd /usr/fiscal/data/; ejrl50 -s -w ejrl10050; bash"

# Mode Logging Missing Store
unitTest --test "Mode Logging Missing Store" -c "auto 192.168.1.100 -m --mode l --register 50 --unittest" -e 255;

# Mode Logging Missing Register
unitTest --test "Mode Logging Missing Register" -c "auto 192.168.1.100 -m --mode l --store 100 --unittest" -e 255;

# Mode Tail
unitTest --test "Mode Tail" -c "auto 192.168.1.100 -m --mode t --store 100 --register 50 --unittest" -e 0 -t "ssh -t fiscal@192.168.1.100 cd /usr/fiscal/data/; ejrl50 -s -w ejrl10050; bash"

# Mode Tail Missing Store
unitTest --test "Mode Tail Missing Store" -c "auto 192.168.1.100 -m --mode t --register 50 --unittest" -e 255;

# Mode Tail Missing Register
unitTest --test "Mode Tail Missing Register" -c "auto 192.168.1.100 -m --mode t --store 100 --unittest" -e 255;

successLog

# POS Conditions
titleLog "POS Conditions"

# Typical Use
unitTest --test "Typical Use" -c "auto 192.168.1.100 -p --unittest" -e 0 -t "ssh -t fiscaluser@192.168.1.100 cd /cygdrive/c/program\ files/fiscal/; bash"

# Mode Default
unitTest --test "Mode Default" -c "auto 192.168.1.100 -p --mode d --unittest" -e 0 -t "ssh -t fiscaluser@192.168.1.100 cd /cygdrive/c/program\ files/fiscal/; bash"

# Mode Logging
unitTest --test "Mode Logging" -c "auto 192.168.1.100 -p --mode l --unittest" -e 0 -t "ssh -t fiscaluser@192.168.1.100 cd /cygdrive/c/program\ files/fiscal/; less Poslog.dat; bash"

# Mode Tail
unitTest --test "Mode Tail" -c "auto 192.168.1.100 -p --mode t --unittest" -e 0 -t "ssh -t fiscaluser@192.168.1.100 cd /cygdrive/c/program\ files/fiscal/; tail -f -n 1000 Poslog.dat; bash"

successLog

# IFSF Conditions
titleLog "IFSF Conditions"

# Typical Use
unitTest --test "Typical Use" -c "auto 192.168.1.100 -i --unittest" -e 0 -t "ssh -t scifsf@192.168.1.100 cd /home/scifsf/; bash"

# Mode Default
unitTest --test "Mode Default" -c "auto 192.168.1.100 -i --mode d --unittest" -e 0 -t "ssh -t scifsf@192.168.1.100 cd /home/scifsf/; bash"

# Mode Logging
unitTest --test "Mode Logging" -c "auto 192.168.1.100 -i --mode l --unittest" -e 0 -t "ssh -t scifsf@192.168.1.100 cd /home/scifsf/; less IFSFlog.dat; bash"

# Mode Tail
unitTest --test "Mode Tail" -c "auto 192.168.1.100 -i --mode t --unittest" -e 0 -t "ssh -t scifsf@192.168.1.100 cd /home/scifsf/; tail -f -n 1000 IFSFlog.dat; bash"

successLog

# New Tab Conditions
titleLog "New Tab Conditions"

# CCL Typical use
unitTest --test "CCL Typical Use" -c "auto 192.168.1.100 -c -n --unittest" -e 0 -t "wt.exe -w 0 new-tab --title ccl@192.168.1.100 wsl.exe -d $WSL_DISTRO_NAME -- ssh -t ccl@192.168.1.100 cd /home/ccl/ccl/ && bash"

# CCL Mode Logging
unitTest --test "CCL Mode Logging" -c "auto 192.168.1.100 -c -n --mode l --unittest" -e 0 -t "wt.exe -w 0 new-tab --title ccl@192.168.1.100 wsl.exe -d $WSL_DISTRO_NAME -- ssh -t ccl@192.168.1.100 cd /home/ccl/ccl/ && less CCLlog.dat && bash"

# SC Mode Tail
unitTest --test "SC Mode Tail" -c "auto 192.168.1.100 -s -n --mode t --unittest" -e 0 -t "wt.exe -w 0 new-tab --title sitecon@192.168.1.100 wsl.exe -d $WSL_DISTRO_NAME -- ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/ && tail -f -n 1000 Syslog.dat && bash"

# SC Custom Command
command=( "cd /home/sitecon/sc/" "./supportConsole 127.0.0.1 d?" "bash" )
unitTest --test "SC Custom Command" -c "auto 192.168.1.100 -s -n --cmd command --unittest" -e 0 -t "wt.exe -w 0 new-tab --title sitecon@192.168.1.100 wsl.exe -d $WSL_DISTRO_NAME -- ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/ && ./supportConsole 127.0.0.1 d? && bash"

# Custom Title
unitTest --test "Custom Title" -c "auto 192.168.1.100 -s -n --unittest --title COOL_TITLE" -e 0 -t "wt.exe -w 0 new-tab --title COOL_TITLE wsl.exe -d ${WSL_DISTRO_NAME} -- ssh -t sitecon@192.168.1.100 cd /home/sitecon/sc/ && bash"

successLog

successInt
