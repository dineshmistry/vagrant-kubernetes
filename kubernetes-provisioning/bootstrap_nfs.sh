#!/bin/bash
apt install -qq -y nfs-common nfs-kernel-server sshpass >/dev/null 2>&1

mkdir -p /srv/nfs/dman-home-kubedata
chown nobody:nogroup  /srv/nfs/dman-home-kubedata

cat >>/etc/exports<<EOF
/srv/nfs/dman-home-kubedata    *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)
EOF

/etc/init.d/nfs-kernel-server reload

mkdir /root/.kube
sshpass -p "admin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@kmaster.local:/etc/kubernetes/admin.conf /root/.kube/config

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
kubectl apply -f https://raw.githubusercontent.com/dineshmistry/vagrant-kubernetes/main/metallb/configmap.yaml

kubectl create namespace nfs-provisioner
kubectl apply -f https://raw.githubusercontent.com/dineshmistry/vagrant-kubernetes/main/nfs-server/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/dineshmistry/vagrant-kubernetes/main/nfs-server/class.yaml
kubectl apply -f https://raw.githubusercontent.com/dineshmistry/vagrant-kubernetes/main/nfs-server/deployment.yaml

curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https -qq --yes >/dev/null 2>&1
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -qq -y > /dev/null 2>&1
sudo apt-get install helm -qq -y > /dev/null 2>&1


kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx -n ingress-nginx --values https://raw.githubusercontent.com/dineshmistry/vagrant-kubernetes/main/nginx-ingress/values.yaml