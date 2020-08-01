#!/bin/sh
. ./config.sh

gcloud --project=$project beta compute ssh --zone "asia-east1-$zone1" "coscup-${username}-test"
