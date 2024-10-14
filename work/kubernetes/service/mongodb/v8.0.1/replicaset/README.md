# MongoDB

MongoDB 是一种基于文档的 NoSQL 数据库，以高性能、易扩展和灵活的文档存储而著称。它由 C++ 语言编写，于 2009 年首次发布。与传统的关系型数据库（如 MySQL、PostgreSQL）不同，MongoDB 采用非结构化的数据存储方式，不使用表和行，而是通过集合（Collection）和文档（Document）来组织数据。

**查看版本**

```
helm search repo bitnami/mongodb -l
```

**下载chart**

```
helm pull bitnami/mongodb --version 16.0.3
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/mongodb="true"
kubectl label nodes server03.lingo.local kubernetes.service/mongodb="true"
```

**创建服务**

```
helm install mongodb -n kongyu -f values.yaml mongodb-16.0.3.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mongodb
kubectl logs -f -n kongyu mongodb-0
```

**使用服务**

创建客户端容器

```
kubectl run mongodb-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mongodb:8.0.1 --namespace kongyu --command -- bash
```

内部网络访问

```
mongosh admin --host "mongodb-0.mongodb-headless.kongyu:27017,mongodb-1.mongodb-headless.kongyu:27017,mongodb-2.mongodb-headless.kongyu:27017" --authenticationDatabase admin -u root -p Admin@123 --eval "rs.status()"
```

集群网络访问

> rs.status() 输出的name即作为外部网络访问的地址

```
mongosh admin --host "192.168.1.11:30701,192.168.1.12:30701,192.168.1.13:30701" --authenticationDatabase admin -u root -p Admin@123 --eval "rs.status()"
```

**删除服务以及数据**

```
helm uninstall -n kongyu mongodb
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=mongodb
```

