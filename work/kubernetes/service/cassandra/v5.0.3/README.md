# Cassandra

Cassandra 是一个开源的分布式 NoSQL 数据库，设计用于处理大规模的数据存储需求，特别适合高可用性和扩展性的场景。它支持分布式架构，具有水平扩展能力，能够在多个节点间自动复制数据，提供高容错性和零单点故障的特性。Cassandra 适合用于大数据应用、实时分析等需求，广泛应用于社交媒体、电商等领域。

- [官网链接](https://cassandra.apache.org/)

**查看版本**

```
helm search repo bitnami/cassandra -l
```

**下载chart**

```
helm pull bitnami/cassandra --version 12.1.3
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 认证配置：dbUser.user dbUser.password
- 资源配置：resources.requests resources.limits
- 副本数量：replicaCount
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/cassandra="true"
```

**创建服务**

```
helm install cassandra -n kongyu -f values.yaml cassandra-12.1.3.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=cassandra
kubectl logs -f -n kongyu cassandra-0
```

**使用服务**

进入容器

```
kubectl exec -it -n kongyu cassandra-0 -- bash
```

查看集群数据中心的节点

```
$ nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load        Tokens  Owns (effective)  Host ID                               Rack
UN  10.244.188.224  137.41 KiB  256     100.0%            b9e199ca-dd20-4ee0-96bc-47fbdefc81d8  rack1
```

访问服务

```
cqlsh -u cassandra -p Admin@123 cassandra.kongyu
```

使用SQL

```
cassandra@cqlsh> SELECT broadcast_address, data_center, rack, release_version FROM system.local;

 broadcast_address | data_center | rack  | release_version
-------------------+-------------+-------+-----------------
     10.244.188.29 | datacenter1 | rack1 |           5.0.3
```

创建Keyspace

```
CREATE KEYSPACE ateng
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
```

查看Keyspace

```
DESCRIBE KEYSPACES;
```

创建表并写入数据

```
USE ateng;
CREATE TABLE ateng.traces (
    trace_id UUID PRIMARY KEY,
    span_id UUID,
    parent_span_id UUID,
    name TEXT,
    timestamp BIGINT,
    duration BIGINT
);
DESCRIBE TABLES;
INSERT INTO ateng.traces (trace_id, span_id, parent_span_id, name, timestamp, duration)
VALUES (uuid(), uuid(), null, 'example-operation', 1617273600000, 500);
SELECT * FROM ateng.traces;
```

**服务扩缩容**

> 将服务扩展至3个副本

```
helm upgrade cassandra -n kongyu -f values.yaml --set replicaCount=3 cassandra-12.1.3.tgz
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=cassandra
```

**删除服务以及数据**

```
helm uninstall -n kongyu cassandra
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=cassandra
```

