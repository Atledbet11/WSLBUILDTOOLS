export CODEROOT="/mnt/wsl/instances/sled11/code/"     # Shared directory to work on code from accross different windows or wsl environments
export WSLROOT="/mnt/c/wslDistroStorage/shared/"
export PATH="$PATH:/mnt/c/wslDistroStorage/shared/scripts" # This is where scripts are stored for automation accross different wsl environments

# Initialize this distro so we can access the code externally using mount
sudo $WSLROOT/scripts/sled11init.sh
