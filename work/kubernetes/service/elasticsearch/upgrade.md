

# 8.11.3 -> 8.14.3

在8.14.3的版本下执行升级命令

```
helm upgrade elasticsearch -n kongyu -f values.yaml elasticsearch-21.3.1.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=elasticsearch
kubectl logs -f -n kongyu elasticsearch-master-0
```

