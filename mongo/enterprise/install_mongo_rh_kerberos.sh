#!/bin/bash
#
#
# This script needs to be made nicer with functions and stuff :)

USAGE="Usage: $(basename $0) $N [-hv]. For example, to configure your mongod instance for Realm 4, run 'bash install_rh_mongo.sh 4'."
VERSION="0.1"

# Checking that the script is run with an option
if [ $# -eq 0 ]
then
    echo -e "$USAGE\n";
    echo -e "Please run with a valid option! Help is printed with '-h'."
    exit $E_OPTERROR;
fi

# Parsing CLI options

for arg in "$@"
do
    case $arg in 
         -h|--help)
             echo -e "\n$USAGE\n";
             exit 0;
             ;;
          -v|--version)
             echo -e "\nVersion $VERSION.\n" 
             exit 0;
             ;;
    esac
done

# Here we pick up the value for N, which is based on your realm number.
N=$1
echo "N is $N"

# Global variables
USR_DIR="/usr/local/bin"
BIN_DIR="/usr/local/bin/mongodb/bin"
HOME="/root"
DOWN_DIR=$(echo $download | sed -e 's/.tgz$//')

download="mongodb-linux-x86_64-subscription-rhel62-2.4.0-rc0.tgz"
profile="$HOME/.bash_profile"
rc="$HOME/.bashrc"
epel_repo="/etc/yum.repos.d/epel.repo"
krb5_conf="/etc/krb5.conf"

# Create directories 
mkdir -p /data/db

# Download MongoDB and tidy up
wget http://downloads.10gen.com/linux/$download -O $USR_DIR/$download &> /dev/null || echo "Failed to download MongoDB - $download"
tar xvfz $USR_DIR/$download
mv $DOWN_DIR $USR_DIR/mongodb
rm $USR_DIR/$download

# Enabling the epel.repo & restoring the required libraries - libgsasl is only found in the epel repos where SNMP & SSL are in the standard libraries.
# See  https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F
echo -e "\n#####\nUpdating the various repositories and dependencies now!\n####\n"
rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

sed -i 's/enabled=0/enabled=1/' $epel_repo
yum update -y &> /dev/null
if $? != 0
then 
    exit 1
fi
echo "Repositories Updated."
yum install -y net-snmp net-snmp-libs net-snmp-utils libgsasl > /dev/null
if $? != 0
then 
    exit 1
fi
echo "Installing of SSL, SNMP & SASL dependencies done."

# Some sed stuff to replace content in various files to ensure an easier life
sed -i.bak 's/\/bin$/\/bin:\/usr\/local\/bin\/mongodb\/bin/' $profile
. $profile || echo failed-profile
echo -e "\n# Additional useful aliases!\nalias psm='ps auwx | grep mongo | grep -v grep'" >> $rc
. $rc || echo failed-rc
#
echo -e "\n#####\nEditing the krb5.conf file now!\n####\n"
#
sed -i.bak "s/EXAMPLE.COM/REALM$N.10GEN.ME/g" $krb5_conf
sed -i "s/example.com/realm$N.10gen.me/g" $krb5_conf
sed -i "s/kerberos/ns/g" $krb5_conf
