# 安装MySQL副本集

查看版本

```
helm search repo bitnami/mysql -l
```

下载chart

```
helm pull bitnami/mysql --version 10.3.0
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install mysql -n kongyu -f values.yaml mysql-10.3.0.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mysql
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mysql
```

使用服务

> read/write: mysql-primary
>
> read-only: mysql-secondary

```
kubectl run mysql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mysql:8.0.39 --namespace kongyu --command -- bash
$ mysql -hmysql-primary -uroot -pAdmin@123
mysql> SHOW REPLICAS;
$ mysql -hmysql-secondary -uroot -pAdmin@123
mysql> SHOW REPLICA STATUS\G;
```

删除服务以及数据

```
helm uninstall -n kongyu mysql
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=mysql
```

