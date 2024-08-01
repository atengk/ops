# 创建harbor

查看版本

```
helm search repo bitnami/harbor -l
```

下载chart

```
helm pull bitnami/harbor --version 22.0.3
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install harbor -n harbor --create-namespace -f values.yaml harbor-22.0.3.tgz
```

查看服务

```shell
kubectl get -n harbor pod,svc,pvc -l app.kubernetes.io/instance=harbor
```

使用服务

```
URL: http://harbor.kongyu.local
Username: admin
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n harbor harbor
kubectl delete -n harbor pvc -l app.kubernetes.io/instance=harbor
```

