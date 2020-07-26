#!/bin/sh
# PATH: /usr/local/bin/failover.sh
# root:wheel, 755

# Original script by Freddie Cash <fjwcash@gmail.com>
# Modified by Michael W. Lucas <mwlucas@BlackHelicopters.org>
# and Viktor Petersson <vpetersson@wireload.net>
# Modified by George Kontostanos <gkontos.mail@gmail.com>

# The names of the HAST resources, as listed in /etc/hast.conf
resources="disk1 disk2 disk3"

# delay in mounting HAST resource after becoming master
# make your best guess
delay=0.5

# logging
log="local0.debug"

if [ $# -eq 2 ]; then
    name=$2
else
    name="failover"
fi

pool="storage"
BASEDIR="/storage"

# end of user configurable stuff

case "$1" in
    MASTER)
        logger -p $log -t $name "Switching to primary provider for ${resources}."
        sleep ${delay}

        # Wait for any "hastd secondary" processes to stop
        for disk in ${resources}; do
            while $( pgrep -lf "hastd: ${disk} \(secondary\)" > /dev/null 2>&1 ); do
                sleep 1
            done

            # Switch role for each disk
            hastctl role primary ${disk}
            if [ $? -ne 0 ]; then
                logger -p $log -t $name "Unable to change role to primary for resource ${disk}."
                exit 1
            fi
        done

        # Wait for the /dev/hast/* devices to appear
        for disk in ${resources}; do
            for I in $( jot 60 ); do
                [ -c "/dev/hast/${disk}" ] && break
                sleep 0.5
            done

            if [ ! -c "/dev/hast/${disk}" ]; then
                logger -p $log -t $name "GEOM provider /dev/hast/${disk} did not appear."
                exit 1
            fi
        done

        logger -p $log -t $name "Role for HAST resources ${resources} switched to primary."

        logger -p $log -t $name "Importing Pool"
        # Import ZFS pool. Do it forcibly as it remembers hostid of
        # the other cluster node.
        out=`zpool import -f "${pool}" 2>&1`
        if [ $? -ne 0 ]; then
            logger -p local0.error -t hast "ZFS pool($pool) import failed: ${out}."
            exit 1
        fi
        logger -p local0.debug -t hast "ZFS pool($pool) imported."

        if [ -e $BASEDIR/config/exports ]; then
            logger -p $log -t $name "Start NFS Server"
            echo 'Start NFS Server'
            /etc/rc.d/mountd forcerestart
            /etc/rc.d/nfsd forcerestart
        else
            logger -p $log -t $name "dont start NFS"
            echo 'dont start NFS'
        fi

    ;;

    *)
        logger -p $log -t $name "Switching to secondary provider for ${resources}."

        # umount
        /etc/rc.d/nfsd forcestop
        /etc/rc.d/mountd forcestop

        # Switch roles for the HAST resources
        zpool list | egrep -q "^${pool} "
        if [ $? -eq 0 ]; then
            # Forcibly export file pool.
            out=`zpool export -f "${pool}" 2>&1`
            if [ $? -ne 0 ]; then
                logger -p local0.error -t hast "Unable to export ZFS pool: ${pool}: ${out}."
                exit 1
            fi
            logger -p local0.debug -t hast "ZFS pool: ${pool} exported."
        fi

        for disk in ${resources}; do
            sleep ${delay}
            hastctl role secondary ${disk} 2>&1
            if [ $? -ne 0 ]; then
                logger -p $log -t $name "Unable to switch role to secondary for resource ${disk}."
                exit 1
            fi
            logger -p $log -t $name "Role switched to secondary for resource ${disk}."
        done
    ;;
esac
