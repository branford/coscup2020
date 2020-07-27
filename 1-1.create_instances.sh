#!/bin/sh
. ./config.sh

# instance A name: coscup-${username}-failover-1, zone: asia-east1-${zone1}
gcloud beta compute --project=${project} instances create coscup-${username}-failover-1 --zone=asia-east1-${zone1} --machine-type=n1-standard-1 --subnet=ip-failover --private-network-ip=10.140.0.${master_ip} --network-tier=PREMIUM --maintenance-policy=MIGRATE --image=coscup-freebsd-image-failover-202007262030-11-4 --image-project=${project} --boot-disk-size=22GB --boot-disk-type=pd-standard --reservation-affinity=any --can-ip-forward

# instance B name: coscup-${username}-failover-2, zone: asia-east1-${zone2}
gcloud beta compute --project=${project} instances create coscup-${username}-failover-2 --zone=asia-east1-${zone2} --machine-type=n1-standard-1 --subnet=ip-failover --private-network-ip=10.140.0.${backup_ip} --network-tier=PREMIUM --maintenance-policy=MIGRATE --image=coscup-freebsd-image-failover-202007262030-11-4 --image-project=${project} --boot-disk-size=22GB --boot-disk-type=pd-standard --reservation-affinity=any --can-ip-forward

sleep 1

# 1st node add disks
for i in 1 2 3
do
    gcloud compute disks create coscup-${username}-failover-1-disk-${i} --project=${project} --zone=asia-east1-${zone1} --type=pd-standard --size=200GB
        sleep 1
    gcloud compute instances attach-disk coscup-${username}-failover-1 --project=${project} --disk=coscup-${username}-failover-1-disk-${i} --zone=asia-east1-${zone1}
done

# 2nd node add disks
for i in 1 2 3
do
    gcloud compute disks create coscup-${username}-failover-2-disk-${i} --project=${project} --zone=asia-east1-${zone2} --type=pd-standard --size=200GB
        sleep 1
    gcloud compute instances attach-disk coscup-${username}-failover-2 --project=${project} --disk=coscup-${username}-failover-2-disk-${i} --zone=asia-east1-${zone2}
done

