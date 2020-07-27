#!/bin/sh
. ./config.sh

gcloud beta --project=$project beta compute ssh --zone "asia-east1-$zone1" "coscup-$username-failover-1"
