#!/bin/bash

# Tested on Ubuntu 20.04

#
# Upgrade existing packages
#
apt update
export DEBIAN_FRONTEND=noninteractive
apt upgrade -y

#
# gcc
#
apt install -y build-essential

#
# tools
#
apt install -y vim curl git tmux jq bat

#
# golang
#
add-apt-repository -y ppa:longsleep/golang-backports
apt update
apt install -y golang-go

#
# docker
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
#
apt install docker.io -y
usermod -a -G docker ubuntu

#
# kind
#
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.0/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

#
# kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux
#
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod 755 ./kubectl
mv ./kubectl /usr/local/bin/kubectl

#
# AWS CLI
#
apt install awscli -y

#
# Python pip
#
apt install python3-pip -y
