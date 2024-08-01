

# 6.2.14 -> 7.2.5

在7.2.5的版本下执行升级命令

```
helm upgrade redis -n kongyu -f values.yaml redis-19.6.0.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=redis
```

