#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#Needed by distrobox
#export PATH=/home/deck/.local/bin:$PATH

export CHROME_EXECUTABLE="/var/lib/flatpak/app/com.google.Chrome/current/active/export/bin/com.google.Chrome"

# Android SDK Paths
export ANDROID_HOME=/home/deck/Android/Sdk
export ANDROID_SDK_ROOT=/home/deck/Android/Sdk

# Android ADB
export PATH=$PATH:/home/deck/Android/Sdk/platform-tools

alias update="nix-channel --update && home-manager switch"
