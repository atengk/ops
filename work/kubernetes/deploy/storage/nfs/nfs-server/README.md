# NFS Ganesha 存储类

NFS Ganesha server and external provisioner

NFS Ganesha 服务器和 Volume Provisioner。

https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner



## 安装

**下载chart**

```
wget https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/releases/download/nfs-server-provisioner-1.8.0/nfs-server-provisioner-1.8.0.tgz
```

**修改values.yaml**

```
helm show values nfs-server-provisioner-1.8.0.tgz > values.yaml
vi values.yaml
```

**添加标签**

给节点添加标签以运行nfs-server-provisioner服务

```
kubectl label nodes k8s-worker01 kubernetes.service/nfs="true"
```

**安装服务**

```
helm install nfs-server \
  -n kube-system -f values.yaml \
  --set persistence.storageClass=openebs-hostpath \
  nfs-server-provisioner-1.8.0.tgz
```

**查看服务**

nfs server provisioner服务会从openebs-hostpath存储类中申请PVC供它存储数据

```
kubectl get -n kube-system pod,pvc -o wide -l app=nfs-server-provisioner
kubectl get sc nfs-server
```

**设置服务（可选）**

设置为默认的存储类

```
kubectl patch storageclass nfs-server -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
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
[root@k8s-master01 nfs-server]# kubectl get pod,pvc
NAME                                READY   STATUS    RESTARTS   AGE
pod/busybox-test-6f46bf9db7-h4wp5   1/1     Running   0          4s
pod/busybox-test-6f46bf9db7-k8fh6   1/1     Running   0          4s
pod/busybox-test-6f46bf9db7-pct6l   1/1     Running   0          4s

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/busybox-test   Bound    pvc-b635cedf-e356-41f7-8ad2-658c266091e1   2Gi        RWX            nfs-server     <unset>                 4s
```

**查看日志**

```
kubectl logs -f deploy/busybox-test
```



## 删除

**创建PVC和Pod**

```
kubectl delete -f pod-volume.yaml
```

**删除服务**

```
helm uninstall nfs-server -n kube-system
kubectl delete -n kube-system pvc -l app=nfs-server-provisioner
```



