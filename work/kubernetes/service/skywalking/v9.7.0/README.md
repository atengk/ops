# 安装SkyWalking

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

> 需要在外部的elasticsearch集群创建skywalking数据库

```
helm install skywalking -n kongyu -f values.yaml skywalking-helm-4.5.0.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app=skywalking
kubectl logs -f -n kongyu -l app=skywalking,component=oap
```

使用服务

```
URL: http://192.168.1.19:45111
```

删除服务以及数据

```
helm uninstall -n kongyu skywalking
```

