#!/bin/bash
#
# Bash script to set up a simple, a really MongoDB instance
#
# This script assumes that you have MongoDB installed and mongod is in your path.
#
# Turns on authentication
#
mongod --port=6001 --auth --dbpath=$HOME/data/db/auth --fork --logpath=/var/tmp/auth
