#!/bin/bash
#
# Due to the Ubuntu key-server being down for a user, I wrote a simple  
# bash script to pull the key file down and manually import it to the apt keychain!
#
keydir="/var/tmp/10gen-key"
mkdir -p $keydir
wget -O $keydir/10gen-gpg-key.asc http://docs.mongodb.org/10gen-gpg-key.asc
sudo apt-key add $keydir/10gen-gpg-key.asc 
rm -rf $keydir
