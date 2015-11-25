#!/bin/bash
#
# Bash script to set up a simple, a really simple replica set on Linux or Mac OS.
#
# This script assumes that you have MongoDB installed and mongod is in your path.
#
# You still have to set up the replica set with rs.initiate() and rs.add()
# as per http://docs.mongodb.org/manual/tutorial/deploy-replica-set/
#

# GLOBAL VARIABLES
ARG=$#
key="../files/MyKeyFile" # KeyFile lives one directory down (relatively) in "files"
DATA="$HOME/data/rs"
LOG="/var/tmp/rs"
count=$(ps auwx | grep -c 'mongod.*47')
VERSION="0.1"

# Checking that mongod is installed
check_mongod ()
{
    which mongod > /dev/null
    if [ $? != 0 ]
        then
                    echo "Exiting - mongod is either not installed or in your path, please fix!" && exit 1

    fi
}

# Kill any mongod processes writing with a test replica set running on tcp ports beginning with "47" :)
kill_mongod_all ()
{
for p in $(ps auwx | grep "mongod.*replSet=test.*port=47" | grep -v grep | awk '{print $2}')
do
    kill -9 $p
done
}

# Describing the usage
usage () {
    echo "Usage:
    -n|--number : The number of members in the replica set.
    -h|--help : Print this message.
    -v|--version : Print the version of the script.

    Sample Usage: bash $0 -n 3"
}

# Detailing the version.
version () {
    echo -e "The version is $VERSION.\n"
}

# Parsing the CLI arguments
parse_arg () {
    # Checking for start-up options and if none exist, exit
    if [ $ARG -gt 2 ]
    then
        echo "Please examine the usage options for this script - you can only have one or two command line switches!\n"
        usage
        exit 1
    fi

    for i in  $@
    do
        case $i in
            -n|--number)
                NUMBER=$2
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

start_mongod ()
{
    for ((i=1;i<=$NUMBER;i++))
do
    DF=$DATA$i
    LF=$LOG$i
    mongod --quiet --replSet=test --keyFile ~/MongoDB/keys/MyKeyFile --port=4701$i --dbpath=$DF --fork --logpath=$LF || echo "mongod process $i on port 4701$i has not started"
done

if [ $count -lt 4 ]
then
    echo -e "\nThere should be 3 'mongod' processes running but there isn't. Please check the log files (beginning 'rs') in $LOG."
else
    echo -e "\nAll 3 'mongod' processes have successfully started!!!"
fi
}

echo "$count is count"
parse_arg $@

kill_mongod_all

check_mongod

start_mongod
