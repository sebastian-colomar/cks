sudo yum install docker -y

sudo systemctl enable --now docker

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

ip_leader=$(hostname -i)

kube=kube-apiserver

log=/tmp/install-leader.log

tigera=https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/tigera-operator.yaml

calico=https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/custom-resources.yaml

pod_network_cidr=192.168.0.0/16

echo ${ip_leader} ${kube} | tee --append /etc/hosts

sudo kubeadm init --upload-certs --control-plane-endpoint "${kube}" --pod-network-cidr ${pod_network_cidr} --ignore-preflight-errors all 2>&1 | tee --append ${log}

kubeconfig=/etc/kubernetes/admin.conf

#export KUBECONFIG=/etc/kubernetes/admin.conf

sudo kubectl create --filename ${tigera} --kubeconfig ${kubeconfig} 2>& 1 | tee --append ${log}

sudo kubectl create --filename ${calico} --kubeconfig ${kubeconfig} 2>& 1 | tee --append ${log}

echo ip_leader=$ip_leader

sudo sed --in-place /${kube}/d /etc/hosts

sudo sed --in-place /127.0.0.1.*localhost/s/$/' '${kube}/ /etc/hosts
