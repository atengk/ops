# kubeadm安装kubernetes



文档使用以下3台服务器

| IP地址        | 主机名       | 描述                 |
| ------------- | ------------ | -------------------- |
| 192.168.1.101 | k8s-master01 | kubernetes的主节点   |
| 192.168.1.102 | k8s-worker01 | kubernetes的工作节点 |
| 192.168.1.103 | k8s-worker02 | kubernetes的工作节点 |



## 基础配置

1. 配置网卡

> 根据实际环境配置每个节点

```
# vi /etc/sysconfig/network-scripts/ifcfg-ens32
DEVICE="ens32"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR="192.168.1.101"
PREFIX="24"
GATEWAY="192.168.1.1"
DNS1="114.114.114.114"
# systemctl restart network
```

2. 修改主机名和hosts

> 每个节点修改相应的主机名和配置hosts

```
hostnamectl set-hostname k8s-master01
cat >> /etc/hosts <<EOF
192.168.1.101 apiserver.k8s.local
192.168.1.101 k8s-master01
192.168.1.102 k8s-worker01
192.168.1.103 k8s-worker02
EOF
```

3. 关闭防火墙以及selinux

```
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
```

4. 设置时区时间

```
timedatectl set-timezone Asia/Shanghai
clock -w
timedatectl set-local-rtc 1
sed -i "/^server/d" /etc/chrony.conf
sed -i "3i server ntp.aliyun.com iburst" /etc/chrony.conf
systemctl restart chronyd
chronyc sources
```

5. 关闭swap分区

```
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
```

6. 配置内核参数

```
modprobe br_netfilter
cat >> /etc/sysctl.d/99-kube.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-arptables = 1
vm.max_map_count = 2000000
fs.file-max = 4658757
vm.swappiness = 0
EOF
sysctl -f /etc/sysctl.d/99-kube.conf
```

7. 安装基础软件包和配置ipvs

```
yum install -y ipvsadm ipset sysstat conntrack libseccomp socat wget net-tools nfs-utils
cat > /etc/modules-load.d/ipvs.conf <<EOF
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
nf_conntrack
br_netfilter
EOF
systemctl restart systemd-modules-load
systemctl enable systemd-modules-load
lsmod | grep ip_vs
```

8. 设置limits限制

```
cat << EOF > /etc/security/limits.conf
root soft nofile 655360
root hard nofile 655360
root soft nproc 655360
root hard nproc 655360
root soft core unlimited
root hard core unlimited
EOF
```

9. 配置journald服务

> journald 是 systemd 管理的系统日志服务，用于收集、存储和管理系统的日志信息。它负责记录系统的各种事件、错误和消息，以便系统管理员进行故障排除和监控。

```
mkdir -p /var/log/journal /etc/systemd/journald.conf.d
cat << EOF > /etc/systemd/journald.conf.d/99-prophet.conf
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
# 同步间隔时间为5分钟，Journal将缓冲日志并在一次性写入磁盘
SyncIntervalSec=5m
# 限制日志的写入速率为每30秒不超过1000条
RateLimitInterval=30s
RateLimitBurst=10000
# 最大占用空间为10G，一旦达到此限制，较早的日志将被删除
SystemMaxUse=10G
# 单个日志文件的最大大小为200M，达到此大小时会切换到新的日志文件
SystemMaxFileSize=500M
# 日志保留时间为100天，超过此时间的日志将被删除
MaxRetentionSec=100d
# 不将日志转发到syslog
ForwardToSyslog=no
EOF
systemctl restart systemd-journald
```



## 安装docker

1. 安装依赖

```
yum -y install iptables procps xz
```

2. 解压并安装软件包

```
cd binary/
tar -zxvf docker-v20.10.24-binary.tar.gz -C /usr/bin/
```

3. 编辑配置文件

```
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<"EOF"
{
  "bip": "10.128.0.1/16",
  "data-root": "/data/service/docker",
  "features": { "buildkit": true },
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries": ["0.0.0.0/0"],
  "registry-mirrors": [
    "https://xf9m4ezh.mirror.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
```

4. 使用systemd管理服务

```
cat > /etc/systemd/system/docker.service <<"EOF"
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start docker
systemctl enable docker
systemctl status docker
```

5. 查看服务

```
docker info
```

## 安装配置kubeadm

1. 安装软件包

```
cd binary/
tar -zxvf k8s-v1.23.12-binary.tar.gz -C /usr/bin/
tar -zxvf helm-v3.9.4-binary.tar.gz -C /usr/bin/
## 命令补全
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

2. 修改配置文件

```
cd config/
cat kubeadm-config.yaml
## 修改advertiseAddress即可，如果需要修改其他配置参数请编辑该文件
export IPADDR=$(ip -4 route get 8.8.8.8 | head -n 1 | awk '{print $7}')
sed -i "s#advertiseAddress: .*#advertiseAddress: ${IPADDR}#" kubeadm-config.yaml
```

3. 拉取镜像

> 如果没有镜像仓库，所有节点都需要读取离线镜像images/images-k8s-v1.23.12.tar.gz

```
kubeadm config images list --config=kubeadm-config.yaml
kubeadm config images pull --config=kubeadm-config.yaml
```

## 配置kubelet

1. 创建kubelet所需文件

```
mkdir -p /etc/kubernetes/manifests /etc/systemd/system/kubelet.service.d
echo "KUBELET_EXTRA_ARGS=" > /etc/sysconfig/kubelet
```

2. 使用systemd管理

```
cat > /etc/systemd/system/kubelet.service <<"EOF"
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target
[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF
```

3. 创建kubeadm的配置

```
cat > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf <<"EOF"
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
EOF
```

4. 设置开机自启

```
systemctl daemon-reload
systemctl enable kubelet
```

## 初始化kubernets

1. 初始化

> 如果使用外部的etcd，则使用kubeadm-config-ext-etcd.yaml配置文件，并根据实际环境修改对应的参数

```
cd config/
kubeadm init --config=kubeadm-config.yaml --upload-certs
```

2. 创建kube证书

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

3. 查看集群pod

```
kubectl get pod -A -o wide
```

4. 删除污点

删除主节点的污点，可以运行调度（可选项）

```
kubectl taint nodes k8s-master01 node-role.kubernetes.io/master-
```

## 加入worker节点

1. 获取join token

> 在主节点获取加入k8s集群的命令

```
kubeadm token create --print-join-command
```

2. 加入worker节点

> 在worker节点执行获取到的命令，加入k8s集群

```
kubeadm join apiserver.k8s.local:6443 --token e8htrc.2uytftnwu91ju005 --discovery-token-ca-cert-hash sha256:1e06997fa6f1bd87347f992a08e
```

3. 给工作节点添加标签

```
kubectl label node k8s-worker01 node-role.kubernetes.io/worker=
kubectl label node k8s-worker02 node-role.kubernetes.io/worker=
```

4. 查看集群pod

```
kubectl get pod -A -o wide
kubectl get node
```

## 安装calico网络

1. 安装operator

```
cd calico/
kubectl apply -f calico-tigera-operator.yaml
```

2. 安装网络

```
kubectl apply -f calico-custom-resources-ipip.yaml
```

3. 查看集群pod

```
kubectl get pod -A -o wide
```

## 安装local存储类

1. 安装openebs local存储类

> 数据存放在/data/service/kubernetes/storage/openebs/local目录下

```
cd storage/local/
kubectl apply -n kube-system -f localpv-provisioner.yaml
```

2. 查看存储类

```
kubectl get sc
```

## 高可用集群（可选）

使用kube-vip扩展主节点，注意新节点请先完成**基础配置**、**安装docker**、**安装配置kubeadm**和**配置kubelet**

1. 获取join token

在已存在的主节点上获取加入k8s集群的命令

```
cd config/
kubeadm token create --print-join-command
```

获取证书秘钥

```
kubeadm init phase upload-certs --config=kubeadm-config.yaml --upload-certs
```

拼接得到加入控制节点的命令

```
echo "$(kubeadm token create --print-join-command) --control-plane --certificate-key  $(kubeadm init phase upload-certs --config=kubeadm-config.yaml --upload-certs 2> /dev/null | tail -1)"
## 得到类似于下方的命令
kubeadm join apiserver.k8s.local:6443 \
  --token 8km0ov.t8mpg23jniubtgpy \
  --discovery-token-ca-cert-hash sha256:0ccdf5424baf432aa1141f32b9158641d56576c0960ed6b500e5aa691b6b334e \
  --control-plane --certificate-key 024f5db42f3bb0a3b8ae0cbe6e089c5c8b992f970477d7bcd7e9d87c31535690
```

2. 加入主节点

在预置的主节点执行获取到的命令，加入k8s集群

```
kubeadm join apiserver.k8s.local:6443 \
  --token 8km0ov.t8mpg23jniubtgpy \
  --discovery-token-ca-cert-hash sha256:0ccdf5424baf432aa1141f32b9158641d56576c0960ed6b500e5aa691b6b334e \
  --control-plane --certificate-key 024f5db42f3bb0a3b8ae0cbe6e089c5c8b992f970477d7bcd7e9d87c31535690
```

创建kube证书

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

3. 查看集群pod

```
kubectl get pod -A -o wide
kubectl get node
```

4. 删除污点

删除主节点的污点，可以运行调度（可选项）

```
kubectl taint nodes k8s-master02 node-role.kubernetes.io/master-
kubectl label node k8s-master02 node-role.kubernetes.io/worker=
```

5. 修改配置文件

```
cd kube-vip/
vi kube-vip.yaml
## 需要根据实际环境修改以下两个参数
## vip_interface：网卡名，address：虚拟IP地址
```

6. 安装kube-vip

> 如果节点的网卡名不一致的，需要在对应的节点修改kube-vip.yaml的网卡配置

```
cp kube-vip.yaml /etc/kubernetes/manifests/
scp kube-vip.yaml k8s-master02:/etc/kubernetes/manifests/
scp kube-vip.yaml k8s-master03:/etc/kubernetes/manifests/
```

7. 查看kube-vip

```
kubectl get -n kube-system -l k8s-app=kube-vip pod
kubectl logs -f --tail=200 -n kube-system -l k8s-app=kube-vip 
ip a show ens32
```

8. 修改hosts文件

> 将master节点的apiserver.k8s.local的IP改为127.0.0.1，worker节点的apiserver.k8s.local的IP改为虚拟IP。

```
## master 
sed -i "s#.*apiserver.k8s.local#127.0.0.1 apiserver.k8s.local#" /etc/hosts
## worker
sed -i "s#.*apiserver.k8s.local#192.168.1.250 apiserver.k8s.local#" /etc/hosts
```

9. 使用vip

后续所有的访问都可以使用该虚拟ip访问

## 漏洞处理

1. kube-apiserver

```
# vi +48 /etc/kubernetes/manifests/kube-apiserver.yaml
    - --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```

2. kube-controller-manager

```
# vi +30 /etc/kubernetes/manifests/kube-controller-manager.yaml
    - --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```

3. kube-scheduler

```
# vi +18 /etc/kubernetes/manifests/kube-scheduler.yaml
    - --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```

4. kubelet

> 需要在所有节点都配置，加入--tls-cipher-suites参数

```
# vi /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS="--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
# systemctl restart kubelet
```

5. 查看的pod状态

```
kubectl get pod -n kube-system
```

## 安装kubesphere

安装kubesphere

> 如果没有镜像仓库，所有节点都需要读取离线镜像images/images-ks-v3.4.1.tar.gz
>
> 可以按需修改cluster-configuration.yaml配置文件，但不要新增组件，离线镜像中不包含其他组件的镜像

```
cd kubesphere/
kubectl apply -f kubesphere-installer.yaml
kubectl apply -f cluster-configuration.yaml
```

检查安装日志

```
kubectl logs -f -n kubesphere-system deploy/ks-installer
```

访问kubesphere

```
URL: http://192.168.1.101:30880/
Username: admin
Password: Admin@123
```



# 删除kubernetes

## 删除节点

这里以删除**k8s-worker01**为例，操作步骤如下

1. 驱逐worker节点并标记为不可调度

```
kubectl drain k8s-worker01 --delete-emptydir-data --force --ignore-daemonsets
kubectl cordon k8s-worker01
```

2. 删除worker节点

```
kubectl delete node k8s-worker01
```

3. 重置worker节点

> 进入**k8s-worker01**节点，重置kubernetes

```
kubeadm reset -f
```

4. 删除相关配置文件

```
ipvsadm --clear
rm -rf $HOME/.kube/ /etc/cni/net.d/* /var/lib/cni/* /var/lib/calico/
```

5. 删除网络

> 如果还有其他k8s网络，可以使用这种方式删除：ip link | egrep "tunl0|dummy0|kube-ipvs0|cali" | awk -F: '{print $2}' | xargs -L 1 -I {} ip link delete {}

```
ip link delete kube-ipvs0
modprobe -r ipip
```

6. 重启kubelet

```
systemctl restart kubelet
```

## 删除集群

- 删除kubesphere

> 使用脚本的方式很容器hang住，最好使用官网的方式按顺序卸载。[官方文档](https://www.kubesphere.io/zh/docs/v3.4/pluggable-components/uninstall-pluggable-components/)

```
cd scripts/
./kubesphere-delete.sh
```

- 删除local存储类

```
cd storage/local/
kubectl delete -n kube-system -f localpv-provisioner.yaml
```

- 删除calico网络

```
cd calico/
kubectl delete -f calico-custom-resources-ipip.yaml
kubectl delete -f calico-tigera-operator.yaml
```

- 删除kubernetes

参考**删除节点**部分
