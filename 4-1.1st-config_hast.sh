#!/bin/sh
. ./config.sh

/etc/rc.d/hastd start

# config HAST primary on 1st node
for i in 1 2 3
do
    hastctl role init disk${i}
    hastctl create disk${i}
    hastctl role primary disk${i}
done
