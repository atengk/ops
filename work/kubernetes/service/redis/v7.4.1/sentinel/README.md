# Redis

Redis 是一个开源的内存数据库，支持多种数据结构，如字符串、哈希、列表、集合和有序集合等。它常用于缓存、会话管理和实时数据分析等场景，具有高性能和低延迟的特点。Redis 支持数据持久化，可以将内存中的数据保存到磁盘，重启后恢复数据。

Sentinel 是 Redis 的高可用解决方案，用于监控 Redis 主从集群的运行状态。它可以自动检测主节点故障，并在主节点不可用时，自动进行主从切换（故障转移），确保 Redis 服务的高可用性。Sentinel 还负责向客户端提供主节点的地址信息，便于客户端连接到正确的 Redis 实例。

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
kubectl logs -f -n kongyu redis-node-0 sentinel
```

**使用服务**

> sentinel只支持k8s集群内部访问，或者通过ExternalDNS

创建客户端容器

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- bash
```

内部网络访问-headless

```
redis-cli -h redis-node-0.redis-headless.kongyu -p 26379 info server sentinel masters
```

内部网络访问

```
redis-cli -h redis -p 26379 info server sentinel masters
```

集群网络访问

> 使用集群+NodePort访问

```

```

**删除服务以及数据**

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

