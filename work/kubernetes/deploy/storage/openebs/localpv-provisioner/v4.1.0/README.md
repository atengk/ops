# OpenEBS 动态本地存储类

Dynamic Kubernetes Local Persistent Volumes

**OpenEBS 动态本地 PV 配置程序**可用于使用 Kubernetes 节点上可用的不同类型的存储来动态配置 Kubernetes 本地卷。

https://github.com/openebs/dynamic-localpv-provisioner



## 安装

**下载chart**

```
wget https://github.com/openebs/dynamic-localpv-provisioner/releases/download/localpv-provisioner-4.1.0/localpv-provisioner-4.1.0.tgz
```

**修改values.yaml**

```
helm show values localpv-provisioner-4.1.0.tgz > values.yaml
vi values.yaml
```

**安装服务**

```
helm install openebs-hostpath -n openebs --create-namespace -f values.yaml localpv-provisioner-4.1.0.tgz
```

**查看服务**

```
kubectl get -n openebs pod,sc
```

**设置服务（可选）**

设置为默认的存储类

```
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 使用

**创建PVC和Pod**

```
kubectl apply -f pod-volume.yaml
```

**查看**

```
[root@k8s-master01 hostpath]# kubectl get pod,pvc -o wide
NAME               READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
pod/busybox-test   1/1     Running   0          41s   10.100.61.20   k8s-worker01   <none>           <none>

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
persistentvolumeclaim/busybox-test   Bound    pvc-2729afb4-32d9-4515-a6e8-d54f8ba2c12a   2Gi        RWO            openebs-hostpath   <unset>                 41s   Filesystem
```

**查看日志**

```
kubectl logs -f busybox-test
```

**查看存储的位置**

找到Pod调度的节点k8s-worker01

```
[root@k8s-worker01 ~]# ll /data/service/openebs-hostpath/pvc-2729afb4-32d9-4515-a6e8-d54f8ba2c12a/
总计 4
-rw-r--r-- 1 root root 2268  9月 4日 11:59 date.txt
```



## 删除

**创建PVC和Pod**

```
kubectl delete -f pod-volume.yaml
```

**删除服务**

```
helm uninstall openebs-hostpath -n openebs
kubectl delete ns openebs
```

