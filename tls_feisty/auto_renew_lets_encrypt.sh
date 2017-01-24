#!/bin/bash

# This was a simple bash script to automatigically renew a server cert from LetsEncrypt
#
#
# Add this script to your cron to run daily and it will automatically renew your cert within 2 weeks of its expiry date
#
# Requirements :: python, openssl ( both should be there by default) and https://github.com/diafygi/acme-tiny

# Some Variables

live_server_crt_chained="/etc/nginx/server-all.crt"
key="/etc/nginx/letsencrypt.key"
csr="/etc/nginx/server.csr"
acme_dir="/var/www/.well-known/acme-challenge/"
new_server_crt="/etc/nginx/server.crt"
intermediate_crt="/etc/nginx/intermediate.crt"
day=$(date +%y%m%d)

check_cmds(){
    which openssl
    if [ echo $? -ne 0 ]
    then
        echo -e "OpenSSL isn't installed, please install!\n" && exit
    fi
    which acme_tiny.py
    if [ echo $? -ne 0 ]
    then
        echo -e "acme_tiny_py isn't installed, please install!\n" && exit
    fi
}
back_up(){
    if [[ $(ls $new_server_crt.* | wc -l) > 2 ]]
    then
        # Deleting all old  server cert copies save the most recent
        ls -r $new_server_crt.* | head -n -1 | xargs rm
    fi
    if [[ $(ls $live_server_crt_chained.* | wc -l) > 2 ]]
    then
        # Deleting all old chained cert copies save the most recent
        ls -r $live_server_crt_chained.* | head -n -1 | xargs rm
    fi
    cp $new_server_crt $new_server_crt.$day
    cp $live_server_crt_chained $live_server_crt_chained.$day
}

# Check is cert expires in the next two weeks
cert_check(){
    openssl x509 -checkend 1209600 -noout -in $live_server_crt_chained
    if [ $? -eq 0 ]
    then
         echo -e "Certificate does not expire in the next two weeks!\n" && exit
    else
         echo -e "Certificate will expire in the next 2 weeks or is invalid/not found!\n"
         echo -e "Renewing the certificate for $(hostname)!\n"
         python $(which acme_tiny.py) --account-key $key --csr $csr --acme-dir $acme_dir > $new_server_crt
         cert_chain_create
    fi
}

cert_chain_create(){
    if [ ! -f "$intermediate_crt" ]
    then
        wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > $intermediate_crt
    else
        echo -e "Intermediate Certificate for LetsEncrypt already exists on the server!\n" && exit
    fi
    cat $new_server_crt $intermediate_crt > $live_server_crt_chained
}

back_up
cert_check
