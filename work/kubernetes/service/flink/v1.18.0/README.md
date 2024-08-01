# 安装flink

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install flink -n kongyu -f values.yaml flink-0.5.3.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=flink
kubectl logs -f -n kongyu deploy/flink-jobmanager
```

使用服务

```

```

删除服务以及数据

```
helm uninstall -n kongyu flink
```

