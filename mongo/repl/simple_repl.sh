#!/bin/bash
#
# Bash script to set up a simple, a really simple replica set on Linux or Mac OS.
#
# This script assumes that you have MongoDB installed and mongod is in your path.
#
# You still have to set up the replica set with rs.initiate() and rs.add()
# as per http://docs.mongodb.org/manual/tutorial/deploy-replica-set/
#
mongod --replSet=test --port=47017 --dbpath=$HOME/data/rs1 --fork --logpath=/var/tmp/rs1
mongod --replSet=test --port=47018 --dbpath=$HOME/data/rs2 --fork --logpath=/var/tmp/rs2
mongod --replSet=test --port=47019  --dbpath=$HOME/data/rs3 --fork --logpath=/var/tmp/rs3
