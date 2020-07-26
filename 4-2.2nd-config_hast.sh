#!/bin/sh
. ./config.sh

/etc/rc.d/hastd start

# config HAST secondary on 2nd node
for i in 1 2 3
do
    hastctl role init disk${i}
    hastctl create disk${i}
    hastctl role secondary disk${i}
done
