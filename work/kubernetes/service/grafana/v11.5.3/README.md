# Grafana

Grafana 是一个开源的数据可视化和监控工具，支持多种数据源（如 Prometheus、MySQL、Elasticsearch 等）。它提供动态仪表盘、警报和数据分析功能，适用于 IT 监控、业务分析和物联网应用。Grafana 具有直观的界面，可通过 SQL 查询或 API 轻松创建可视化图表，并支持权限管理及插件扩展，广泛应用于 DevOps 和大数据领域。

- [官网地址](https://grafana.com/)
- [Dashboards](https://grafana.com/grafana/dashboards)



**查看版本**

```
helm search repo bitnami/grafana -l
```

**下载chart**

```
helm pull bitnami/grafana --version 11.6.1
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
kubectl label nodes server03.lingo.local kubernetes.service/grafana="true"
```

**创建服务**

```
helm install grafana -n kongyu -f values.yaml grafana-11.6.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=grafana
kubectl logs -f -n kongyu deploy/grafana
```

**使用服务**

访问Web地址

> service/grafana 的 3000

```
URL: http://192.168.1.10:18764
```

**删除服务以及数据**

```
helm uninstall -n kongyu grafana
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=grafana
```

