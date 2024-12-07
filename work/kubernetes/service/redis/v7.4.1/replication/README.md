# Redis

Redis 是一个开源的内存数据库，支持多种数据结构，如字符串、哈希、列表、集合和有序集合等。它常用于缓存、会话管理和实时数据分析等场景，具有高性能和低延迟的特点。Redis 支持数据持久化，可以将内存中的数据保存到磁盘，重启后恢复数据。

Redis 主从复制（Replication）是一种数据同步机制，其中一个主节点（Master）将数据复制到一个或多个从节点（Slave）。主节点负责处理写操作，并将数据更新同步给从节点，从节点只处理读操作。这种方式可以用于数据备份、负载均衡和提高读取性能。即使主节点发生故障，从节点也能提供部分数据访问功能。

- [官方文档](https://redis.io/)

**查看版本**

```
helm search repo bitnami/redis -l
```

**下载chart**

```
helm pull bitnami/redis --version 20.2.1
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
kubectl label nodes server03.lingo.local kubernetes.service/redis="true"
```

**创建服务**

```
helm install redis -n kongyu -f values.yaml redis-20.2.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=redis
```

**使用服务**

创建客户端容器

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- bash
```

内部网络访问-headless

```
## 读写节点
redis-cli -h redis-master-0.redis-headless.kongyu info server
## 只读节点
redis-cli -h redis-replicas-0.redis-headless.kongyu info server
```

内部网络访问

```
## 读写节点
redis-cli -h redis-master.kongyu info server
## 只读节点
redis-cli -h redis-replicas.kongyu info server
```

集群网络访问

> 使用集群+NodePort访问

```
## 读写节点
redis-cli -h 192.168.1.10 -p 17285 info server
## 只读节点
redis-cli -h 192.168.1.10 -p 20585 info server
```

**删除服务以及数据**

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

