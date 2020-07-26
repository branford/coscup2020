#!/bin/sh
. /usr/local/sbin/config.sh

echo $PATH
for i in sbin bin
do
    if [ -z "`echo $PATH | grep /usr/local/$i`" ]; then
        PATH="$PATH:/usr/local/$i"
    fi
done

_basedir='/usr/local/sbin'

# memorystore(memcached)
_memserver='10.47.144.3'
_memport='11211'

_host=`hostname`
_prefix=`echo $_host | sed 's;-[0-9];;'`
_peer=`grep "$_prefix-[12]$" /etc/hosts | grep -v "$_host" | uniq | awk '{print $2}'`
_thisip=`ifconfig vtnet0 | grep 10.140 | awk '{print $2}'`
_iplen=${#_thisip}

log="local0.debug"
name="boot-check"

_ping=`ping -c 1 -t 1 $_peer | grep '100.0% packet loss'` # check alive for peer

_master=`printf "get master$master_ip\r\n" | nc -N $_memserver $_memport | tr '\r\n' ' ' | sed 's;..*\(10\.1[^ ][^ ]*\)..*;\1;'`

if [ -n "$_ping" ]; then # change to master
    printf "set master$master_ip 0 86400 $_iplen\r\n$_thisip\r\n" | nc -N $_memserver $_memport > /dev/null 2>&1
    echo 'failover master 1'
    $_basedir/hast_failover.sh MASTER $name
elif [ -z "$_ping" -a "$_master" = "$_thisip" ]; then # change to master
    printf "set master$master_ip 0 86400 $_iplen\r\n$_thisip\r\n" | nc -N $_memserver $_memport > /dev/null 2>&1
    echo 'failover master 2'
    $_basedir/hast_failover.sh MASTER $name
else # change to slave, backup
    echo 'failover backup'
    $_basedir/hast_failover.sh BACKUP $name
fi
