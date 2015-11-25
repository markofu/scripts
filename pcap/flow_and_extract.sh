#!/bin/bash
# Short script that parses the pcap to analyse the streams and flows
# Originally written for SANS Christmas Hack Challenge 2013
#

# Global Variables

VERSION="0.1"
ARG=$#

flow_out="out_flow.log"
fore_out="out_fore"

# Detailing the version
version () {
    echo -e "The version is $VERSION.\n"
}

# Describing the usage
usage () {
    echo -e "Usage:
    -h|--help : Print this message.

    Usage: bash $0 PCAP_FILE

    Sample Usage: bash $0 /var/tmp/malicious.pcap"

}

# Parsing the CLI arguments

parse_arg () {
    # Checking for start-up options and if none exist, exit
    if [ $ARG -ne 1 ]
    then
        echo "Please examine the usage options for this script - you need to specify the pcap file!\n"
        usage
        exit 1
    fi
}

clean_up() {
ls -d output
if [ $? -eq 0 ]
then
    mv output output.$(date +"%Y-%m-%d-%H")
fi
for i in flow_out fore_out
do
    cat /dev/null > $i
done
}

run_tcpflow () {
    which tcpflow
    if [ $? -ne 0 ]
    then
        echo -e "\n##########\nNow exiting because tcpflow either doesn't exist or it's not in your path. Please resolve!!\n##########\n" && exit 5;
    else
        tcpflow -r $pcap -C -B > $flow_out
    fi
}
    
run_foremost () {
    which foremost
    if [ $? -ne 0 ]
    then
        echo -e "\n##########\nNow exiting because foremost either doesn't exist or it's not in your path. Please resolve!!\n##########\n" && exit 5;
    else
        foremost $flow_out -o $fore_out
fi
}

parse_arg $@

clean_up

run_tcpflow

run_foremost
