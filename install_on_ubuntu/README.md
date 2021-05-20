# Steps to Install Kubernetes on Ubuntu

## login

```shell
$ ssh -i "~/.ssh/k8s-key-pair.pem" ubuntu@"address"
```

Forward port

```shell
$ ssh -i "~/.ssh/k8s-key-pair.pem" -L 8001:127.0.0.1:8001 ubuntu@"address"
```

## Install Docker

```shell
$ sudo apt-get update && \
    sudo apt-get install -y docker.io
```

Check the installation and version

```shell
docker ––version
```

Manage Docker as a non-root user

```shell
$ sudo groupadd docker
$ sudo gpasswd -a $USER docker
```

Either do a `newgrp` docker or log out/in to activate the changes to groups

Verify

```shell
docker run hello-world
```

Install k8s with kubeadm

```shell
$ sudo apt-get install -y apt-transport-https ca-certificates curl
$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update
$ sudo apt-get install -y kubelet kubeadm kubectl
$ sudo apt-mark hold kubelet kubeadm kubectl
```

```shell
$ sudo hostnamectl set-hostname master-node
sudo hostnamectl set-hostname worker01
$ sudo kubeadm init
$ sudo sysctl net.bridge.bridge-nf-call-iptables=1
$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

```shell
$ kubectl get nodes
$ kubectl get pods -n kube-system
$ kubectl get pods --all-namespaces
```

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.21.251:6443 -v=5 --token ocec2s.lxq5gkxv5sdl5yo3 --discovery-token-ca-cert-hash sha256:5739013bd7873b6c78d451abee679a4ecdb985062f37144d699f43ce8e9daaf9

## Clean up
```shell
$ sudo kubeadm reset
```