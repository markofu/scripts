#!/usr/bin/perl -w
#
# Analyse AGEE Logins for Networking TRM Customer
# Written by Mark Hillick (Citrix Networking TRM - EMEA Team)
#
# Version 0.1 - November 2012 - Converted from bash with lots of things still to do ;-)
# Version 0.2 - November 2012 - Added login-type checking with nested for loops!
# Version 0.3 - December 2012 - Add a second array within the first foreach loop to pick up the client type. This second array was required due to different UAs causing issues with splitting on ' ' so I'd to split on '-'.
# Version 0.31 - 15th December 2012 - Added checks for multiple groups through calling dash_line[9]. Could be done nicer but hey :)
#
# TO DO: Add sub-routines so that we have reusable code!
# TO DO: Consider using a hash.
#
#
use strict;

# Declaring variables

my $outfile ="/var/tmp/ag_out.csv"; # This file contains all required information and just import it into excel.
my $errfile ="/var/tmp/ag_err.log";
my $dir ="/var/log";
my $nsfile;
my $counter1=0;
my $counter2=0;

my @login;
my @logout;
my @out_lines;
my @in_lines;
my @dash_lines;
my @nslogs;


open(OUTFILE, ">$outfile") or die "Unable to open log file:$!";
open(ERRFILE, ">$errfile") or die "Unable to open error log file:$!";
opendir(INDIR, "$dir") or die "Unable to open input directory:$!";
#
# Defining the nslogs - looking for files beginning with ns.log and checking that it's a file
# The "*" ensures that we pick up the gzip files
#
@nslogs = grep {
/ns.log.*$/ && -f "/$dir/$_"
}
readdir (INDIR);
#
# We're printing out the date/time field (5), the timezone (6), the SSL action (10 & 11), the session id (18), the username (20), the Client IP (23), the vServer IP (30), the start time for the connection (33), the end time for the connection (37) and the duration (41).
#
#
# Outputing the headings and some row separators
#
print OUTFILE "Date, Timezone, Action, Session ID, User, Client IP, vServer, Start Time, End Time, Duration, Logout Method, Group Membership, Connection Type\n";
print OUTFILE "-----,-----,-----,-----,-----,-----,-----,-----,-----,-----,-----,-----,-----\n";

foreach $nsfile (@nslogs) {
    if ($nsfile =~ /ns.log.[0-9].*.gz$/) {
        open(NSFILE, "gunzip -c $dir/$nsfile|") or die "Unable to open ns.log gzipped:$!";
        }
        else {
            open(NSFILE, "$dir/$nsfile") or die "Unable to open file ns.log :$!";
        }
    while (<NSFILE>) {
        chomp;
#
# Searching for SSLVPN logouts with valid Session IDs.
#
        if (/SSLVPN LOGIN.*Sess/) {
            $login[$counter1]=$_;
            $counter1++;
        }
        elsif (/SSLVPN LOGOUT.*Sess/) {
            $logout[$counter2]=$_;
            $counter2++;
        }
        else {
           print ERRFILE "No match:|$_|\n";
        }
    }
}

foreach my $login_match(@login) {
    @in_lines = split(' ',$login_match);
    $in_lines[18] =~s/-//; # Removing the extraneous hyphen in the Session ID
#
# Creating a second array due to various User Agents having more details than others and also all groups (when a user is a member of more than one) :(
#
    @dash_lines = split('-',$login_match);
    $dash_lines[8] =~s/ SSLVPN_client_type //; # Removing the SSLVPN type header
    $dash_lines[9] =~s/ Group\(s\) "(.*)"/$1/; # Removing the Group header, comma (so that we .csv format is still valid) and leaving the quotes
    $dash_lines[9] =~s/,/ /g; # Removing the quotes and commas. Tried doing it in one line but got messy with commas and back-references :(
    foreach my $logout_match (@logout) {
        @out_lines = split(' ',$logout_match);
        $out_lines[18] =~s/-//;
        $out_lines[33] =~s/"//; # Removing the extraneous quotes in Start Time id field
        $out_lines[37] =~s/"//; # Removing the extraneous quotes in End Time id field
        $out_lines[80] =~s/"//g; # Removing the extraneous quotes in Logout Method field
        $out_lines[83] =~s/"//g; # Removing the extraneous quotes in Group Membership field
#
# Ensuring that we have matching session IDs so there's no incorrect outputs.
#
        if ($out_lines[18] =~m/$in_lines[18]/) {
            print OUTFILE "$out_lines[5],$out_lines[6],$out_lines[10] $out_lines[11],$out_lines[18],$out_lines[20],$out_lines[23],$out_lines[30],$out_lines[33],$out_lines[37],$out_lines[41],$out_lines[80],$dash_lines[9],$dash_lines[8]\n";
            last;
        }
        else {
            print ERRFILE "Session $in_lines[18], with user $in_lines[21] did not logout yet.\n";
        }
    }
  close(NSFILE);
}
close(OUTFILE);
close(ERRFILE);
closedir(INDIR);
exit 0;
