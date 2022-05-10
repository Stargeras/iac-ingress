#!/bin/bash

installterraform="true"
installhelm="true"
usedriveforcontainers="true"
containerdriveuuid="a1536d8b-1828-4cca-8b21-a1d722647cc4"
osname=$(cat /etc/os-release | grep '^ID=' | awk -F = '{print $NF}')


# ENSURE SUPPORTED OS
if [[ ! ${osname} == "debian" ]] || [[ ! ${osname} == "arch" ]]; then
  echo "Install only supported on Debian or Arch Linux"
  exit 1
fi

# PREP CONTAINER DRIVE
if ${usedriveforcontainers}; then
  containerdir="/var/lib/docker"
  mkdir -p ${containerdir}
  mount -U ${containerdriveuuid} ${containerdir}
  rm -rf ${containerdir}/*
fi

# BRIDGE
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# INSTALL PACKAGES
if [[ ${osname} == "debian" ]]; then
  apt update
  apt upgrade -y
  apt install gnupg curl unzip -y

  # INSTALL PACKAGES
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
  apt update
  apt install -y docker.io kubelet kubeadm kubectl
fi

if [[ ${osname} == "arch" ]]; then
  pacman -Sy
  pacman -S docker
  systemctl enable --now docker
  pacman -S kubectl kubeadm kubelet --noconfirm
fi

# INITIALIZE KUBEADM
kubeadm init --pod-network-cidr=10.244.0.0/16

# KUBECONFIG FILE
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# REMOVE MASTER TAINT
kubectl taint nodes --all node-role.kubernetes.io/master-

# INSTALL FLANNEL
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# LOCAL-PATH PROVISIONER
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.21/deploy/local-path-storage.yaml

# BASH COMPLETION
if [[ ! $(cat ${HOME}/.bashrc | grep "kubectl completion bash") ]]; then
  echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc
fi

# INSTALL TERRAFORM
if ${installterraform}; then
  if [[ ${osname} == "debian" ]]; then
    terraformversion=$(curl https://releases.hashicorp.com/terraform/ | grep href | sort -r | grep terraform_ | head -1 | awk -F _ '{print $NF}' | awk -F '<' '{print $1}')
    url="https://releases.hashicorp.com/terraform/${terraformversion}/terraform_${terraformversion}_linux_amd64.zip"
    file=$(echo ${url} | awk -F / '{print $NF}')
    wget ${url}
    echo ${file} | grep .zip >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
      unzip ${file}
      newfile=$(echo ${file} | awk -F _ '{print $1}')
      chmod +x ${newfile}
      mv ${newfile} /usr/local/bin/
      rm -f ${file}
     else
      chmod +x ${file}
      mv ${file} /usr/local/bin/
    fi
  elif [[ ${osname} == "arch" ]]; then
    pacman -Sy
    pacman -S terraform --noconfirm
  fi
fi

# INSTALL HELM
if ${installhelm}; then
  if [[ ${osname} == "debian" ]]; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  elif [[ ${osname} == "arch" ]]; then
    pacman -Sy
    pacman -S helm --noconfirm
  fi
fi
