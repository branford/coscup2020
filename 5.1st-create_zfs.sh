#!/bin/sh
. ./config.sh

# config ZFS on 1st node
for i in 1 2 3
do
    gpart create -s gpt /dev/hast/disk${i}
    gpart add -t freebsd-zfs -l gpt${i} /dev/hast/disk${i}
    
done

zpool create -f -O canmount=off -m none storage raidz1 /dev/gpt/gpt1 /dev/gpt/gpt2 /dev/gpt/gpt3

zfs set atime=off storage
zfs set checksum=fletcher4 storage
mkdir /storage

zfs create -o mountpoint=/storage/config storage/config
zfs create -o mountpoint=/storage/data storage/data

cat << EOF > /storage/config/exports
/storage/data   -alldirs -maproot=root -network=10.0.0.0 -mask=255.0.0.0
EOF

cd /
tar cvf - var etc usr | tar xf - -C /storage/data

# check ZFS status
zpool status

