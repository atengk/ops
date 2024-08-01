

# 8.0.39 -> 8.4.1

在8.4.1的版本下执行升级命令

```
helm upgrade mysql -n kongyu -f values.yaml mysql-11.1.7.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mysql
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mysql
```

