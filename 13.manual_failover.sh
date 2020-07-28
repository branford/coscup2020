#!/bin/sh
. ./config.sh

if [ $# -eq 1 ]; then
    if [ $1 -eq $master_ip ]; then
        _num='1'
        _zone=$zone1
    elif [ $1 -eq $backup_ip ]; then
        _num='2'
        _zone=$zone2
    else
        echo 'please give the correct ip'
    fi
else
    _num='1'
    _zone=$zone1
fi

gcloud --project=$project beta compute instances reset --zone "asia-east1-$_zone" "coscup-$username-failover-$_num"
sleep 1
gcloud --project=$project beta compute instances stop --zone "asia-east1-$_zone" "coscup-$username-failover-$_num"

