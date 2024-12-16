# OpenSearch

OpenSearch 是一个开源的分布式搜索和分析引擎，基于 Apache 2.0 许可，支持实时搜索、日志分析和数据可视化。它继承自 Elasticsearch，并提供强大的查询、索引、分析功能，适用于大规模数据处理和监控。OpenSearch 具有高可扩展性，支持插件扩展，广泛用于日志管理、应用搜索和安全监控。

- [官网链接](https://opensearch.org)

**查看版本**

```
helm search repo bitnami/opensearch -l
```

**下载chart**

```
helm pull bitnami/opensearch --version 1.3.14
```

**创建证书**

- 参考 `certs/README.md` 完成证书的创建 

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 认证配置：security.adminPassword security.logstashPassword
- 堆内存：*.heapSize
- 副本数量：*.replicaCount
- 存储配置：*.persistence.size
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/opensearch="true"
kubectl label nodes server03.lingo.local kubernetes.service/opensearch="true"
```

**创建服务**

```
helm install opensearch -n kongyu -f values.yaml opensearch-1.3.14.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=opensearch
kubectl logs -f -n kongyu opensearch-master-0
```

**使用服务**

访问Dashboard

> service/opensearch-dashboards 的 5601

```
URL: http://192.168.1.10:27569
Username: admin
Password: Admin@123
```

进入容器

```
kubectl exec -it -n kongyu opensearch-master-0 -- bash
```

内部网络访问

```
curl \
  --cacert /opt/bitnami/opensearch/config/certs/ca.crt \
  -u admin:Admin@123 \
  https://opensearch:9200/
```

集群网络访问

> 使用集群+NodePort访问

```
curl \
  --cacert cert/opensearch-ca.crt \
  -u admin:Admin@123 \
  https://192.168.1.10:34169/
```

查看集群节点信息

```
curl \
  --cacert cert/opensearch-ca.crt \
  -u admin:Admin@123 \
  https://192.168.1.10:34169/_cat/nodes?v
```

查看集群健康状态

```
curl \
  --cacert cert/opensearch-ca.crt \
  -u admin:Admin@123 \
  https://192.168.1.10:34169/_cluster/health?pretty
```

**服务扩缩容**

> 将data服务扩展至3个副本，服务至少2个副本

```
helm upgrade opensearch \
  -n kongyu -f values.yaml \
  --set master.replicaCount=2 \
  --set data.replicaCount=3 \
  --set coordinating.replicaCount=2 \
  opensearch-1.3.14.tgz
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=opensearch
```

**删除服务以及数据**

删除服务以及数据

```
helm uninstall -n kongyu opensearch
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=opensearch
```

删除证书

```
kubectl delete -n kongyu secrets opensearch-admin-crt opensearch-coordinating-crt opensearch-data-crt opensearch-ingest-crt opensearch-master-crt
```

