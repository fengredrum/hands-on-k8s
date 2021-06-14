# Steps to Install Kubernetes on Ubuntu 20.04

<img src=https://d33wubrfki0l68.cloudfront.net/69e55f968a6f44613384615c6a78b881bfe28bd6/42cd3/_common-resources/images/flower.svg width=100% />

> Source: https://kubernetes.io

## Login to remote servers

```shell
ssh -i "~/.ssh/k8s-key-pair.pem" ubuntu@"address"
```

With port forwarding

```shell
ssh -i "~/.ssh/k8s-key-pair.pem" -L 8001:127.0.0.1:8001 ubuntu@"address"
```

## Install Docker

<img src=https://www.docker.com/sites/default/files/social/docker_facebook_share.png width=40% />

> Source: https://www.docker.com

```shell
sudo apt-get update && \
    sudo apt-get install -y docker.io
```

Check the installation and version

```shell
docker ––version
```

> Docker version 20.10.2, build 20.10.2-0ubuntu1~20.04.2

Manage Docker as a non-root user

```shell
sudo groupadd docker
sudo gpasswd -a $USER docker
```

Either do a `newgrp` docker or log out/in to activate the changes to groups.

Verify that Docker is working properly

```shell
docker run hello-world
```

> Hello from Docker!
>
> This message shows that your installation appears to be working correctly.
>
> To generate this message, Docker took the following steps:
>
> 1. The Docker client contacted the Docker daemon.
> 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
>
>    (arm64v8)
>
> 3. The Docker daemon created a new container from that image which runs the
>    executable that produces the output you are currently reading.
> 4. The Docker daemon streamed that output to the Docker client, which sent it
>    to your terminal.
>
> To try something more ambitious, you can run an Ubuntu container with:
>
> `$ docker run -it ubuntu bash`
>
> Share images, automate workflows, and more with a free Docker ID:
>
> https://hub.docker.com/
>
> For more examples and ideas, visit:
>
> https://docs.docker.com/get-started/

## Creating a K8s cluster with kubeadm

<img src=https://raw.githubusercontent.com/kubernetes/kubeadm/master/logos/stacked/color/kubeadm-stacked-color.png width=40% />

> Source: https://kubernetes.io

### Installing kubeadm, kubelet and kubectl

```shell
sudo apt-get install -y apt-transport-https ca-certificates curl
```

```shell
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

```shell
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```shell
sudo apt-get update && \
    sudo apt-get install -y kubelet kubeadm kubectl
```

```shell
sudo apt-mark hold kubelet kubeadm kubectl
```

> K8s version 1.21

### Initializing control-plane node

```shell
sudo hostnamectl set-hostname master-node
```

```shell
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Optional

untaint master node
```shell
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### Deploying flannel

<img src=https://github.com/flannel-io/flannel/raw/master/logos/flannel-horizontal-color.png width=50% />

> Source: https://github.com/flannel-io/flannel#flannel

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### Initializing worker node

```shell
sudo hostnamectl set-hostname worker01
```

Join any number of worker nodes by running the following on each

```shell
sudo kubeadm join 172.31.21.251:6443 --token l8lmyg.1ruxxngkkloie8br --discovery-token-ca-cert-hash sha256:dd9f32afd796a8ea447d8723a18a4fdeeb7208bd302f6bb4af5b9976d5a015bf --v=5
```

> This node has joined the cluster:
>
> - Certificate signing request was sent to apiserver and a response was received.
> - The Kubelet was informed of the new secure connection details.
>
> Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

## Deploy Kubernetes Dashboard

<img src=https://github.com/kubernetes/dashboard/raw/master/docs/images/dashboard-ui.png width=100% />

> Source: https://github.com/kubernetes/dashboard#kubernetes-dashboard

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

Creating a Service Account

```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

Creating a ClusterRoleBinding

```shell
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

Getting a Bearer Token

```shell
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

Forward the pod port

```shell
ip -4 addr show eth0
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443 --address=0.0.0.0
```

Access the K8s dashboard through `https://your_server_ip:8080`

### Install Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

### Patch the dashboard to allow skipping login
kubectl patch deployment kubernetes-dashboard -n kubernetes-dashboard --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--enable-skip-login"}]'

### Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml

### Patch the metrisc server to work with insecure TLS
kubectl patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

### Run the Kubectl proxy to allow accessing the dashboard
kubectl proxy

## Check up that everthing is working properly

```shell
kubectl get nodes
```

> | NAME        | STATUS | ROLES                | AGE  | VERSION |
> | :---------- | :----- | :------------------- | :--- | :------ |
> | master-node | Ready  | control-plane,master | 19m  | v1.21.1 |
> | worker01    | Ready  | \<none\>             | 3m5s | v1.21.1 |
> | worker02    | Ready  | \<none\>             | 75s  | v1.21.1 |

```shell
kubectl get pods -n kube-system
```

> | NAME                                | READY | ROLES   | RESTARTS | AGE |
> | :---------------------------------- | :---- | :------ | :------- | :-- |
> | coredns-558bd4d5db-b4hz7            | 1/1   | Running | 0        | 35m |
> | coredns-558bd4d5db-t2kr6            | 1/1   | Running | 0        | 35m |
> | etcd-master-node                    | 1/1   | Running | 0        | 35m |
> | kube-apiserver-master-node          | 1/1   | Running | 0        | 35m |
> | kube-controller-manager-master-node | 1/1   | Running | 0        | 35m |
> | kube-flannel-ds-6sdc6               | 1/1   | Running | 0        | 23m |
> | kube-flannel-ds-td4hf               | 1/1   | Running | 0        | 18m |
> | kube-flannel-ds-zthxd               | 1/1   | Running | 0        | 20m |
> | kube-proxy-7s2zt                    | 1/1   | Running | 0        | 20m |
> | kube-proxy-kslt9                    | 1/1   | Running | 0        | 18m |
> | kube-proxy-pg4zk                    | 1/1   | Running | 0        | 35m |
> | kube-scheduler-master-node          | 1/1   | Running | 0        | 35m |

```shell
kubectl get pod --all-namespaces -o wide
```

> | NAMESPACE            | NAME                                       | READY | STATUS  | RESTARTS | AGE   | IP            | NODE        | NOMINATED NODE | READINESS GATES |
> | :------------------- | :----------------------------------------- | :---- | :------ | :------- | :---- | :------------ | :---------- | :------------- | :-------------- |
> | default              | nginx-deployment-66b6c48dd5-575mz          | 1/1   | Running | 0        | 2m20s | 10.244.1.53   | worker01    | \<none\>       | \<none\>        |
> | default              | nginx-deployment-66b6c48dd5-cb8rx          | 1/1   | Running | 0        | 11m   | 10.244.2.3    | worker02    | \<none\>       | \<none\>        |
> | kube-system          | coredns-558bd4d5db-b4hz7                   | 1/1   | Running | 0        | 35m   | 10.244.0.3    | master-node | \<none\>       | \<none\>        |
> | kube-system          | coredns-558bd4d5db-t2kr6                   | 1/1   | Running | 0        | 35m   | 10.244.0.2    | master-node | \<none\>       | \<none\>        |
> | kube-system          | etcd-master-node                           | 1/1   | Running | 0        | 35m   | 172.31.21.251 | master-node | \<none\>       | \<none\>        |
> | kube-system          | kube-apiserver-master-node                 | 1/1   | Running | 0        | 35m   | 172.31.21.251 | master-node | \<none\>       | \<none\>        |
> | kube-system          | kube-controller-manager-master-node        | 1/1   | Running | 0        | 35m   | 172.31.21.251 | master-node | \<none\>       | \<none\>        |
> | kube-system          | kube-flannel-ds-6sdc6                      | 1/1   | Running | 0        | 22m   | 172.31.21.251 | master-node | \<none\>       | \<none\>        |
> | kube-system          | kube-flannel-ds-td4hf                      | 1/1   | Running | 0        | 17m   | 172.31.31.130 | worker02    | \<none\>       | \<none\>        |
> | kube-system          | kube-flannel-ds-zthxd                      | 1/1   | Running | 0        | 19m   | 172.31.26.208 | worker01    | \<none\>       | \<none\>        |
> | kube-system          | kube-proxy-7s2zt                           | 1/1   | Running | 0        | 19m   | 172.31.26.208 | worker01    | \<none\>       | \<none\>        |
> | kube-system          | kube-proxy-kslt9                           | 1/1   | Running | 0        | 17m   | 172.31.31.130 | worker02    | \<none\>       | \<none\>        |
> | kube-system          | kube-proxy-pg4zk                           | 1/1   | Running | 0        | 35m   | 172.31.21.251 | master-node | \<none\>       | \<none\>        |
> | kube-system          | kube-scheduler-master-node                 | 1/1   | Running | 0        | 35m   | 172.31.21.251 | master-node | \<none\>       | \<none\>        |
> | kubernetes-dashboard | dashboard-metrics-scraper-856586f554-l8st2 | 1/1   | Running | 0        | 13m   | 10.244.2.2    | worker02    | \<none\>       | \<none\>        |
> | kubernetes-dashboard | kubernetes-dashboard-78c79f97b4-xmx8j      | 1/1   | Running | 0        | 13m   | 10.244.1.2    | worker01    | \<none\>       | \<none\>        |

## Deploy a Stateless Application

```shell
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
```

Remove

```shell
kubectl delete deployment nginx-deployment
```

## Clean up

Remove the admin ServiceAccount and ClusterRoleBinding.

```shell
kubectl -n kubernetes-dashboard delete serviceaccount admin-user
kubectl -n kubernetes-dashboard delete clusterrolebinding admin-user
```

Run the following command on each node

```shell
sudo kubeadm reset
```
