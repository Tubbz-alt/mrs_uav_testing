#!/bin/bash

# get path to script
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ -x "$(whereis nvim | awk '{print $2}')" ]; then
 VIM_BIN="$(whereis nvim | awk '{print $2}')"
 HEADLESS="--headless"
elif [ -x "$(whereis vim | awk '{print $2}')" ]; then
 VIM_BIN="$(whereis vim | awk '{print $2}')"
 HEADLESS=""
fi

$VIM_BIN -u "$GIT_PATH/linux-setup/submodules/profile_manager/epigen/epigen.vimrc "$HEADLESS -E -s -c "%s/uav./$1/g" -c "wqa" -- "$SCRIPT_PATH/../plot_juggler/odometry.xml"
$VIM_BIN -u "$GIT_PATH/linux-setup/submodules/profile_manager/epigen/epigen.vimrc" $HEADLESS -E -s -c "%s/uav./$1/g" -c "wqa" -- "$SCRIPT_PATH/../rviz/odometry.rviz"