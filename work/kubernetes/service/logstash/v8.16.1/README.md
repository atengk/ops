# Logstash

Logstash是一个开源的数据收集、处理和转发工具，广泛用于日志聚合和分析。它能够从多种数据源（如日志文件、数据库、消息队列等）收集数据，通过插件进行过滤和转换，最终将数据输出到各种存储系统（如Elasticsearch、Kafka等）。Logstash常与Elasticsearch和Kibana一起组成Elastic Stack，用于实时搜索和数据可视化。

- [官网地址](https://www.elastic.co/logstash)


**查看版本**

```
helm search repo bitnami/logstash -l
```

**下载chart**

```
helm pull bitnami/logstash --version 6.4.4
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数量：replicaCount
- 服务配置：input、extraInput、filter、output
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/logstash="true"
```

**创建服务**

```
helm install logstash -n kongyu -f values.yaml logstash-6.4.4.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=logstash
kubectl logs -f -n kongyu logstash-0
```

**使用服务**

访问Dashboard

> service/logstash 的 8080(HTTP)、5000(TCP)

```
HTTP Address: http://192.168.1.10:24214
TCP Address: http://192.168.1.10:21566
```

**服务扩缩容**

> 将服务扩展至3个副本，服务至少2个副本

```
helm upgrade logstash -n kongyu -f values.yaml --set replicaCount=3 logstash-6.4.4.tgz
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=logstash
```

**删除服务以及数据**

```
helm uninstall -n kongyu logstash
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=logstash
```

