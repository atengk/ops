# KubeKey

KubeKey是一个开源的轻量级工具，用于部署Kubernetes集群。它提供了一种灵活、快速、方便的方式来安装Kubernetes/K3s、Kubernetes/K3s和KubeSphere，以及相关的云原生附加组件。它也是扩展和升级集群的有效工具。

此外，KubeKey还支持定制离线包（artifact），方便用户在离线环境下快速部署集群。

https://github.com/kubesphere/kubekey

https://github.com/kubesphere/kubekey/blob/master/README_zh-CN.md



## 安装KubeKey

下载kubekey

```
wget https://github.com/kubesphere/kubekey/releases/download/v3.1.7/kubekey-v3.1.7-linux-amd64.tar.gz
```

安装kubekey

```
tar -zxvf kubekey-v3.1.7-linux-amd64.tar.gz -C /usr/bin
kk version
```



## 制作离线包

> 只适用于centos7和OpenEuler24.03系统，其他系统需要重新制作，参考[官网](https://github.com/kubesphere/kubekey/blob/master/docs/manifest-example.md)
> 镜像包就是将这依赖软件包做成离线yum包，保证其根目录能使用yum安装，最后打成ISO镜像就行了，以下给出关键命令
> dnf download --resolve --alldeps --downloaddir=openEuler-24.03-amd64/packages nfs-utils net-tools bash-completion openssl socat conntrack ipset ebtables chrony ipvsadm tar zip unzip wget curl vim
> createrepo openEuler-24.03-amd64/packages
> 将openEuler-24.03-amd64/目录下的数据做成ISO

查看支持的k8s版本

```
kk version --show-supported-k8s
```

生成制品清单示例

```
kk create manifest --with-kubernetes v1.23.17,v1.24.17,v1.25.16,v1.26.15,v1.27.16,v1.28.15,v1.29.10,v1.30.6,v1.31.2 --arch amd64 --with-registry -f kk-manifest-ks-sample.yaml
```

获取基础镜像并修改为阿里云仓库

```
grep -E docker.io kk-manifest-ks-sample.yaml | awk -F '/' '{print "registry.cn-beijing.aliyuncs.com/kubesphereio/"$NF}' | sed "s/^/  - /"
```

获取KubeSphere镜像并修改为阿里云仓库

```
wget -O ks-images-list.txt https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/images-list.txt
grep -E -v "^$|^#" ks-images-list.txt | awk -F '/' '{print "registry.cn-beijing.aliyuncs.com/kubesphereio/"$NF}' | sed "s/^/  - /"
```

根据生成的kk-manifest-ks-sample.yaml文件按需求自定义manifest配置文件，以上步骤的镜像修改在文件中

```
vi ks-manifest-ks.yaml
```

设置时区变量

```
export KKZONE=cn
```

构建最小制品

> 这三种选其一即可，其实也就是KubeSphere的镜像的变化

```
kk artifact export -m kk-manifest-ks.yaml -o kubekey-artifact-ks.tar.gz
```

构建最大制品

```
kk artifact export -m kk-manifest-ks-max.yaml -o kubekey-artifact-ks-max.tar.gz
```

构建所有制品

```
kk artifact export -m kk-manifest-ks-all.yaml -o kubekey-artifact-ks-all.tar.gz
```



## 离线安装集群

> 目前可以使用**centos7.9**、**openEuler-24.03**安装。

### 安装镜像仓库

安装kubekey

```
tar -zxvf kubekey-v3.1.7-linux-amd64.tar.gz -C /usr/bin/
```

初始化系统依赖

```
kk init os -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz
```

初始化镜像仓库

```
kk init registry -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz
```

查看镜像仓库

> 数据存放在/mnt/registry下，这个镜像仓库只做临时安装用，正常情况下是用harbor
>
> 也可以编辑配置文件修改`/etc/kubekey/registry/config.yaml`，然后重启服务

```
systemctl status registry
```

推送镜像到私有镜像仓库

```
kk artifact image push -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz
```



### 安装普通集群

创建集群安装k8s和ks

> 注意修改相应的主机信息

```
kk create cluster -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz --with-packages --with-local-storage
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

访问kubesphere

```
URL: http://192.168.1.101:30880/
Username: admin
Password: Admin@123
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s

```
kk delete cluster -f kk-config-ks.yaml --all
```

删除etcd数据

> 修改了默认的路径，kk无法删除

```
rm -rf /data/service/etcd
```



### 安装高可用集群（kube-vip）

创建集群安装k8s和ks

> 注意修改相应的主机信息

```
kk create cluster -f kk-config-ks-ha-1.yaml -a kubekey-artifact-ks.tar.gz --with-packages --with-local-storage
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

访问kubesphere

```
URL: http://192.168.1.101:30880/
Username: admin
Password: Admin@123
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s

```
kk delete cluster -f kk-config-ks-ha-1.yaml --all
```

删除etcd数据

> 修改了默认的路径，kk无法删除

```
rm -rf /data/service/etcd
```



### 安装高可用集群（haproxy）

创建集群安装k8s和ks

> 注意修改相应的主机信息

```
kk create cluster -f kk-config-ks-ha-2.yaml -a kubekey-artifact-ks.tar.gz --with-packages --with-local-storage
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

访问kubesphere

```
URL: http://192.168.1.101:30880/
Username: admin
Password: Admin@123
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s

```
kk delete cluster -f kk-config-ks-ha-2.yaml --all
```

删除etcd数据

> 修改了默认的路径，kk无法删除

```
rm -rf /data/service/etcd
```



## 在线安装集群

### 安装kubekey

```
export KKZONE=cn
export VERSION=v3.1.7
curl -sfL https://get-kk.kubesphere.io | sh -
mv kk /usr/bin
```



### 安装普通集群

安装依赖包

> 注意配置好yum源
>
> 如果有些操作系统不支持使用以下命令，那么就手动安装相关依赖`dnf install -y socat conntrack`
>
> 目前可以使用**centos7.9**、**openEuler-24.03**、**Rocky-9.4**、**AnolisOS-8.9**、**debian-12.5.0**、**ubuntu-24.04**安装。

```
kk init os -f kk-config-ks-online.yaml
```

创建集群

> 如果嫌下载太慢，可以将**kubekey-install-packages.tar.gz**解压到当前目录下，可以避免再次下载相关软件包。

```
export KKZONE=cn
kk create cluster -f kk-config-ks-online.yaml
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s，保留容器镜像

```
kk delete cluster -f kk-config-ks-online.yaml --all
```

删除etcd数据

> 修改了默认的路径，kk无法删除

```
rm -rf /data/service/etcd
```



### 安装高可用集群（kube-vip）

安装依赖包

> 注意配置好yum源

```
kk init os -f kk-config-ks-ha-online-1.yaml
```

创建集群

```
export KKZONE=cn
kk create cluster -f kk-config-ks-ha-online-1.yaml
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s，保留容器镜像

```
kk delete cluster -f kk-config-ks-ha-online-1.yaml --all
```

删除etcd数据

> 修改了默认的路径，kk无法删除

```
rm -rf /data/service/etcd
```



### 安装高可用集群（haproxy）

安装依赖包

> 注意配置好yum源

```
kk init os -f kk-config-ks-ha-online-2.yaml
```

创建集群

```
export KKZONE=cn
kk create cluster -f kk-config-ks-ha-online-2.yaml
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s，保留容器镜像

```
kk delete cluster -f kk-config-ks-ha-online-2.yaml --all
```

删除etcd数据

> 修改了默认的路径，kk无法删除

```
rm -rf /data/service/etcd
```

