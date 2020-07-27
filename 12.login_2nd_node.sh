#!/bin/sh
. ./config.sh

gcloud --project=$project beta compute ssh --zone "asia-east1-$zone2" "coscup-$username-failover-2"
