# Fluentd

Fluentd 是一个开源的数据收集和日志聚合工具，专为高效、灵活的日志处理设计。它支持从多种来源收集数据，进行过滤、缓冲，并将其转发到不同的存储系统（如 Elasticsearch、Kafka、S3）。Fluentd 采用 JSON 作为数据格式，提供丰富的插件生态，适用于云原生、容器化和大规模分布式系统的日志管理。

- [官网链接](https://www.fluentd.org/)



**查看版本**

```
helm search repo bitnami/fluentd -l
```

**下载chart**

```
helm pull bitnami/fluentd --version 7.1.4
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/fluentd="true"
```

**创建服务**

```
helm install fluentd -n kongyu -f values.yaml fluentd-7.1.4.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=fluentd
kubectl logs -f -n kongyu fluentd-0
```

**使用服务**



**删除服务以及数据**

```
helm uninstall -n kongyu fluentd
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=fluentd
```

