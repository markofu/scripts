#!/bin/bash
#
# Bash script to set up a simple, a really MongoDB instance
#
# This script assumes that you have MongoDB installed and mongod is in your path.
#
mongod --port=15001 --dbpath=$HOME/data/db/syslog --fork --syslog
