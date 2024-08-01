

# 3.7.0 -> 3.7.1

在3.7.1的版本下执行升级命令

```
helm upgrade kafka -n kongyu -f values.yaml kafka-29.3.7.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kafka
kubectl logs -f -n kongyu kafka-controller-0
```

