## scripts

Simple scripts (nothing artistic) that I've used. Sadly not all my scripts can be uploaded but some's better than none :)

- "agee_login.pl": one of the few Netscaler scripts I still have and that I can technically publish. It calculates information on AGEE (SSL VPN on Netscaler) and spits it out in a .csv format. Unbeliavably a lot of this information is not in the Netscaler reporting tools.

- "mongodb-apt-checker.sh": bash script written to verify Ubuntu Upstart packaging works across multiple versions of MongoDB

- "simple3_shard.sh": bash script to quickly set up a 3-shard cluster. The data either needs to be imported after and the db & collection sharded OR it's previously been done. Very useful for quickly testing or repro'ing something.

- "shard.sh": bash script that sets up a 3-shard cluster and imports data from Twitter in json format.

- "apt-key-manual_10gen.sh": quick, little script to pull down 10gen gpg key for "aptitude" package manage when Ubuntu key-server is non-responsive (which sadly happens too frequently)


*Usage:* for all the above scripts, make executable via "chmod a+x $script" and execute or "bash $script" for the shell scripts and "perl $script" for the perl scripts etc.

