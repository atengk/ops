

# 2024.7.4 -> 2024.7.15

在2024.7.15的版本下执行升级命令

```
helm upgrade minio -n kongyu -f values.yaml minio-14.6.22.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=minio
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=minio
```

