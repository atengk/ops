

# 11.1.3 -> 11.3.2

在11.3.2的版本下执行升级命令

```
helm upgrade mariadb-galera -n kongyu -f values.yaml mariadb-galera-13.2.5.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mariadb-galera
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mariadb-galera
```

