

# 3.5.0->3.5.1

在3.5.0的版本下执行升级命令

```
helm upgrade spark -n kongyu -f values.yaml spark-9.2.5.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=spark
kubectl logs -f -n kongyu spark-master-0
```

