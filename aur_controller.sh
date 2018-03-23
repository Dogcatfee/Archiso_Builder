#!/bin/bash
# FILE: aur_controller.sh
# DESC: merge AUR activities to one script

if [ $# == 1 ]; then
    case "$1" in
        disable)
            cp ./pacman.conf.bak ./pacman.conf
            # Cut https://aur.archlinux.org/ and *.git to get package name
            for var in $(grep -v '^#' ./aur_git.links |  grep -Po '.*(?=\.)' | cut -c 27-100)
            do
              echo $var
              # Find package name in package list, remove package from list
              sed --in-place '/'$var'/d' ./configs/general_packages
            done
            printf "\nAUR packages disabled in pacman.conf\n"
            printf "Removed from packagelist\n-------------------------\n"
        ;;
        enable)
            # DESC: Add repo to pacman.conf, add packages to packagelist
            repo_dir=$PWD/aur_repo_x86_64
            base_dir=$PWD
            echo "Using default directory at $repo_dir"

            #Configure Pacman
            echo "Last line in pacman.conf set. Server = file://"$repo_dir""
            cp ./pacman.conf.bak ./pacman.conf

            #Configure Pacman
            echo "Last line in pacman.conf set. Server = file://"$repo_dir""
            cp ./pacman.conf.bak ./pacman.conf
            echo "[custom]" >> ./pacman.conf
            echo "SigLevel = Optional TrustAll" >> ./pacman.conf
            echo "Server = file://"$repo_dir >> pacman.conf

            # Cut https://aur.archlinux.org/ and *.git to get package name
            PACK=$(grep -v '^#' ./aur_git.links |  grep -Po '.*(?=\.)' | cut -c 27-100 )
            echo -e "$PACK" >> ./configs/general_packages
            printf "\nAdded to packagelist:\n--------------\n"
            echo -e "$PACK"
        ;;
        build)
            #Set repo directory
            repo_dir=aur_repo_x86_64
            base_dir=$PWD
            #Fetch AUR builder
            curl "https://codeload.github.com/Dogcatfee/AUR_BUILDER/zip/master" > aur.zip
            unzip -q aur.zip
            rm aur.zip
            mv ./AUR_BUILDER-master ./AUR_BUILDER
            # Transfer links to the AUR builder
            cat ./aur_git.links | grep -v '^#' | grep h > ./AUR_BUILDER/git.links
            # Build AUR packages
            cd ./AUR_BUILDER
            ./git_build_packages.sh ./$repo_dir
            ./init_custom_repo.sh ./$repo_dir
            # Move locl AUR repo
            cd $base_dir
            cp -r ./AUR_BUILDER/$repo_dir ./
            cd ./AUR_BUILDER && ./clean.sh
            # Add packages and pacman.conf
            cd $base_dir
            $0 enable
        ;;
        clean)
            rm -rf ./AUR_BUILDER
            rm -rf ./aur_repo_x86_64
            $0 disable
        ;;
    esac
fi