# Prometheus

**Prometheus** 是一个开源的监控系统和时序数据库，广泛用于服务器、容器和应用的性能监控。它采用 **Pull 模式** 采集数据，支持 **PromQL 查询语言** 进行实时分析，并可与 **Grafana** 集成实现可视化。Prometheus 具备 **多维度数据模型**、**告警系统（Alertmanager）**，并对 **Kubernetes** 友好，是云原生监控的首选方案。

- [官网链接](https://prometheus.io/)



**查看版本**

```
helm search repo bitnami/prometheus -l
```

**下载chart**

```
helm pull bitnami/prometheus --version 1.4.9
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
kubectl label nodes server02.lingo.local kubernetes.service/prometheus="true"
kubectl label nodes server03.lingo.local kubernetes.service/prometheus="true"
```

**创建服务**

```
helm install prometheus -n kongyu -f values.yaml prometheus-1.4.9.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=prometheus
kubectl logs -f -n kongyu deploy/prometheus-server -c prometheus
```

**使用服务**

访问Prometheus地址

> service/prometheus-server 的 80

```
URL: http://192.168.1.10:19382
```

访问Alertmanager地址

> service/prometheus-alertmanager 的 80

```
URL: http://192.168.1.10:8126
```

**删除服务以及数据**

```
helm uninstall -n kongyu prometheus
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=prometheus
```

