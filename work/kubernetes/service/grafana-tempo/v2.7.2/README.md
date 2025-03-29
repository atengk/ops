# Grafana Tempo

Grafana Tempo 是一款高效、可扩展的分布式追踪（tracing）系统，专为存储和查询跟踪数据而设计。它支持 OpenTelemetry、Jaeger、Zipkin 等追踪格式，并通过无索引存储方式降低成本。Tempo 可与 Grafana 无缝集成，帮助开发者分析分布式系统的性能瓶颈，优化应用性能。适用于微服务架构、云原生环境的大规模追踪需求。

- [官网地址](https://grafana.com/oss/tempo/)




**查看版本**

```
helm search repo bitnami/grafana-tempo -l
```

**下载chart**

```
helm pull bitnami/grafana-tempo --version 4.0.1
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
kubectl label nodes server03.lingo.local kubernetes.service/grafana-tempo="true"
```

**创建服务**

```
helm install grafana-tempo -n kongyu -f values.yaml grafana-tempo-4.0.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=grafana-tempo
kubectl logs -f -n kongyu deploy/grafana-tempo
```

**使用服务**

访问Web地址

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[0].nodePort}" services grafana-tempo-query-frontend)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

**删除服务以及数据**

```
helm uninstall -n kongyu grafana-tempo
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=grafana-tempo
```

