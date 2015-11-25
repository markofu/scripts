#!/bin/bash
#
# Bash script to set up a simple, a really MongoDB instance
#
# This script assumes that you have MongoDB installed and mongod is in your path.
#
mongod --port=5001 --auth --dbpath=$HOME/data/db/single --fork --logpath=/var/tmp/single
