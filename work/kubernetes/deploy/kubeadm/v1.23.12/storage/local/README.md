安装openebs local存储类

> 数据存放在/data/service/kubernetes/storage/openebs/local目录下

```
kubectl apply -n kube-system -f localpv-provisioner.yaml
```

查看存储类

```
kubectl get sc
```

