yum install -y yum-utils
yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast

yum install -y policycoreutils-python
wget ./ https://mirrors.huaweicloud.com/centos-altarch/7/extras/aarch64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
rpm -ivh container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm

wget ./ https://mirrors.huaweicloud.com/centos-altarch/7/extras/aarch64/Packages/slirp4netns-0.4.3-4.el7_8.aarch64.rpm
rpm -ivh slirp4netns-0.4.3-4.el7_8.aarch64.rpm

yum install -y fuse3-libs
wget ./ https://mirrors.huaweicloud.com/centos-altarch/7/extras/aarch64/Packages/fuse-overlayfs-0.7.2-6.el7_8.aarch64.rpm
rpm -ivh fuse-overlayfs-0.7.2-6.el7_8.aarch64.rpm

yum install -y docker-ce docker-ce-cli containerd.io

systemctl start docker
systemctl enable docker
systemctl status docker