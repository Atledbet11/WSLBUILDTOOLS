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

**Lets start with SLED11**

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

**Now lets setup openSUSE-Leap-15.6**

