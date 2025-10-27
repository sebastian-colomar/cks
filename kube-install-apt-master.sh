sudo apt-get update

sudo apt-get install docker.io -y

sudo systemctl enable --now docker

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

ip_leader=$(hostname -i)

kube=kube-apiserver

log=/tmp/install-leader.log

#tigera=https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/tigera-operator.yaml

#calico=https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/custom-resources.yaml

cni=https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

#pod_network_cidr=192.168.0.0/16
pod_network_cidr=10.5.0.0/16

echo ${ip_leader} ${kube} | tee --append /etc/hosts

sudo kubeadm init --upload-certs --control-plane-endpoint "${kube}" --pod-network-cidr ${pod_network_cidr} 2>&1 | tee --append ${log}

kubeconfig=/etc/kubernetes/admin.conf

#export KUBECONFIG=/etc/kubernetes/admin.conf

#sudo kubectl create --filename ${tigera} --kubeconfig ${kubeconfig} 2>& 1 | tee --append ${log}

#sudo kubectl create --filename ${calico} --kubeconfig ${kubeconfig} 2>& 1 | tee --append ${log}

sudo kubectl create --filename ${cni} --kubeconfig ${kubeconfig} 2>& 1 | tee --append ${log}

echo ip_leader=$ip_leader

#sudo sed --in-place /${kube}/d /etc/hosts

#sudo sed --in-place /127.0.0.1.*localhost/s/$/' '${kube}/ /etc/hosts
