#!/bin/bash
#
# Simple Bash script to check if the Ubuntu Upstart repos work

# Cleaning out the lock files in case there was a previous corrupt dpkg issue
lock="
/var/cache/apt/archives/lock
/var/lib/dpkg/lock"
for file in $lock
do
    if [ ! -f $file ]
    then
        echo -e "$file doesn't exists\n"
    else
        sudo rm $file
    fi
done

# I am only concerned with the production builds.

builds="
1.8.
2.0.
2.2.
"

# Defining apt-get as a variable for the craic
get=$(which apt-get)

pkg="mongodb-10gen="
pkg18="mongodb18-10gen="
install="sudo $get install -f -y --force-yes -q"
mongod="$(which mongod)"

# Editing & updating the apt source file
apt_f="/etc/apt/sources.list"

count1=$(egrep -c '1.8 10gen' $apt_f)
count2=$(egrep -c '2.0 10gen' $apt_f)
count3=$(egrep -c '2.2 10gen' $apt_f)

if [ $count1 -lt 1 ]
then
    echo -e "\ndeb http://packages.10gen.cc/repo/ubuntu-upstart 1.8 10gen\n" | sudo tee -a $apt_f
elif [ $count2 -lt 1 ]
then
    echo -e "\ndeb http://packages.10gen.cc/repo/ubuntu-upstart 2.0 10gen\n" | sudo tee -a $apt_f
elif [ $count3 -lt 1 ]
then
    echo -e "\ndeb http://packages.10gen.cc/repo/ubuntu-upstart 2.2 10gen\n" | sudo tee -a $apt_f
else
    echo -e "\n#############\nsources.list up to date\n#############\n"
fi

# Updating the repository list
sudo $get -qq update 

# Files
out="/var/tmp/mongodb-pkg-results.log"

# for loop to test upgrading and downgrading mongod, hence the 'funny' order of the second loop
for bld in $builds
do
    if [ "$bld" =  "2.0." ]
    then
        for v in 2 6 0 4 7 5 3 1
        do
            echo -e "Current version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" > $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
            $install $pkg$bld$v
            echo -e "New version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" >> $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
        done 
    elif [ "$bld" =  "2.2." ]
    then
        for v in 1 0
        do
            echo -e "Current version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" > $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
            $install $pkg$bld$v
            echo -e "New version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" >> $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
        done 
    elif [ "$bld" =  "1.8." ]
    then
        for v in 2 0 3 1
        do
            echo -e "Current version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" >> $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
            $install $pkg$bld$v
            echo -e "New version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" >> $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
        done
        for v in 5 4
        do
# name change for versions .4 and .5 for some reason :)
            echo -e "Current version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" >> $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
            $install $pkg$bld$v
            echo -e "New version of mongod is $($mongod --version | awk '/^db/ {print $3}' | tr -d "[v,]")" >> $out
            echo -e "mongod process running as $(ps awx | grep 'mongodb.conf' | head -1 | awk '{print $(NF -2) " " $(NF-1) " " $NF}')\n" >> $out
        done
    else
        exit
    fi
done
