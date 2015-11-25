#!/bin/bash
#
# Bash script to set up a simple, a really MongoDB instance
#
# This script assumes that you have MongoDB installed and mongod is in your path.
#
# Create the default data directory for the arbiter

mkdir -p $HOME/data/arb
adir="$HOME/data/arb"
port="47030"
hostname=$(hostname)
rs="test" # Replica Set Name
logfile="/var/tmp/arb.log"

#
#Start the arbiter, making sure to specify the replica set name and the data directory.
#
mongod --port $port --dbpath $adir --replSet $rs --fork --logpath $logfile
#
# Adding the arbiter to the replica set by issuing the rs.addArb() method, which uses the following syntax:
#
mongo --port $port --eval 'rs.addArb("mark-mbp.local:47030")'
