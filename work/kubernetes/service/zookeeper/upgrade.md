

# 3.9.1 -> 3.9.2

在3.9.2的版本下执行升级命令

```
helm upgrade zookeeper -n kongyu -f values.yaml zookeeper-13.4.7.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zookeeper
kubectl logs -f -n kongyu zookeeper-0
```

