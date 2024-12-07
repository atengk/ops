# Redis

Redis 是一个开源的内存数据库，支持多种数据结构，如字符串、哈希、列表、集合和有序集合等。它常用于缓存、会话管理和实时数据分析等场景，具有高性能和低延迟的特点。Redis 支持数据持久化，可以将内存中的数据保存到磁盘，重启后恢复数据。

Redis Cluster 是 Redis 的分布式实现，用于实现数据的自动分片和高可用性。它将数据分布在多个节点上，每个节点存储一部分数据，并通过哈希槽（hash slots）进行管理，共有 16384 个槽位。Redis Cluster 支持无中心架构，具有自动故障转移功能，当部分节点失效时，其他节点可以接管数据，实现无缝的服务。它适用于需要高扩展性和高性能的场景。

- [官方文档](https://redis.io/)

## 开发环境

使用LoadBalancer将集群暴露到集群外部访问

**查看版本**

```
helm search repo bitnami/redis-cluster -l
```

**下载chart**

```
helm pull bitnami/redis-cluster --version 11.0.6
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values-dev.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
kubectl label nodes server03.lingo.local kubernetes.service/redis="true"
```

**创建服务**

```
helm install redis -n kongyu -f values-dev.yaml redis-cluster-11.0.6.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-0
```

**使用服务**

创建客户端容器

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis-cluster:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- bash
```

内部网络访问-headless

```
redis-cli -c -h redis-0.redis-headless.kongyu cluster nodes
```

内部网络访问

```
redis-cli -c -h redis cluster nodes
```

集群网络访问

> 使用集群+NodePort访问

```
redis-cli -c -h 192.168.1.10 -p 28597 cluster nodes
```

**删除服务以及数据**

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```



## 生产环境

只能在k8s集群内部访问

**查看版本**

```
helm search repo bitnami/redis-cluster -l
```

**下载chart**

```
helm pull bitnami/redis-cluster --version 11.0.6
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values-prod.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
kubectl label nodes server03.lingo.local kubernetes.service/redis="true"
```

**创建服务**

```
helm install redis -n kongyu -f values-prod.yaml redis-cluster-11.0.6.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-0
```

**使用服务**

创建客户端容器

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis-cluster:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- bash
```

内部网络访问-headless

```
redis-cli -c -h redis-0.redis-headless.kongyu cluster nodes
```

内部网络访问

```
redis-cli -c -h redis cluster nodes
```

**删除服务以及数据**

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

