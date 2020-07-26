#!/bin/sh
files=`ls hast_*sh config.sh`
install -o 0 -g 0 $files /usr/local/sbin
