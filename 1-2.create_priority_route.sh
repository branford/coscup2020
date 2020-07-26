#!/bin/sh
. ./config.sh

# confit static priority route 500 for 1st node
gcloud --project=${project} compute routes create coscup-${username}-failover-1-route --destination-range 10.200.0.${master_ip}/32 --network ip-failover --priority 500 --next-hop-instance-zone asia-east1-${zone1} --next-hop-instance coscup-${username}-failover-1

# confit static priority route 500 for 2nd node
gcloud --project=${project} compute routes create coscup-${username}-failover-2-route --destination-range 10.200.0.${master_ip}/32 --network ip-failover --priority 600 --next-hop-instance-zone asia-east1-${zone2} --next-hop-instance coscup-${username}-failover-2
