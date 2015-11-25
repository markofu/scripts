#!/bin/bash

ips="ntp_ips.lst"
out="ntp_results.lst"

for i in $(cat $ips)
do
    echo $i
    sudo nmap -sU -p 123 --script=ntp-monlist.nse 127.0.0.1 >> $out
done
