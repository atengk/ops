

# 3.5.13 -> 3.5.14

在3.5.14的版本下执行升级命令

```
helm upgrade etcd -n kongyu -f values-etcd.yaml etcd-10.2.6.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,cj,svc,pvc -l app.kubernetes.io/name=etcd
kubectl logs -f -n kongyu etcd-2
```

