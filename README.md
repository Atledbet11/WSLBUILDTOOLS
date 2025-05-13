WSLBUILDTOOLS setup guide

In this guide I will go over setting up wsl2 for building SC/CCL code.

# WSL Installation

WSL is a windows feature you can enable
>Note: Once enabled you will have to run some windows updates to install the latest version of WSL

Click start and search:
```
turn windows features on or off
```

Then, enable the following:
```
Hyper-V
Virtual Machine Platform
Windows Hypervisor Platform
Windows Subsystem for Linux
```
>Note: You really only need Windows Subsystem for Linux
>        However the others are useful to enable now.

Run windows updates and restart your computer.

# WSL Setup

We will need two distrobutions of linux installed
- First we need SLED11, as this is where the code has to be built
- Next you can install any Linux distro of your choice, I use openSUSE-Leap-15.6

# Lets start with SLED11

First you need to download [SLED11](https://capstonelogistics-my.sharepoint.com/:u:/p/anthony_ledbetter/EdlROLDEiVVLkZPwJya-nFkBpigy3NB6ex3GxMbHBkT_Mg?e=y33KJd)
>Note: Make note of where that gets downloaded.

Now you will need to choose a place to install SLED11
>Note: I am using C:\wslDistroStorage\sled11

Open powershell

Navigate to where you downloaded SLED11
```
cd $HOME\downloads
```

Create directory to install
```
mkdir C:\wslDistroStorage\sled11
```

Import sled11-0-i586.tar
```
wsl --import sled11 C:\wslDistroStorage\sled11 .\sled11-0-i586.tar
```

Verify that sled11 is installed
```
wsl -l -v
```
>Note: you should see sled11 on this list.

# Now lets setup openSUSE-Leap-15.6

Open powershell

Install openSUSE-Leap-15.6
```
wsl install -d openSUSE-Leap-15.6
```
>Note: By default this will be installed in a weird spot
>      We will now move it to be in C:\wslDistroStorage\openSUSE-Leap-15.6

Moving install location
```
wsl --shutdown
```

```
wsl --manage openSUSE-Leap-15.6 --move C:\wslDistroStorage\openSUSE-Leap-15.6
```

Set default distro
```
wsl --setdefault openSUSE-Leap-15.6
```

Restart the distro
```
wsl -d openSUSE-Leap-15.6
```

# Clone the Repository

Using your openSUSE-Leap-15.6 terminal

```
cd /mnt/c/wslDistroStorage/
git clone git@github.com:Atledbet11/WSLBUILDTOOLS.git shared
```
>Note: It is important that the scripts are installed into "/mnt/c/wslDistroStorage/shared/scripts"
>      This is because the .bashrc files will add this directory to the shell path variable.

# Sled11 setup

Open a new sled11 terminal using windows terminal
>Note: If you arent on windows terminal you can use "wsl -d sled11" to open it from CMD

**Copy over your sled11 .bashrc**

```
cd $HOME
cp /mnt/c/wslDistroStorage/shared/files/sled11Files/.bashrc ./.bashrc
```

**Close and restart the sled11 terminal so the new .bashrc is loaded**

Verify the .bashrc is loaded
```
echo $WSLROOT
```
>Note: Should display "/mnt/c/wslDistroStorage/shared/"

# openSUSE-Leap-15.6 setup

open a new openSUSE-Leap-15.6 terminal using windows terminal
>Note: If you arent on windows terminal you can use "wsl -d openSUSE-Leap-15.6" to open it from CMD

**Copy over your openSUSE-Leap-15.6 .bashrc**

```
cd $HOME
cp /mnt/c/wslDistroStorage/shared/files/distroFiles/.bashrc
```

**Close and restart the openSUSE-Leap-15.6 terminal so the new .bashrc is loaded**

Verify the .bashrc is loaded
```
echo $WSLROOT
```
>Note: Should display "/mnt/c/wslDistroStorage/shared/"

**EDIT your CVSROOT**

```
cd $HOME
nano .bashrc
```

edit the line containing "export CVSROOT=" to have your username instead of mine.

# Make sure that the buildbox is initialized

From the openSUSE-Leap-15.6 terminal
```
cd $CODEROOT
```
>Note: This should put you in the directory "/mnt/wsl/instances/sled11/code"
>      If you are not taken there, then there is an issue with your setup.
>      Try rebooting the host machine and opening a fresh openSUSE Terminal.
