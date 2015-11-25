#!/bin/bash
#
# Short simple script to install nmap from svn
#
# Works up to Version 6.47
#

tmp="/var/tmp"

which svn
if [ $? -ne 0 ]; then
    echo -e "\n##########\nNow exiting because you don't have _svn_ install, please fix :)\n##########\n" && exit 1;
else
    cd $tmp
    echo -e "\n##########\nBear with us, this nmap download will take some time as svn connects..........:)\n##########\n";
    svn co https://svn.nmap.org/nmap
    cd nmap
    if [ $(echo $?) -ne 0 ]
    then
        echo -e "\n nmap installed....will now begin to configure\n"
    else
        echo -e "\n nmap did not download via svn....go review the svn output\n"
    fi
fi
# Configuring and making
./configure && make
# Now time to install
sleep 5 && echo -e "\n You will now be prompted for your sudo password to install the binaries for nmap....\n" && sleep 3
sudo make install

which nmap

if [ $? -ne 0 ]
then
    echo -e "\n##########\nnmap didn't install, please fix!\n##########\n" && exit 1;
else
        echo -e "\n nmap is here :) Woot!\n"
fi
