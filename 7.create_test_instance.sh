#!/bin/sh
. ./config.sh

gcloud beta compute --project=${project} instances create coscup-${username}-test --zone=asia-east1-${zone1} --machine-type=n1-standard-1 --subnet=ip-failover --network-tier=PREMIUM --maintenance-policy=MIGRATE --image=coscup-freebsd-image-failover-202007262030-11-4 --image-project=${project} --boot-disk-size=22GB --boot-disk-type=pd-standard --reservation-affinity=any

