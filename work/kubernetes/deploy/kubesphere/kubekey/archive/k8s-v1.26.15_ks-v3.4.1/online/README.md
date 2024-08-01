# KubeKey在线安装KubeSphere



## 安装基础包

安装kubekey

```
export KKZONE=cn
export VERSION=v3.1.1
curl -sfL https://get-kk.kubesphere.io | sh -
mv kk /usr/bin
```



## 安装普通集群

安装依赖包

> 注意配置好yum源

```
kk init os -f kk-config-ks-online.yaml
```

创建集群

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



## 安装高可用集群（kube-vip）

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



## 安装高可用集群（haproxy）

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

