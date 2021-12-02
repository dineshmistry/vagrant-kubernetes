#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
apt install -qq -y nfs-common sshpass >/dev/null 2>&1
sshpass -p "admin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.local:/joincluster.sh /joincluster.sh 2>/dev/null
bash /joincluster.sh >/dev/null 2>&1

