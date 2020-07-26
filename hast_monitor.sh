#!/bin/sh
# please change
_member='11'

if [ "$_member" = 'XX' ]; then
    echo 'Please change the value of _member first.'
    exit 1
fi

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

while [ True ]
do
    _master=`printf "get master$_member\r\n" | nc -N $_memserver $_memport | tr '\r\n' ' ' | sed 's;..*\(10\.1[^ ][^ ]*\)..*;\1;'`
    _curstate=`hastctl status | grep ' primary  */'`
    _ping=`ping -c 1 -t 1 $_peer | grep '100.0% packet loss'` # check alive for peer

    if [ -z "$_ping" ]; then
        if { [ -n "$_curstate" -a "$_master" = "$_thisip" ]; } || { [ -z "$_curstate" -a "$_master" != "$_thisip" ]; } then
            echo none 1 && sleep 1 && echo
            continue
        elif [ -z "$_curstate" -a "$_master" = "$_thisip" ]; then
            printf "set master$_member 0 86400 $_iplen\r\n$_thisip\r\n" | nc -N $_memserver $_memport > /dev/null 2>&1
            echo 'failover master 1'
            $_basedir/hast_failover.sh MASTER $name
        else
            pid=`echo $$`
            echo "error: maybe split brain, please kill $pid first"
        fi
    else
        if [ -z "$_curstate" ]; then
            printf "set master$_member 0 86400 $_iplen\r\n$_thisip\r\n" | nc -N $_memserver $_memport > /dev/null 2>&1
            echo 'failover master 2'
            $_basedir/hast_failover.sh MASTER $name
        elif [ -n "$_curstate" -a "$_master" != "$_thisip" ]; then
            printf "set master$_member 0 86400 $_iplen\r\n$_thisip\r\n" | nc -N $_memserver $_memport > /dev/null 2>&1
            echo 'upload'
        else
            echo none 2 && sleep 1 && echo
            continue
        fi
    fi

    sleep 1
    echo
done

