# Grafana Mimir

Grafana Mimir 是一款高可用、可扩展的时序数据库，专为存储和查询 Prometheus 指标而设计。它支持多租户、水平扩展，并优化了查询性能，适用于大规模监控场景。Mimir 兼容 PromQL，能够与 Prometheus、Grafana 无缝集成，提供高效的数据存储和管理能力，助力企业构建强大的监控系统。

- [官网地址](https://grafana.com/oss/mimir/)



**查看版本**

```
helm search repo bitnami/grafana-mimir -l
```

**下载chart**

```
helm pull bitnami/grafana-mimir --version 1.4.5
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
kubectl label nodes server03.lingo.local kubernetes.service/grafana-mimir="true"
```

**创建服务**

```
helm install grafana-mimir -n kongyu -f values.yaml grafana-mimir-1.4.5.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=grafana-mimir
kubectl logs -f -n kongyu deploy/grafana-mimir
```

**使用服务**

获取地址

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[0].nodePort}" services grafana-mimir-gateway)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
```

​    Remote write endpoints for Prometheus or Grafana Agent:

```
echo "http://$NODE_IP:$NODE_PORT/api/v1/push"
```

​    Read address, Grafana data source (Prometheus) URL:

```
echo "http://$NODE_IP:$NODE_PORT/prometheus"
```

**删除服务以及数据**

```
helm uninstall -n kongyu grafana-mimir
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=grafana-mimir
```

