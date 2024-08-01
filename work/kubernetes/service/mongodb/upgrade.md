

# 7.0.4 -> 7.0.12

在7.0.12的版本下执行升级命令

```
helm upgrade mongodb -n kongyu -f values.yaml mongodb-15.6.12.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mongodb
kubectl logs -f -n kongyu mongodb-0
```

