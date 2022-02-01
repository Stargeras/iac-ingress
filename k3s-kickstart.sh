#!/bin/bash

installk3s="true"
installterraform="true"
installhelm="true"

if ${installk3s}; then
  # DETERMINE K3S ANNOTATIONS FROM OS 
  if [[ $(cat /etc/os-release | grep ^ID=) == "ID=debian" ]]; then
    k3sannotations="--snapshotter=native --disable=traefik"
  else
    k3sannotations="--snapshotter=fuse-overlayfs --disable=traefik"
  fi

  # INSTALL K3S
  curl -sfL https://get.k3s.io > k3s.sh
  bash k3s.sh ${k3sannotations}

  # KUBECONFIG
  mkdir ${HOME}/.kube
  cp /etc/rancher/k3s/k3s.yaml ${HOME}/.kube/config
  chown ${USERNAME}:${USERNAME} ${HOME}/.kube/config

  # BASH COMPLETION
  if [[ ! $(cat ${HOME}/.bashrc | grep "kubectl completion bash") ]]; then
    echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc
  fi
fi

if ${installterraform}; then
  url="https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_linux_amd64.zip"
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
fi

if ${installhelm}; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi