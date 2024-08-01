

# 3.12.10 -> 3.13.4

在3.13.4的版本下执行升级命令

```
helm upgrade rabbitmq -n kongyu -f values.yaml rabbitmq-14.5.0.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=rabbitmq
kubectl logs -f -n kongyu rabbitmq-0
```

