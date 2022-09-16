#!/bin/bash

echo ">>> INIT MASTER NODE"

sudo systemctl enable kubelet

kubeadm init \
  --apiserver-advertise-address=$MASTER_NODE_IP \
  --pod-network-cidr=$K8S_POD_NETWORK_CIDR \
  --ignore-preflight-errors=NumCPU \

echo ">>> CONFIGURE KUBECTL"

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

# ./vagrant/kubeadm/kubectl.sh

echo ">>> FIX KUBELET NODE IP"

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$MASTER_NODE_IP\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

if [ "$K8S_POD_NETWORK_TYPE" == "calico" ]
then 
  echo ">>> DEPLOY POD NETWORK > CALICO"
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
  # kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml

  envsubst < /vagrant/cni/calico/custom-resources.yaml | kubectl apply -f -
else
  echo ">>> DEPLOY POD NETWORK > FLANNEL"
   envsubst < /vagrant/cni/flannel/flannel.yml | kubectl apply -f -
fi

sudo systemctl daemon-reload
sudo systemctl restart kubelet

echo ">>> GET WORKER JOIN COMMAND "

rm -f /vagrant/kubeadm/init-worker.sh
kubeadm token create --print-join-command >> /vagrant/kubeadm/init-worker.sh
