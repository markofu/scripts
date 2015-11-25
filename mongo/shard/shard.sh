#!/bin/bash

# Small shell script to set up sharded MongoDB server.
# Currently this script assumes that you have mongod and mongos installed, I know it's a little pre-sumptious but hey :)
# The script then starts a sharded cluster from scratch (all elements),shards a database, pulls down json data from the Interwebs and imports it into a collection in a database and in turn shards that collection.

# This script runs in interactive mode by default.

# TO DO: More clever around "sleeping".
# TO DO: More dynamic around directory creation and ability to set data directory on cli.
# TO DO: Provide options to modify the number of shards.
# TO DO: Include replica sets possibly?
# TO DO: Specifiy binaries of mongos and mongod on the cli.
# TO DO: Review 'getopts" usage".
# TO DO: Consider "eval" usage with .js file after shard cluster creation.

set -e

# Declaring the USAGE variable.

USAGE="Usage: $(basename $0) [-fhiv] [-b arg] [-m arg] [-d arg] [-s arg] [-o arg]."

VERSION="0.4"

# Checking that the script is run with an option
if [ $# -eq 0 ]
then
    echo -e "$USAGE\n";
    echo -e "Please run with a valid option! Help is printed with '-h'."
    exit $E_OPTERROR;
fi

########## Function Definitions Start ##########

# Checking if mongo is installed by looking for mongod across multiple *nix platforms
installed_mongo ()
{
which mongod
if [ ! $? -eq 0 ]
then
    which apt-get
    [ $? -eq 0 ] && echo -e "\nYou seem to be running a Ubuntu distro, please go to http://docs.mongodb.org/manual/tutorial/install-mongodb-on-debian-or-ubuntu-linux/ for further information on installing MongoDB for Ubuntu.\n" && exit 1;
    which yum
    [ $? -eq 0 ] && echo -e "\nYou seem to be running a Red Hat distro, please go to http://docs.mongodb.org/manual/tutorial/install-mongodb-on-redhat-centos-or-fedora-linux/ for further information on installing MongoDB for Red Hat.\n" && exit 1;
    uname -a | grep Darwin
    [ $? -eq 0 ] && echo -e "\nYou seem to be running on OSX, please go to http://docs.mongodb.org/manual/tutorial/install-mongodb-on-os-x/ for further information on installing MongoDB for Mac OS.\n" && exit 1;
fi
}

# Function defining mongod and mongos. Provides the ability to run different versions of mongod and mongos...woot!!!

define_mongo ()
{
case "$answer_d" in
    y|Y) mongod=$(which mongod)
    ;;
    n|N) echo -e "What is the full path to mongod?\n"
        read mongod
    ;;
    *) echo -e "\nPlease enter 'y' or 'n', nothing-else (case-insensitive). Now exiting, bye bye!\n";
        exit 12;
esac

echo -e "\nmongod is @ '$mongod'\n"

case "$answer_s" in
    y|Y) mongos=$(which mongos)
    ;;
    n|N) echo -e "What is the full path to mongos?\n> "
        read mongos
    ;;
    *) echo -e "\nPlease enter 'y' or 'n', nothing-else (case-insensitive). Now exiting, bye bye!\n";
        exit 13;
esac

echo -e "\nmongos is @ '$mongos'\n"
}

# Function for stopping all existing mongod and mongos processes..... 
stop_mongo ()
{
    if [ $(ps auwx | egrep 'mongo(d|s)' | grep -vc egrep) -gt 0 ]
    then
        echo -e "\nThere are currently some mongo(d|s) processes running!!!!\n";
        case "$byebye" in
            y|Y) echo -e "\nKilling every mongod and mongos.....\n" 
                ps auwx | egrep 'mongo(d|s)' | egrep -v egrep | awk '{print $2}' | xargs kill -9 # killall wasn't reliable as I name the binaries per the version
            ;;
            n|N) echo -e "\nMoving on, not killing anything.....\n"
            ;;
            *) echo -e "\nPlease enter one of 'y', 'Y', 'n' or 'N'. Now exiting, bye bye!\n"
                 exit 10;
            ;;
         esac
    fi
}

# Function for starting mongod instances, config server and mongos......

start_mongo ()
{
    for dir in $d_dirs
    do
        port=$(echo $dir | awk -F/ '{print $NF}')
        $mongod --shardsvr --dbpath $dir --port 100$port --fork --logpath $ldir/shard.$port.log $MONGOD_PARAMS
    done
# MongoS port => for loop to check if there is a free port around this range.
    for port in {20000..20100}
    do
        if [ $(netstat -an | egrep -c $port.*LISTEN) -eq 0 ]
        then
            s_port=$port
            echo -e "\nmongos is running on port $s_port.\n"
            "break"
        else
            continue
        fi
    done
# Config Server & MongoS configuration (with a small chunk size of 1 MB)

    $mongod --configsvr --dbpath $cdir --port $s_port --fork --logpath $ldir/configdb.log $MONGOD_PARAMS 

    echo -e "\n ==> Sleeping for 60 seconds after starting the config server...\n"
    sleep 60

    # Ensuring that all 3 mongod shards have started up correctly!

    if [ $(ps auwx | egrep -c 'mongod.*--shardsvr'| egrep -v egrep) -lt 3 ]
    then
        echo -e "There's a problem starting some of the shards, please examine the debug information in the relevant shard.*.log file in $ldir.\n";
        echo -e "Now exiting!\n";
        exit 13;
    elif [ $(ps auwx | egrep -c 'mongod.*--configsvr'| egrep -v egrep) -lt 1 ]
    then
        echo -e "There's a problem starting the config server, please examine the debug information in the config server configdb.log file in $ldir.\n";
        echo -e "Now exiting!\n";
        exit 14;
    else
        echo -e "\nAll three mongoD shards and config server have started correctly. Wuhoo!\n";
    fi

    $mongos $MONGOS_PARAMS --configdb localhost:$s_port --chunkSize 1 --fork --logpath $ldir/mongos.log

    echo -e "\n ==> Sleeping for 180 seconds after starting the mongos...\n";
    sleep 180

    # Ensuring that the mongos has started up correctly!

    if [ $(ps auwx | egrep -c 'mongos'| egrep -v egrep) -lt 1 ]
    then
        echo -e "There seems to be a problem starting the mongos, please examine the debug information in the mongos.log file in $ldir.\n";
        echo -e "Now exiting!\n";
        exit 15;
    else
        echo -e "\nIt looks like the mongos has started correctly. Wuhoo!\n"
    fi
}

# Function for removing old MongoDB data.......

remove_mongo_data ()
{
case "$remove" in
    # If they are created, removing the redundant data so we have a clean start.
    y|Y) for all in $all_dirs
         do
           [ -d $all ] && $del $all/* && echo -e "\n ==> Removing old sharding & config data in $all.\n"
         done
    ;;
    n|N) [ -d $all ] && echo -e "\nKeeping the old sharding and config data. Hopefully you're not going to import data that's already there.\n"
    ;;
    *) echo -e "\nPlease enter 'y' or 'n', nothing-else (case-insensitive). Now exiting, bye bye!\n";
        exit 11;
    ;;
esac
}

# Function checking for the existence of the data directories
exist_datadir ()
{
for all in $all_dirs
do
    # Ensuring all required directories are created.
    if [ ! -d $all ]
    then
        mkdir -p $all
    else
        continue
    fi
done
}

# Function that creates the shards. Unable to pass a variable from bash to the mongo shell inside the "db.runCommand" :(
create_shard ()
{
echo -e "\n ==> Adding shards on ports 10000, 10001 and 10002.\n";
mongo admin --eval 'db.runCommand( { addshard : "localhost:10000" } )'
mongo admin --eval 'db.runCommand( { addshard : "localhost:10001" } )'
mongo admin --eval 'db.runCommand( { addshard : "localhost:10002" } )'

# Checking the shards have been created successfully.

for dir in $d_dirs
do
    i=$(echo $dir | awk -F/ '{print $NF}')
    [ $(mongo admin --eval 'sh.status()' | grep -c :100$i) -eq 1 ] && echo -e "\nAdded shard on port 100$i.....\n"
done
}

# Function for importing data into the "tweets" collection in the twitter database. This can be dynamically with an Interet connection via Twitter or via a local file (json or bson).

import_data ()
{
case "$import" in
    y|Y) # Using the "real" Twitter to collate some data
        echo -e "\nChecking internet connectivity (http GET to twitter.com)\n";
        curl -s -o /dev/null twitter.com 2>&1
        if [ $? -eq 0 ]
        then
            echo -e "\nInterweb connectivity looks good!\n";
            echo -e "\nRetrieving hashtags:\n";
            for coll in $hashtags
            do
                echo -e "#$coll...\n";
                # Used 'tee' initially but too much standard output.
                curl -s https://search.twitter.com/search.json?q=%23$coll >> $twitter_json
                echo "" >> $twitter_json
            done
            # Just making the twitter.json larger so that chunks actually split across the shards.
            for i in {1..6}
            do
                cp $twitter_json $temp_json
                cat $temp_json >> $twitter_json
            done
            $del $temp_json # Cleaning up.
            # Importing the data retrieved from the Interweb.
            mongoimport -d twitter -c tweets --file $twitter_json && echo -e "\nImporting the dynamically created twitter.json file.\n"
        else
            echo -e "\nHTTP GET to Twitter has failed. Please verify you have network connectivity and HTTP outbound is allowed (unless Twitter is actually down :S). Surely, it is? It's only a test, not a production DB with real, production data, is it?\n"
            exit 16;
        fi
    ;;
    m|M) echo -e "\nManually importing json file.\n";
        read $import_file
        suffix=$(echo $import_file | awk -F. '{print $NF}')
        if [ $suffix == "json"]
        then
        mongoimport -d twitter -c tweets --file $import_file && echo -e "\nImporting $import_file. The database is called 'twitter' and the collection is 'tweets'."
        else
            echo -e "\nPlease provide a valid json file for import. Now exiting, bye bye!\n";
            exit 17;
        fi
    ;;
    b|B) echo -e "\nManually importing bson file.\n";
         read $import_file
         suffix=$(echo $import_file | awk -F. '{print $NF}')
         if [ $suffix == "bson"]
         then
             mongorestore --objcheck -d twitter -c tweets $import_file && echo -e "\nImporting $import_file. The database is called 'twitter' and the collection is 'tweets'."
         else
             echo -e "\nPlease provide a valid bson file for import. Now exiting, bye bye!\n";
             exit 18;
         fi
    ;;
    *) echo -e "\nIf in interactive mode, please enter 's', 'j' or 'b', nothing-else (case-insensitive). Now exiting, bye bye!\n";
        exit 19;
    ;;
esac
}

# Function that enables sharding on the Twitter database and checks the sharded status.

db_shard ()
{
mongo admin --eval 'db.runCommand( { enablesharding : "twitter" } )'
[ $(mongo admin --eval 'sh.status()' | egrep -c 'twitter.*part.*true') -eq 1 ] && echo -e "Twitter DB Successfully sharded, woot!\n"
}

# Function that creates an index so we subsequently create a shard key over it and then sharding the tweets collection.

coll_shard ()
{
mongo twitter --eval 'db.tweets.ensureIndex({"query":1, "max_id":1})'
mongo admin --eval 'db.runCommand( { shardcollection : "twitter.tweets", key : {"query": 1, "max_id": 1} } )'
}

# Function to check that we have successfully sharded a collection and have some chunks :)

check_chunks ()
{
if [ $(mongo twitter --eval 'sh.status()' | grep -q chunks && echo $?)  -eq 0 ]
then
    echo -e "\nSuccess, we've sharded a collection....wuhoo!\n";
else
    echo -e "\nWe've got a problem here, there are no chunks!\n";
    exit 20;
fi
}


# Tidy up - deleting the json file that we created from Twitter hashtags.
tidy_up ()
{
$del $twitter_json
}
########## Function Definitions End ##########

# Parse command line options.
while getopts fhivb:d:m:o:r:s: OPT
do
    case "$OPT" in
        b)
            byebye="y"
            remove="y"
            answer_d="y"
            answer_s="y"
            import="b"
        ;;
        d) mongod=$OPTARG
        ;;
        f)
            byebye="y"
            remove="y"
            answer_d="y"
            answer_s="y"
            import="y"
            tidy="y"
        ;;
        h)
            echo -e "$USAGE\n";
            echo "-b:  Forcibly answer yes for everything but manually import and reference a bsondump file as an argument.";
            echo "-f:  Forcibly answer yes for everything. Dynamically imports a json file created from retrieving Twitter hashtags.";
            echo "-h:  Help";
            echo "-i:  Run in interactive mode. Do not use with '-d', -f', '-s'";
            echo "-m:  Forcibly answer yes for everything but manually import and reference a json file as an argument.";
            echo "-o:  Output to file (requires an argument)";
            echo "-r:  CLI option to manually remove all previous data created by previous runs of this script.";
            echo "-s:  Specify a different version of mongos (requires an argument)";
            echo "-v:  Version Information.\n";
            echo "Examples:"
            echo "`bash shard.sh -f` will forcibly say 'yes' to all options and create the sharded cluster containing data from Twitter";
            echo "`bash shard.sh -i` will prompt you for answers;"
            echo "`bash shard.sh -d /usr/bin/mongodb-2.2.0/bin/mongod -s /usr/bin/mongodb-2.2.1.mongos` will run a 2.2.0 mongod instance with a 2.2.1 mongos, removing all previous sharded data";
            exit 0;
        ;;
        i) # The interactive questions over and done with :) Putting them all together to enable a "force-yes" option, there must be a cleaner way though.
            if [ $(ps auwx | egrep 'mongo(d|s)' | grep -vc egrep) -gt 0 ]
            then
                echo -e "As we're testing, is it ok to kill any mongod and mongos processes that may be running (y/n)?\n";
                read -n 1 -p '> ' byebye
            fi
            echo -e "\nHave you previously run this script and want to remove your original data (y/n)?\nEntering 'y' means that all previous sharding and config data will be removed.\n"
            read -n 1 -p '> ' remove
            echo -e "\nIs mongod @ '$(which mongod)' (y/n)?\n"
            read -n 1 -p '> ' answer_d
            echo -e "\nIs mongos @ '$(which mongos)' (y/n)?\n"
            read -n 1 -p '> ' answer_s
            echo -e "\nTo allow the script perform its default action and import data from the Interwebs, enter 'y'.\nTo manually import your own json data via 'mongoimport', manually enter 'm'.\nTo manually import a bson dump with mongorestore, enter 'b'.\n";
            read -n 1 -p '> ' import
            if [ $import == "y" ]
            then
                echo -e "\nDo you want to clean up by removing the dynamically created Twitter json file @ the end? (y/n)?\n"
                read -n 1 -p '> ' tidy
            else
                continue
            fi
        ;;
        m)
            byebye="y"
            remove="y"
            answer_d="y"
            answer_s="y"
            import="m"
        ;;
        o) OUTPUT_FILE=$OPTARG
        ;;
        r) remove=$OPTARG
        ;;
        s) mongos=$OPTARG
        ;;
        v)
            echo -e "\nVersion 0.4 of $(basename $0)\n";
            exit 0;
        ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2;
            echo $USAGE 1>&2
            exit 1;
        ;;
        :)
            echo "The option -$OPTARG must have an argument." 1>&2
            exit 1
        ;;
    esac
done

########## Variable Definitions Start ##########

# Setting some variables. As this is only testing, we'll create the data directories under the home directory. This will also ensure that we don't have to worry about permissions issues.

d_dirs="
$HOME/data/db/00
$HOME/data/db/01
$HOME/data/db/02
"

cdir="$HOME/data/db/config"
ldir="/var/tmp/shard"

all_dirs="
$cdir
$ldir
$d_dirs
"
twitter_json="/var/tmp/twitter.json" # JSON file for the data input to create the sharded collection
temp_json="/var/tmp/temp.json" # JSON file for the data input to create the sharded collection

del="rm -rf"

# Additional parameters for both mongod and mongos
#MONGOD_PARAMS="--nojournal --noprealloc" These options make MongoD quicker to load, NEVER run without a journal in production btw!!!
MONGOD_PARAMS="--noprealloc"
MONGOS_PARAMS=""

# Using Twitter hashtags to pull down data in json format.

hashtags="
news
christmas
xmas
olympics
jobs
business
football
FF
FollowFriday
security
soccer
epl
premiership
nba
nfl
mlb
nhl
laliga
news
cloud
ladygaga
bigdata
xfactor
london
newyork
sanfrancisco
google
apple
iphone
android
twitter
facebook
fb
music
"

########## Variable Definitions End ##########

installed_mongo

stop_mongo

remove_mongo_data

define_mongo

exist_datadir

start_mongo

create_shard

db_shard

import_data

coll_shard

check_chunks

[ $tidy == "y" ] && tidy_up
