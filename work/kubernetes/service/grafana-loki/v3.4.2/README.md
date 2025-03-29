# Grafana Loki

Grafana Loki 是一款轻量级、可扩展的日志聚合系统，专为云原生环境设计。它采用类似 Prometheus 的标签索引方式，而非全文索引，从而降低存储和查询成本。Loki 与 Promtail、Fluentd、Grafana 无缝集成，支持 Kubernetes、Docker 等多种日志来源，适用于监控、故障排查和日志分析。其高效的索引方式使查询更快，并支持多租户和按需扩展。

- [官网地址](https://grafana.com/oss/loki/)



**查看版本**

```
helm search repo bitnami/grafana-loki -l
```

**下载chart**

```
helm pull bitnami/grafana-loki --version 4.7.6
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 外部缓存数据库：externalMemcached*
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/grafana-loki="true"
```

**创建服务**

```
helm install grafana-loki -n kongyu -f values.yaml grafana-loki-4.7.6.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=grafana-loki
kubectl logs -f -n kongyu deploy/grafana-loki-compactor
```

**使用服务**



**删除服务以及数据**

```
helm uninstall -n kongyu grafana-loki
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=grafana-loki
```

