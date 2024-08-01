# 安装MySQL单机

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install mysql -n kongyu -f values.yaml mysql-9.12.3.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mysql
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mysql
```

使用服务

```
kubectl run mysql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mysql:8.0.34 --namespace kongyu --command -- mysqladmin status -h mysql.kongyu.svc.cluster.local  -uroot -pAdmin@123
```

删除服务以及数据

```
helm uninstall -n kongyu mysql
kubectl delete -n kongyu pvc data-mysql-0
```

