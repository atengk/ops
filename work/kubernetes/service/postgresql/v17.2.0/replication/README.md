# PostgreSQL

PostgreSQL 是一个功能强大的开源关系型数据库，支持标准 SQL 和面向对象特性，具备高扩展性、数据完整性和并发控制能力。通过 PostGIS 扩展，它还能处理地理空间数据，适用于企业级应用、数据分析和地理信息系统（GIS）等多种场景。

**查看版本**

```
helm search repo bitnami/postgresql -l
```

**下载chart**

```
helm pull bitnami/postgresql --version 16.2.1
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 认证配置：auth.postgresPassword
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/postgresql="true"
kubectl label nodes server03.lingo.local kubernetes.service/postgresql="true"
```

**创建服务**

```shell
helm install postgresql -n kongyu -f values.yaml postgresql-16.2.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=postgresql
kubectl logs -f -n kongyu postgresql-primary-0
```

**使用服务**

创建客户端容器

```
kubectl run postgresql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/bitnami/postgresql:17.2.0 --namespace kongyu --env="PGPASSWORD=Admin@123" --command -- bash
```

内部网络访问-headless

```
## 读写节点
psql --host postgresql-primary-0.postgresql-primary-hl.kongyu -U postgres -d postgres -p 5432
## 只读节点
psql --host postgresql-read-0.postgresql-read-hl.kongyu -U postgres -d postgres -p 5432
```

内部网络访问

```
## 读写节点
psql --host postgresql-primary.kongyu -U postgres -d postgres -p 5432
## 只读节点
psql --host postgresql-read.kongyu -U postgres -d postgres -p 5432
```

集群网络访问

> 使用集群+NodePort访问

```
## 读写节点
psql --host 192.168.1.10 -U postgres -d postgres -p 46045
## 只读节点
psql --host 192.168.1.10 -U postgres -d postgres -p 32143
```

使用SQL

```
\l
SELECT name, setting FROM pg_settings;
SELECT * FROM pg_stat_replication;
```

**删除服务以及数据**

```
helm uninstall -n kongyu postgresql
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=postgresql
```

