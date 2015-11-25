#!/bin/bash
#
# Simple bash script to install Security Onion on Lubuntu (should work on all Ubuntu distros tbh)
#
# Assuming that you have installed 12.04 version of your Ubuntu distro (12.04 is LTS)
#
# Before installing Security Onion please back-up your systems (VM snapshot, LVM, EBS whatever)
# Updating Lubuntu/Ubuntu repos
#

# Global Variables

VERSION="0.1"
ARG=$#

# Detailing the version.
version () {
    echo -e "The version is $VERSION.\n"
}

# Describing the usage
usage () {
    echo -e "Usage:
        -h|--help : Print this message.
        -t|--test : Install the test Security Onion repo.
        -s|--stable : Install the test Security Onion repo.
        -v|--version : Print the version of the script.

        Sample Usage: bash $0 -t

        Sample Usage: bash $0 --stable\n"
}

# Parsing the CLI arguments

parse_arg () {
    # Checking for start-up options and if none exist, exit
    if [ $ARG -gt 1 ]
    then
        echo "Please examine the usage options for this script - you can only have one command line switch!\n"
        usage
        exit 1
    fi

    for i in  $@
    do
        case $i in
            -s|--stable)
               INSTALL="stable"
                ;;
            -t|--test)
               INSTALL="test"
                ;;
            -h|--help)
                usage
                exit 1;
                ;;
            -v|--version)
                version
                exit 1;
                ;;
        esac
    done
}

# This function upgrades the Ubuntu distribution and installs Security Onion from either the test or production repo.
# This can take up to 30 minutes due the dist-upgrade and Security Onion install.
so_install ()
{
    #    Here we are telling MySQL not to prompt for root password - note this step is key, otherwise you get some funky MySQL errors!
    echo "debconf debconf/frontend select noninteractive" | sudo debconf-set-selections

    if [ $INSTALL == "stable" ]
    then
        sudo add-apt-repository -y ppa:securityonion/stable || echo -e "\n Could not download Security Onion from the Stable repo!" # You will be prompted for a password to 'sudo' at this point
    elif [ $INSTALL == "test" ]
    then
        sudo add-apt-repository -y ppa:securityonion/test || echo -e "\n Could not download Security Onion from the Test repo!"
    else
        echo -e "\nYou did not enter a valid option for the install!\n"
        usage
    fi

    sudo apt-get -y update 
    sudo apt-get -y dist-upgrade && sudo reboot # You need to reboot for the pf_ring DKMS module to build properly

    sudo apt-get -y install python-software-properties # Pre-req

    sudo apt-get -y install securityonion-all #  Installing ALL Security Onion packages. This could take up to 15 minutes.
}

# Function that will kick-off the Security Onion set-up process
# Note that this will require X-Windows so if you've SSH access, ensure you're connecting from an X11 Windows Client.

so_setup ()
{
    sudo sosetup
}

parse_arg $@

so_install

so_setup
