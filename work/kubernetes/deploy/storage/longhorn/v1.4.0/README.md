安装软件包

```
yum -y install nfs-utils iscsi-initiator-utils
```

设置存储标签

```
kubectl label node k8s-worker01 node.longhorn.io/create-default-disk=true
kubectl label node k8s-worker02 node.longhorn.io/create-default-disk=true
kubectl label node k8s-worker03 node.longhorn.io/create-default-disk=true
```

创建

```
helm install longhorn -n longhorn-system --create-namespace -f values-longhorn.yaml longhorn-1.4.0.tgz
```

查看

```
kubectl get -n longhorn-system pod,svc
```

删除

```
helm uninstall longhorn -n longhorn-system
```

