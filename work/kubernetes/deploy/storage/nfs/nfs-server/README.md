创建

```
kubectl label nodes k8s-worker02 app=nfs-server-provisioner
helm install nfs-server-provisioner -n kube-system -f values-nfs-server.yaml ./nfs-server-provisioner-1.4.0.tgz
```

查看

```
kubectl get -n kube-system pod -l app=nfs-server-provisioner
ll /data/kubernetes/storage/nfs-server/
```

删除

```
helm uninstall -n kube-system nfs-server-provisioner
```









