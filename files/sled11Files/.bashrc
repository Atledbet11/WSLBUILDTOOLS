export CODEROOT="/mnt/wsl/instances/sled11/code/"     # Shared directory to work on code from accross different windows or wsl environments
export WSLROOT="/mnt/c/wslDistroStorage/shared/"
export PATH="$PATH:/mnt/c/wslDistroStorage/shared/scripts" # This is where scripts are stored for automation accross different wsl environments


# We need to make a directory so that other linux wsl instances can access /code
mkdir -p /mnt/wsl/instances/$WSL_DISTRO_NAME
mount -t none / /mnt/wsl/instances/$WSL_DISTRO_NAME -o defaults,bind,X-mount.mkdir
