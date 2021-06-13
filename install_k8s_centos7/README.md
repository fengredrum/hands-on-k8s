# Steps to Install Kubernetes on CentOS 7

```shell
hostnamectl
```

## Add a user

```shell
adduser testuser
passwd testuser
```

```shell
chmod -v u+w /etc/sudoers
```

```shell
vim /etc/sudoers
testuser    ALL=(ALL)    NOPASSWD:ALL
```

## Configure SSH Key-Based Authentication

```shell
mkdir .ssh
chmod 700 .ssh
```

```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.10.1.2 -p 22
```

## Disable swap

```shel
swapoff /dev/mapper/centos-swap
```

```shell
vi /etc/fstab
```

## Install Docker

```shell
sudo yum install -y yum-utils
```

```shell
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum makecache fast
```

```shell
sudo yum install docker-ce docker-ce-cli containerd.io
```

### requirments

```shell
sudo yum install policycoreutils-python
wget ./ https://mirrors.huaweicloud.com/centos-altarch/7/extras/aarch64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
sudo rpm -ivh container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
```

```shell
wget ./ https://mirrors.huaweicloud.com/centos-altarch/7/extras/aarch64/Packages/slirp4netns-0.4.3-4.el7_8.aarch64.rpm
sudo rpm -ivh slirp4netns-0.4.3-4.el7_8.aarch64.rpm
```

```shell
sudo yum install fuse3-libs
 wget ./ https://mirrors.huaweicloud.com/centos-altarch/7/extras/aarch64/Packages/fuse-overlayfs-0.7.2-6.el7_8.aarch64.rpm
sudo rpm -ivh fuse-overlayfs-0.7.2-6.el7_8.aarch64.rpm
```

### post run

```shell
systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
```

```shell
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo vim /etc/docker/daemon.json
{
"registry-mirrors": [
"https://dockerhub.azk8s.cn",
"https://reg-mirror.qiniu.com"
]
}
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Install K8s

```shell
systemctl stop firewalld && systemctl disable firewalld && setenforce 0
```
```shell
vim /etc/hosts

10.10.10.3 k8s-master
10.10.10.3 etcd
10.10.10.3 registry
10.10.10.4 k8s-node-1
10.10.10.5 k8s-node-2
```

adjust time server
```shell
yum install -y ntpdate
ntpdate ntp1.aliyun.com
```

```shell
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/ipv4/ip_forward
lsmod | grep br_netfilter
```

```shell
modprobe ip_vs && \
modprobe ip_vs_rr && \
modprobe ip_vs_wrr && \
modprobe ip_vs_sh && \
modprobe nf_conntrack_ipv4
```

```shell
yum install -y ipvsadm
```

```shell
vim /etc/docker/daemon.json
"exec-opts": ["native.cgroupdriver=systemd"]
systemctl daemon-reload
systemctl restart docker
```

```shell
vim /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-aarch64
enabled=1
gpgcheck=0
```

```shell
yum clean all
yum makecache fast
yum list kubelet --showduplicates | sort -r
yum install -y kubelet-1.21.1-0 kubeadm-1.21.1-0  kubectl-1.21.1-0 --disableexcludes=kubernetes
systemctl enable kubelet
```

```shell
kubeadm init \
  --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers \
--pod-network-cidr=10.244.0.0/16
```

```shell
docker pull coredns/coredns
docker tag coredns/coredns:latest registry.cn-hangzhou.aliyuncs.com/google_containers/coredns/coredns:v1.8.0
docker rmi coredns/coredns:latest
```

```shell
kubeadm token create --print-join-command
```

下面这几条命令在master节点上执行
查看令牌
# kubeadm token list
发现之前初始化时的令牌已过期
生成新的令牌
# kubeadm token create
ns2eo4.3tbeaiji7y1jx4hj
生成新的加密串
# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null |    openssl dgst -sha256 -hex | sed 's/^.* //'
d129df5787b082de4f6c5101881b6977e615d65a76cf59d0849a51c339731e12
node节点加入集群(在node节点上分别执行如下操作)
# kubeadm join 192.168.174.156:6443 --token ns2eo4.3tbeaiji7y1jx4hj --discovery-token-ca-cert-hash sha256:d129df5787b082de4f6c5101881b6977e615d65a76cf59d0849a51c339731e12

