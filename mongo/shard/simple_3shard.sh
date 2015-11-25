#!/bin/bash

# Small shell script to set up sharded MongoDB server.

# Once this script is run, further configuration is required through the Mongo Shell - please see http://www.mongodb.org/display/DOCS/A+Sample+Configuration+Session.
# If you've already configured a 3-shard cluster, sharded the database & collection as per the above link then simply running this script should be sufficientIf you've already configured a 3-shard cluster, sharded the database & collection as per the above link then simply running this script should be sufficient.
# This script is very useful for quickly creating a 3-shard cluster and debugging a sharding problem (I think).



# Cleaning up by killing other mongod shardsvr processes

ps auwx | egrep 'mongo(d|s).*(config|shardsvr)' | grep -v grep | awk '{print $2}' | xargs kill

# Setting some variables.

dirs="
$HOME/data/db/1
$HOME/data/db/2
$HOME/data/db/3
"

cdir="$HOME/data/db/config"
ldir="/tmp/shard"
mkdir -p $ldir

rm -rf $ldir/*

s_port="20000" # MongoS port

# Asking where is mongod, as we may be testing a different version
# Need to make this more interactive

#echo "Give me the full path to the mongod version you wish to run......"
#read mongod
mongod=$(which mongod)
echo "Mongod is here at $mongod"
#
#echo "Give me the full path to the mongos version you wish to run......"
#read mongos
mongos=$(which mongos)
echo "Mongos is here at $mongos"

# This is where stuff happens.....

for dir in $dirs
do
        port=$(echo $dir | awk -F/ '{print $NF}')
        if [ -d "$dir" ]
            then
            $mongod --shardsvr --dbpath $dir --port 1000$port --fork --logpath $ldir/shard.$port.log # Start MongoDB Sharded Servers
            continue # Go to next iteration of $dir
        else
            mkdir -p $dir
            $mongod --shardsvr --dbpath $dir --port 1000$port --fork --logpath $ldir/shard.$port.log # Start MongoDB Sharded Servers, if directories don't exist
        fi
done
     
# Config Server & MongoS configuration (with a small chunk size of 1 MB.

if [ -d "$cdir" ]
        then
        $mongod --configsvr --dbpath $cdir --port $s_port --fork --logpath $ldir/configdb.log
        sleep 5
        $mongos --configdb localhost:$s_port --chunkSize 1 --fork --logpath $ldir/mongos.log
else
        mkdir -p $cdir
        $mongod --configsvr --dbpath $cdir --port $s_port --fork --logpath $ldir/configdb.log
        sleep 5
        $mongos --configdb localhost:$s_port --chunkSize 1 --fork --logpath $ldir/mongos.log
fi
