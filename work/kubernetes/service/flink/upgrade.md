

# 1.18.1-> 1.19.1

在1.19.1的版本下执行升级命令

```
helm upgrade flink -n kongyu -f values.yaml flink-1.3.8.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=flink
kubectl logs -f -n kongyu deploy/flink-jobmanager
```

