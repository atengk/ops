

# 16.1.0 -> 16.3.0

在16.3.0的版本下执行升级命令

```
helm upgrade postgresql -n kongyu -f values.yaml postgresql-15.5.14.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=postgresql
kubectl logs -f -n kongyu postgresql-0
```

