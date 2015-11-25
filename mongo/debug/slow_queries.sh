#!/bin/sh
#
# This script looks for slow queries in specific log files.
#
# The script outputs the analysis to /var/tmp/slowqueries.out unless specified otherwise on the cli.
# Declaring some variables.

USAGE="Usage: $(basename $0) [-hv] [-d arg] [-i arg] [-m arg] [-n arg] [-o arg]). Options '-i' and '-o' are obligatory for the input/output files."
VERSION="0.2"

#
# Defining functions
#
nice_output ()
{
echo "-------------------------------------------------------------------------------------------------" > $outFile
printf "| %-15s | %-22s | %-100s |\n" "QUERY TIME" "DATE" "SLOW QUERY" >> $outFile
echo "-------------------------------------------------------------------------------------------------" > $outFile
}

#
# Function to check for slow queries.
#
check_slow ()
{
echo -e "\n-------------------------------------------------------------------------------------------------" > $outFile
awk '/[0-9]{3,}ms$/ {print $NF "\t" $0}' $inFile | sed -e 's/[0-9]\{3,\}ms$//' | sed -e 's/\[conn[0-9].*\] //' | sort -rn >> $outFile
echo -e "-------------------------------------------------------------------------------------------------\n" >> $outFile
}

#
# Function to check for slow queries per hour
#
check_slow_hour ()
{
outFile_hourly="$outFile"_hourly
cat /dev/null > $outFile_hourly
for hour in {0..23}
do
    echo -e "\n-------------------------------------------------------------------------------------------------" >> $outFile_hourly
    if [[ $number -gt 9 ]]
    then
        h_rate=$(egrep -c "^$day $month $number $hour:.*[0-9]{3,}ms$" $inFile)
    else
        h_rate=$(egrep -c "^$day $month  $number $hour:.*[0-9]{3,}ms$" $inFile)
    fi
    echo -e "For the hour beginning at $hour:00, on $day $month $number, there were $h_rate slow queries." >> $outFile_hourly
    echo -e "-------------------------------------------------------------------------------------------------\n" >> $outFile_hourly
done
}

#
# Function to check for corruption in bios or bad dumps.
#

check_corrupt ()
{
echo -e "\n\n-------------------------------------------------------------------------------------------------" >> $outFile
egrep -i "corrupted" $inFile >> $outFile
echo -e "-------------------------------------------------------------------------------------------------\n" >> $outFile
}

# Start-up Options

while getopts hvd:i:m:n:o: OPT
do
case "$OPT" in
    d)
        day=$OPTARG;
    ;;
    h)
        echo -e "$USAGE\n";
        echo "-d:  Day of the week (3 letters formatted as  Mon, Tue, Wed etc)";
        echo "-m:  Month of the year (3 letters formatted as  Jan, Dec etc)";
        echo "-n:  Number of the day in the month (2 numbers formatted as 28, 29 but ONLY 1 number for 1,2,3...9)";
        echo "-h:  Print this message!";
        echo -e "-v:  Version Information.\n";
        exit 0;
    ;;
    i)
        inFile=$OPTARG;
        [ OPTIND=${OPTIND} ];
    ;;
    m)
        month=$OPTARG;
    ;;
    n)
        number=$OPTARG;
    ;;
    o)
        outFile=$OPTARG;
        [ OPTIND=${OPTIND} ];
    ;;
    v)
        echo -e "\nVersion $VERSION of $(basename $0)\n";
        exit 0;
    ;;
    \?) echo $USAGE;
        exit 1;
        ;;
    *)  echo -e "\nOption -$OPTARG requires an argument.\n";
        exit 1;
    ;;
esac
done

nice_output

check_slow

check_corrupt

# Checking that the variables for Day, Month and Date are set before running the hourly calculation
# I'm sure this could be tidier but hey....

if [[ $number -gt 0 && $number -lt 32 ]]
then
    echo $month | egrep 'Jan|Feb|Mar|Apr|Ju(n|l)|Aug|Sep|Oct|Nov|Dec' 2>&1 > /dev/null
    if [ $? -eq 0 ]
    then
        echo $day | egrep 'S(at|un)|Mon|Tue|Wed|Thu|Fri' 2>&1 > /dev/null
        if [ $? -eq 0 ]
        then
            check_slow_hour
        fi
    fi
fi

