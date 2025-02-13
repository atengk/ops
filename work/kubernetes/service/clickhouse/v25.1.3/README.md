# ClickHouse

ClickHouse 是一个开源的列式数据库管理系统，专为实时分析和大数据处理设计。它支持快速的查询性能，尤其在处理大规模数据集时表现优异。ClickHouse 支持高并发的读写操作，适用于在线分析处理（OLAP）场景，广泛应用于日志分析、监控和数据仓库等领域。其高度优化的存储引擎和分布式架构使其能够处理PB级别的数据。

- [官方地址](https://clickhouse.com/)

**查看版本**

```
helm search repo bitnami/clickhouse -l
```

**下载chart**

```
helm pull bitnami/clickhouse --version 8.0.0
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 认证配置：auth.username auth.password
- 镜像地址：image.registry
- Zookeeper配置：需要配置外部Zookeeper信息 externalZookeeper
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/clickhouse="true"
kubectl label nodes server03.lingo.local kubernetes.service/clickhouse="true"
```

**创建服务**

```
helm install clickhouse -n kongyu -f values.yaml clickhouse-8.0.0.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=clickhouse
kubectl logs -f -n kongyu clickhouse-shard0-0
```

**使用服务**

创建客户端容器

```
kubectl run clickhouse-client --rm --tty -i --restart='Never' --image  registry.lingo.local/bitnami/clickhouse:25.1.3 --namespace kongyu --command -- bash
```

访问服务

```
clickhouse-client --host clickhouse --port 9000 --user admin --password Admin@123 --query "SELECT * FROM system.clusters;"
```

**删除服务以及数据**

```
helm uninstall -n kongyu clickhouse
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=clickhouse
```

