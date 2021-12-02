#!/bin/bash
apt install -qq -y nfs-common nfs-kernel-server >/dev/null 2>&1

mkdir -p /srv/nfs/dman-home-kubedata
chown nobody:nogroup  /srv/nfs/dman-home-kubedata

cat >>/etc/exports<<EOF
/srv/nfs/dman-home-kubedata    *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)
EOF

/etc/init.d/nfs-kernel-server reload