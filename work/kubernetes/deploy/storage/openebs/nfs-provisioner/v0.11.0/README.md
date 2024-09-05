# OpenEBS 动态NFS存储类

Dynamic NFS Volume Provisioner

**项目状态：测试版**

需要提前准备好一个存储类，例如**localpv-provisioner**

**OpenEBS 动态 NFS PV 配置程序**可用于使用 Kubernetes 节点上可用的不同类型的块存储来动态配置 NFS 卷。

https://github.com/openebs-archive/dynamic-nfs-provisioner



## 安装

**下载chart**

```
wget https://github.com/openebs-archive/dynamic-nfs-provisioner/releases/download/nfs-provisioner-0.11.0/nfs-provisioner-0.11.0.tgz
```

**修改values.yaml**

```
helm show values nfs-provisioner-0.11.0.tgz > values.yaml
vi values.yaml
```

**安装服务**

```
helm install openebs-kernel-nfs -n openebs --create-namespace -f values.yaml nfs-provisioner-0.11.0.tgz
```

**查看服务**

```
kubectl get -n openebs pod,sc
```

**设置服务（可选）**

设置为默认的存储类

```
kubectl patch storageclass openebs-kernel-nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
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

从默认的存储类openebs-hostpath申请了PVC供使用

```
[root@k8s-master01 nfs]# kubectl get pod,pvc -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP              NODE           NOMINATED NODE   READINESS GATES
pod/busybox-test-6f46bf9db7-7m965   1/1     Running   0          12s   10.100.181.19   k8s-worker02   <none>           <none>
pod/busybox-test-6f46bf9db7-xxlfm   1/1     Running   0          12s   10.100.61.30    k8s-worker01   <none>           <none>
pod/busybox-test-6f46bf9db7-zkhcv   1/1     Running   0          12s   10.100.130.13   k8s-master01   <none>           <none>

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
persistentvolumeclaim/busybox-test   Bound    pvc-c308fdd1-1f7d-47cb-90b6-00d721c75722   2Gi        RWX            openebs-kernel-nfs   <unset>                 12s   Filesystem
[root@k8s-master01 nfs]# kubectl get pod,pvc -o wide -n openebs
NAME                                                                READY   STATUS    RESTARTS   AGE     IP              NODE           NOMINATED NODE   READINESS GATES
pod/nfs-pvc-c308fdd1-1f7d-47cb-90b6-00d721c75722-559d88cfc8-6z5hn   1/1     Running   0          25s     10.100.130.12   k8s-master01   <none>           <none>
pod/openebs-hostpath-867d9f6685-r54cm                               1/1     Running   0          6h18m   10.100.181.12   k8s-worker02   <none>           <none>
pod/openebs-kernel-nfs-7748bc8c84-kj85r                             1/1     Running   0          8m44s   10.100.61.23    k8s-worker01   <none>           <none>

NAME                                                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
persistentvolumeclaim/nfs-pvc-c308fdd1-1f7d-47cb-90b6-00d721c75722   Bound    pvc-7458c427-f5e8-4791-95c5-d083ad35fa53   2Gi        RWO            openebs-hostpath          <unset>                 25s   Filesystem
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
helm uninstall openebs-kernel-nfs -n openebs
kubectl delete ns openebs
```

