#!/bin/bash

# Really simple nmap scanning script

i=0
j=0

outfile="/var/tmp/discovery.txt"

for i in {0..255}
do
    for j in {0..255}
    do
        nmap -sP 10.31.$i.$j | grep 'Host is up'
        if [ $? -eq 0 ]
        then
            echo "10.31.$i.$j" >> $outfile
        fi
    done
done


for x in $(cat $outfile)
do
    nmap -sS -T4 -Pn --initial-rtt-timeout 250ms --max-rtt-timeout 400ms --max-retries $x -oA /var/tmp/port
done
