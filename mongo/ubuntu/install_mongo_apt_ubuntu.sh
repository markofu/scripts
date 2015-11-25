#!/bin/bash

# Adding the key for the 10gen repo
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

# Create a the /etc/apt/sources.list.d/10gen.list file & including the latest version from the 10gen repository
sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" > 10gen.list
sudo mv 10gen.list /etc/apt/sources.list.d/10gen.list

# Reloading the list of repositories
sudo apt-get update

# Installing packages (typically the latest stable version of MongoDB)
sudo apt-get install mongodb-10gen

# Checking that mongod is now running
num=$(ps auwx | grep -v grep | grep -c 'mongod --config')
if [ $num -gt 0 ]
then 
    echo "MongoD is running in config mode"
else
    echo "MongoD is not running"
fi
