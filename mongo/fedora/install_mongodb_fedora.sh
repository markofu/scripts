#!/bin/bash
# Create a /etc/yum.repos.d/10gen.repo file to hold information about your repository. If you are running a 64-bit system (recommended,) place the following configuration in /etc/yum.repos.d/10gen.repo file
# Assuming that you are running a 64 bit system
# Run this script as "root" or under "sudo"

# Output file
out_f="/var/tmp/mongo_install_fed.log"
cat /dev/null > $out_f

# The yum source file
yum_f="/etc/yum.repos.d/10gen.repo"

ls $yum_f
if [ ! $? -eq 0 ]
then
    echo -e "[10gen]\nname=10gen Repository\nbaseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64\ngpgcheck=0\nenabled=1" > /etc/yum.repos.d/10gen.repo
    echo "Added a new 10gen repo file"
elif [ $? -eq 0 ] && [ $(wc -l /etc/yum.repos.d/10gen.repo) -lt 5 ]
#    if [ $(wc -l $yum_f) -lt 5 ]
then
    echo -e "\n[10gen]\nname=10gen Repository\nbaseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64\ngpgcheck=0\nenabled=1" > /etc/yum.repos.d/10gen.repo
else
    echo -e "\nYum file looks good!!!!\n"
fi

# Installing Packages - the latest stable version of MongoDB and the associated tools. When this command completes, you have successfully installed MongoDB!
# Configure MongoDB - these packages configure MongoDB using the /etc/mongod.conf file in conjunction with the control script. You can find the init script at /etc/rc.d/init.d/mongod.
# This MongoDB instance will store its data files in the /var/lib/mongo and its log files in /var/log/mongo, and run using the mongod user account.

echo "Begun installing packages"
yum install -y mongo-10gen mongo-10gen-server 2>&1 >> $out_f
echo "Finished installing packages"

# Note If you change the user that runs the MongoDB process, you will need to modify the access control rights to the /var/lib/mongo and /var/log/mongo directories.
# Checking that MongoD can start: the mongod process by issuing the following command (as root, or with sudo):
# MongoDB logs are found at /var/log/mongo/mongod.log.

service mongod start 2>&1 >> $out_f
if [ ! $? -eq 0 ]
then
    echo -e "\nThere is an issue MongoDB isn't starting, whatttttttttdddddd!!!!\n"
fi
# Ensuring that MongoDB will start following a system reboot - taking the default run levels.

chkconfig mongod on 2>&1 >> $out_f

# Checking that mongo can be stopped and restarted

service mongod stop 2>&1 >> $out_f
if [ ! $? -eq 0 ]
then
    echo -e "\nThere is an issue MongoDB isn't stopping, whatttttttttdddddd!!!!\n"
fi

service mongod restart 2>&1 >> $out_f
if [ ! $? -eq 0 ]
then
    echo -e "\nThere is an issue MongoDB isn't REstarting, whatttttttttdddddd!!!!\n"
fi

# Test that you can connect to the database (via localhost) and insert data into the "mycoll" collection of the default "test" database

mongo test --eval 'db.mycoll.save( { a: 1 })' 2>&1 >> $out_f
mongo test --eval 'db.mycoll.find()' 2>&1 >> $out_f
