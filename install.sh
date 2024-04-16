#!/bin/bash

###############################################################################################################################
#                                                                                                                             #
#  Run me anywhere with:                                                                                                      #
#  TTY=$(tty) bash -c 'curl -sSf https://raw.githubusercontent.com/aiguy110/astronvim_user_config/main/install.sh | bash -s'  #
#                                                                                                                             #
###############################################################################################################################

function install_nvim_bin() {
    INSTALL_ROOT=/opt/nvim-root
    TMP_DIR=/tmp/nvim-setup

    # Setup temp dir
    if [ -e $TMP_DIR ]; then
        rm -rf $TMP_DIR
    fi
    mkdir -p $TMP_DIR
    cd $TMP_DIR

    # Figure out which appimage to download
    APPIMAGE_URL="https://github.com/neovim/neovim/releases/download/stable/nvim.appimage"
    if [ "$(uname -m)" == "aarch64" ]; then
        APPIMAGE_URL="https://github.com/matsuu/neovim-aarch64-appimage/releases/download/v0.9.4/nvim-v0.9.4-aarch64.appimage"
    fi

    # Download and extract Appimage
    wget -q --show-progress $APPIMAGE_URL -O nvim.appimage
    if [ $? -ne 0 ]; then
        echo "Error downloading nvim.appimage. Trying again without \"--show-progress\"."
        wget -q $APPIMAGE_URL -O nvim.appimage 
        if [ $? -ne 0 ]; then
            echo "Still can't download nvim.appimage. Exiting."
            exit
        fi
    fi

    chmod +x nvim.appimage
    ./nvim.appimage --appimage-extract 2>&1 > /dev/null
    sudo -E mv ./squashfs-root $INSTALL_ROOT 

    echo "Downloaded and extacted Appimage squashfs-root to $INSTALL_ROOT"

    # Attempt to symlink into path
    SUCCESS=0
    while read -r PATH_DIR; do
        sudo -E ln -s -T $INSTALL_ROOT/usr/bin/nvim $PATH_DIR/nvim 2>&1 > /dev/null
        if [ $? -eq 0 ]; then
            echo "Successfully symlinked nvim into $PATH_DIR"
            SUCCESS=1
            break
        fi
    done < <(echo $PATH | tr ':' '\n' | grep sbin)

    # If we couldn't symlink into any "sbin" dirs, try "bin" dirs
    if [ $SUCCESS -eq 0 ]; then
         while read -r PATH_DIR; do
            sudo -E ln -s -T $INSTALL_ROOT/usr/bin/nvim $PATH_DIR/nvim 2>&1 > /dev/null
            if [ $? -eq 0 ]; then
                echo "Successfully symlinked nvim into $PATH_DIR"
                SUCCESS=1
                break
            fi
        done < <(echo $PATH | tr ':' '\n' | grep sbin)
    fi

    # Report failure if necessary
    if [ $SUCCESS -eq 0 ]; then
        echo "Failed to symlink $INSTALL_ROOT/usr/bin/nvim into the PATH. You may want to do this manually."
    fi
}

function install_nvim_config() {
    # Check if we can install the custom config
    which git 2>&1 > /dev/null
    if [ $? -ne 0 ]; then 
        echo "git does not appear to be installed. Please install it and run this script again."
        exit
    fi

    # If we're here, we're good to clone the config from github
    if [ ! -e ~/.config ]; then
        mkdir ~/.config
    fi
    cd ~/.config

    # Clone parent AstroNvim repo over HTTPS
    git clone --depth 1 https://github.com/AstroNvim/template nvim

    # Try cloning this repo via SSH, and prompt for HTTPS clone if that fails
    git clone --depth 1 git@github.com:aiguy110/astronvim_user_config nvim/lua/user
    if [ $? -ne 0 ]; then
        read -p 'Issue cloning using SSH. Clone using HTTPS? [Yn]' HTTP_CLONE < $TTY
        if [ "$(echo "$HTTP_CLONE" | tr 'A-Z' 'a-z')" != "n" ]; then
            git clone --depth 1 https://github.com/aiguy110/astronvim_user_config nvim/lua/user
        else
            echo "Aborting. Consider using ssh-add to add a valid SSH key for this account and trying again."
            exit
        fi
    fi
}

# If the "nvim" command is not executable, make it so
which nvim 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    echo "Did not detect nvim binary on PATH. Downloading and installing it..."
    install_nvim_bin
else
    echo "Detected nvim on path. Skipping nvim install."
fi

# Check if we should install the custom config
if [ -e ~/.config/nvim ]; then
    read -p 'It looks like config files already exist at ~/.config/nvim. Would you like to overwrite them? [yN]' OVERWRITE_CONFIG < $TTY
    if [ "$(echo $OVERWRITE_CONFIG | tr 'A-Z' 'a-z')" != "y" ]; then # Using negative logic intentionally to impliment default
        echo "Will not overwrite config."
    else
        rm -rf ~/.config/nvim
        install_nvim_config
    fi
else
    install_nvim_config
fi
