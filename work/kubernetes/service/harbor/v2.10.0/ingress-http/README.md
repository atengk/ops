# 创建harbor

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install harbor -n harbor --create-namespace -f values.yaml harbor-19.2.3.tgz
```

查看服务

```shell
kubectl get -n harbor pod,svc,pvc -l app.kubernetes.io/instance=harbor
```

使用服务

```
URL: http://harbor.kongyu.local/
Username: admin
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n harbor harbor
kubectl delete -n harbor pvc data-harbor-trivy-0 data-postgresql-0 harbor-jobservice harbor-registry redis-data-redis-master-0
```

