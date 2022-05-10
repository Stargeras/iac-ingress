#!/bin/bash

installk3s="true"
installterraform="true"
installhelm="true"
osname=$(cat /etc/os-release | grep '^ID=' | awk -F = '{print $NF}')

if ${installk3s}; then
  # DETERMINE K3S ANNOTATIONS FROM OS 
  if [[ ${osname} == "debian" ]]; then
    k3sannotations="--snapshotter=native --disable=traefik"
  elif [[ ${osname} == "arch" ]]; then
    k3sannotations="--snapshotter=fuse-overlayfs --disable=traefik"
  else
    k3sannotations="--disable=traefik"
  fi
  # INSTALL K3S
  curl -sfL https://get.k3s.io > k3s.sh
  bash k3s.sh ${k3sannotations}
  rm -f k3s.sh

  # KUBECONFIG
  mkdir ${HOME}/.kube
  cp /etc/rancher/k3s/k3s.yaml ${HOME}/.kube/config
  chown ${USERNAME}:${USERNAME} ${HOME}/.kube/config

  # BASH COMPLETION
  if [[ ! $(cat ${HOME}/.bashrc | grep "kubectl completion bash") ]]; then
    echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc
  fi
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