# Fluent Bit

Fluent Bit 是一个轻量级、快速的日志和指标收集器，专为资源受限环境（如边缘计算、IoT 设备和容器）设计。它是 Fluentd 生态的一部分，提供高效的日志解析、过滤和传输功能，支持多种数据后端（如 Elasticsearch、Kafka、Loki）。Fluent Bit 具备低内存占用、高性能和可扩展性，适用于云原生和分布式日志管理场景。

- [官网链接](https://fluentbit.io/)



**查看版本**

```
helm search repo bitnami/fluent-bit -l
```

**下载chart**

```
helm pull bitnami/fluent-bit --version 2.5.7
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
kubectl label nodes server03.lingo.local kubernetes.service/fluent-bit="true"
```

**创建服务**

```
helm install fluent-bit -n kongyu -f values.yaml fluent-bit-2.5.7.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=fluent-bit
kubectl logs -f -n kongyu deploy/fluent-bit
```

**使用服务**



**删除服务以及数据**

```
helm uninstall -n kongyu fluent-bit
```

