#!/bin/bash

echo "Initializing sled11 mount"

# We need to make a directory so that other linux wsl instances can access /code
mkdir -p /mnt/wsl/instances/$WSL_DISTRO_NAME
mount -t none / /mnt/wsl/instances/$WSL_DISTRO_NAME -o defaults,bind,X-mount.mkdir
