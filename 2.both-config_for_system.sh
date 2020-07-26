#!/bin/sh
. ./config.sh

# change timezon
cp /usr/share/zoneinfo/Asia/Taipei  /etc/localtime

# add ip alias for priority route
ifconfig vtnet0 inet alias 10.200.0.${master_ip}/32

# 避免 google 移除 vip: 10.200.0.XX
sed -i -e 's;^google_network;#google_network;' /etc/rc.conf
rm -f /etc/rc.conf.bak

# enable HASTd and ZFS
cat << EOF >> /etc/rc.conf
hastd_enable="YES"
zfs_enable="YES"

nfs_server_enable="NO"
mountd_enable="NO"
mountd_flags="-r -S /etc/exports /storage/config/exports"
EOF

# config ZFS on loader.conf
touch /boot/loader.conf
cat << EOF >> /boot/loader.conf
zfs_load="YES"
# if RAM >= 4G then enable(1), else < 4G , diskable(0)
vfs.zfs.prefetch_disable="0"
EOF

cat << EOF > /etc/rc.local
#!/bin/sh
ifconfig vtnet0 inet alias 10.200.0.${master_ip}/32

deleteline=\`grep -n '# delete' /etc/hosts | awk -F: '{print \$1}'\`
deleteline=\$(( \$deleteline + 1 ))
sed -i.bak "\$deleteline,\\\$d" /etc/hosts
rm -f /etc/hosts.bak

echo
echo 'check HAST'
/usr/local/sbin/hast_boot.sh

sleep 3
echo 'start HAST monitoring'
/usr/local/sbin/hast_monitor.sh > /tmp/hast.log 2>/dev/null &
EOF

cat << EOF > /etc/hosts
::1         localhost localhost.my.domain
127.0.0.1       localhost localhost.my.domain
169.254.169.254 metadata.google.internal metadata

10.140.0.11 coscup-$username-failover-1.c.pixnet-system-admin.internal coscup-$username-failover-1  # Added by Google
10.140.0.12 coscup-$username-failover-2.c.pixnet-system-admin.internal coscup-$username-failover-2  # Added by Google
169.254.169.254 metadata.google.internal  # Added by Google

10.140.0.11 coscup-$username-failover-1
10.140.0.12 coscup-$username-failover-2

# delete below
EOF

# workarun for HAST
cat << EOF >> /etc/sysctl.conf
vfs.zfs.vdev.aggregation_limit=131071
EOF

/etc/rc.d/sysctl start
kldload zfs

sysctl -w vfs.zfs.vdev.aggregation_limit=131071

echo 'check vfs.zfs.vdev.aggregation_limit'
sysctl vfs.zfs.vdev.aggregation_limit

