#!/bin/bash
# FILE: makefile.sh
# DESC: To get more lines 'in' Makefile

AIROOTFS_ROOT="./airootfs/root"
AIROOTFS_SCRIPT="$AIROOTFS_ROOT/customize_airootfs.sh"
AIROOTFS_CONFIG_DIR="./airootfs/home/user/.config/"
Targets=(xfce4 cinnamon gnome lxde i3)

if [ ! -d "./aur_repo_x86_64" ]; then
  ./aur_controller.sh build
fi


cp ./configs/general_packages packages.x86_64
if [ $# == 1 ]; then
  # if .config exists, delete it
  if [ -d "$AIROOTFS_CONFIG_DIR" ]; then
    rm -r $AIROOTFS_CONFIG_DIR  
  fi
  # if .config does not exist, create it
  if [ ! -d "$AIROOTFS_CONFIG_DIR " ]; then
    mkdir -p $AIROOTFS_CONFIG_DIR 
  fi
  # copy general config files, not related to desktop function
  if [ "$(ls -A ./configs/general_config/)" ]; then
    cp -r ./configs/general_config/* $AIROOTFS_CONFIG_DIR
  fi
  # determine and configure target
  for var in ${Targets[@]}; do
    if [ "$1" == $var ]; then
      echo "Building $1 build"
      if [ "$(ls -A ./configs/$1_config/)" ]; then
        cp -r ./configs/$1_config/* $AIROOTFS_CONFIG_DIR
      fi
      cat ./configs/$1_packages >> packages.x86_64
      # General + specific customizations
      cp  ./configs/airootfs_scripts/general_fs.sh "$AIROOTFS_SCRIPT"
      echo "" >> $AIROOTFS_SCRIPT
      cat ./configs/airootfs_scripts/$1_fs.sh >> "$AIROOTFS_SCRIPT"
      chmod +x "$AIROOTFS_SCRIPT"
    fi
  done
fi

# Run buildscript
sudo ./build.sh -v