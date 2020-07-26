#!/bin/sh
. ./config.sh

cat << EOF > /etc/hast.conf
resource disk1 {
        on coscup-${username}-failover-1 {
                local /dev/da1
                remote coscup-${username}-failover-2
        }
        on  coscup-${username}-failover-2 {
                local /dev/da1
                remote coscup-${username}-failover-1
        }
}

resource disk2 {
        on coscup-${username}-failover-1 {
                local /dev/da2
                remote coscup-${username}-failover-2
        }
        on  coscup-${username}-failover-2 {
                local /dev/da2
                remote coscup-${username}-failover-1
        }
}

resource disk3 {
        on coscup-${username}-failover-1 {
                local /dev/da3
                remote coscup-${username}-failover-2
        }
        on  coscup-${username}-failover-2 {
                local /dev/da3
                remote coscup-${username}-failover-1
        }
}
EOF

