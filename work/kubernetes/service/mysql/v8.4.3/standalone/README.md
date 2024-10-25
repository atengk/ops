# MySQL

MySQL 是一个流行的开源关系型数据库管理系统（RDBMS），广泛用于Web应用、企业系统和数据仓库等场景。它采用结构化查询语言（SQL）进行数据管理，支持多种存储引擎、事务处理和复杂查询操作。MySQL 以高性能、可靠性和易用性著称，同时具有强大的社区支持和广泛的第三方工具兼容性，适合各种规模的应用程序。

https://www.mysql.com/

**查看版本**

```
helm search repo bitnami/mysql -l
```

**下载chart**

```
helm pull bitnami/mysql --version 11.1.19
```

**修改配置**

根据环境做出相应的修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/mysql="true"
```

**创建服务**

```
helm install mysql -n kongyu -f values.yaml mysql-11.1.19.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mysql
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mysql
```

**使用服务**

创建客户端容器

```
kubectl run mysql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mysql:8.4.3 --namespace kongyu --command -- bash
```

内部网络访问-headless

```

```

内部网络访问

```
mysqladmin status -hmysql.kongyu -uroot -pAdmin@123
```

集群网络访问

> 使用集群+NodePort访问

```
mysqladmin status -h192.168.1.10 -P12192 -uroot -pAdmin@123
```

**删除服务以及数据**

```
helm uninstall -n kongyu mysql
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=mysql
```

