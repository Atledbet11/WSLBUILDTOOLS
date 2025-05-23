# Sample .bashrc for SuSE Linux
# Copyright (c) SuSE GmbH Nuernberg

# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit

# For some news readers it makes sense to specify the NEWSSERVER variable here
#export NEWSSERVER=your.news.server

# If you want to use a Palm device with Linux, uncomment the two lines below.
# For some (older) Palm Pilots, you might need to set a lower baud rate
# e.g. 57600 or 38400; lowest is 9600 (very slow!)
#
#export PILOTPORT=/dev/pilot
#export PILOTRATE=115200

test -s ~/.alias && . ~/.alias || true

export CODEROOT="/mnt/wsl/instances/sled11/code/"     # Shared directory to work on code from accross different windows or wsl environments
export WSLROOT="/mnt/c/wslDistroStorage/shared/"
export PATH="$PATH:/mnt/c/wslDistroStorage/shared/scripts" # This is where scripts are stored for automation accross different wsl environments
export CVSROOT="tate@192.168.101.201/usr/local/cvsroot"
export CVS_RSH="ssh"

# Initialize SLED11 distro and mount / to /mnt/wsl/instances/sled11/
if [ ! -d $CODEROOT ]; then
	cd /mnt/c
	wsl.exe -d sled11 sled11init.sh
	cd
fi

