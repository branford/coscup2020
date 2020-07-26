#!/bin/sh
username='XXX'
zone1='a' # you can choice {a,b,c}, and different from zone2
zone2='b' # you can choice {a,b,c}, and different from zone1
master_ip='XX'
backup_ip='XX'

# default variable
project='pixnet-coscup-2020'

if [ "${username}" = 'XXX' -o "${master_ip}" = 'XX' -o "${backup_ip}" = 'XX' -o "${zone1}" = "${zone2}" ]; then
    echo 'please setup config.sh first.'
    exit
fi
