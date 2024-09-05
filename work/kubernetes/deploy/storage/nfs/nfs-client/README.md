# 外部NFS存储类

Kubernetes NFS Subdir External Provisioner

**NFS subdir 外部配置程序**是一个自动配置程序，它使用*现有且已配置的*NFS 服务器来支持通过持久卷声明动态配置 Kubernetes 持久卷。持久卷配置为`${namespace}-${pvcName}-${pvName}`.

https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner



## 前提条件

1. 已有NFS服务器

| NFS Server IP |
| ------------- |
| 192.168.1.115 |

如没有，参考[文档](https://kongyu666.github.io/work/#/work/service/nfs/)。

2. 创建存储的目录

```
sudo mkdir -p /data/service/nfs/myk8s
```



## 安装

**下载chart**

```
wget https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/releases/download/nfs-subdir-external-provisioner-4.0.18/nfs-subdir-external-provisioner-4.0.18.tgz
```

**修改values.yaml**

```
helm show values nfs-subdir-external-provisioner-4.0.18.tgz > values.yaml
vi values.yaml
```

**安装服务**

```
helm install nfs-client \
  -n kube-system -f values.yaml \
  --set nfs.server=192.168.1.115 \
  --set nfs.path=/data/service/nfs/myk8s \
  nfs-subdir-external-provisioner-4.0.18.tgz
```

**查看服务**

```
kubectl get -n kube-system deploy/nfs-client-nfs-subdir-external-provisioner
kubectl get sc nfs-client
```

**设置服务（可选）**

设置为默认的存储类

```
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 使用

**安装依赖包**

集群所有节点都需要安装，尤其是使用该存储类被调度到的节点

```
yum -y install nfs-utils
```

**创建PVC和Pod**

```
kubectl apply -f pod-volume.yaml
```

**查看**

从默认的存储类kube-system-hostpath申请了PVC供使用

```
[root@k8s-master01 nfs-client]# kubectl get pod,pvc
NAME                                READY   STATUS    RESTARTS   AGE
pod/busybox-test-6f46bf9db7-467dm   1/1     Running   0          4m52s
pod/busybox-test-6f46bf9db7-bvl4z   1/1     Running   0          4m52s
pod/busybox-test-6f46bf9db7-j9cm6   1/1     Running   0          4m52s

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/busybox-test   Bound    pvc-8f11420a-e41b-4f3b-867a-d3fd625cf809   2Gi        RWX            nfs-client     <unset>                 4m52s
```

**查看日志**

```
kubectl logs -f deploy/busybox-test
```

**查看NFS服务器**

查看NFS服务器所创建的目录，登录到NFS Server服务器查看

```
ll /data/service/nfs/myk8s/
```



## 删除

**创建PVC和Pod**

```
kubectl delete -f pod-volume.yaml
```

**删除服务**

```
helm uninstall nfs-client -n kube-system
```



