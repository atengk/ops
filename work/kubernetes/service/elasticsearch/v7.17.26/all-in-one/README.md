# ElasticSearch

Elasticsearch 是一个开源的分布式搜索和分析引擎，基于 Apache Lucene 构建，支持全文搜索、结构化数据查询和实时分析。它以高性能和可扩展性著称，广泛应用于日志管理、网站搜索、实时监控和大数据分析场景。Elasticsearch 提供 RESTful API，易于集成和扩展。

- [官网链接](https://www.elastic.co/elasticsearch/)

**查看版本**

```
helm search repo bitnami/elasticsearch -l
```

**下载chart**

```
helm pull bitnami/elasticsearch --version 21.3.25
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 堆内存：master.heapSize
- 副本数量：master.replicaCount
- 存储配置：master.persistence.size
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/elasticsearch="true"
kubectl label nodes server03.lingo.local kubernetes.service/elasticsearch="true"
```

**创建服务**

```
helm install elasticsearch -n kongyu -f values.yaml elasticsearch-21.3.25.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=elasticsearch
kubectl logs -f -n kongyu elasticsearch-master-0
```

**使用服务**

访问Dashboard

> service/elasticsearch-kibana 的 5601

```
URL: http://192.168.1.10:22413
```

进入容器

```
kubectl exec -it -n kongyu elasticsearch-master-0 -- bash
```

内部网络访问

```
curl http://elasticsearch:9200/
```

集群网络访问

> 使用集群+NodePort访问

```
curl http://192.168.1.10:22857/
```

查看集群节点信息

```
curl http://elasticsearch:9200/_cat/nodes?v
```

查看集群健康状态

```
curl http://elasticsearch:9200/_cluster/health?pretty
```

查看已安装的插件

```
curl http://elasticsearch:9200/_cat/plugins?v
```

创建索引

```
curl -X PUT "http://localhost:9200/my_index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  }
}'
```

查询索引的设置

```
curl -X GET "http://localhost:9200/my_index/_settings?pretty"
```

写入数据

```
curl -X POST "http://localhost:9200/my_index/_doc" -H 'Content-Type: application/json' -d'
{
  "title": "OpenSearch Introduction",
  "content": "OpenSearch is a distributed search engine.",
  "tags": ["search", "analytics", "open source"],
  "timestamp": "2024-12-05T10:00:00"
}'
```

查询数据

```
curl -X GET "http://localhost:9200/my_index/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}'
```

删除索引

```
curl -X DELETE "http://localhost:9200/my_index"
```

**服务扩缩容**

> 将服务扩展至3个副本，服务至少2个副本

```
helm upgrade elasticsearch -n kongyu -f values.yaml --set master.replicaCount=3 elasticsearch-21.3.25.tgz
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=elasticsearch
```

**删除服务以及数据**

```
helm uninstall -n kongyu elasticsearch
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=elasticsearch
```

