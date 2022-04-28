#! /bin/bash

sudo kubeadm config images pull

echo "Preflight Check Passed: Downloaded All Required Images"

sudo kubeadm init --apiserver-advertise-address=10.0.1.100  --apiserver-cert-extra-sans=10.0.1.100 --pod-network-cidr=10.0.0.0/16 --node-name $(hostname -s) --ignore-preflight-errors Swap

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
sudo chmod 755 /home/ubuntu/.kube/config