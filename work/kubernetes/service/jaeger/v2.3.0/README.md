# Jaeger

Jaeger是一个开源的分布式追踪系统，旨在帮助开发者监控和分析微服务架构中的请求流。它能够追踪请求在不同服务间的传播过程，帮助识别性能瓶颈、故障定位以及优化系统响应时间。Jaeger支持多种数据存储后端，通常与Prometheus、Grafana等工具集成，提供丰富的可视化分析功能。

- [官网链接](https://www.jaegertracing.io/)

**查看版本**

```
helm search repo bitnami/jaeger -l
```

**下载chart**

```
helm pull bitnami/jaeger --version 5.1.9
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数：query.replicaCount collector.replicaCount
- 其他配置：...
- 外部cassandra数据库：externalDatabase（chart有问题，暂时先不用使用外部数据库）

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/jaeger="true"
```

**创建服务**

```
helm install jaeger -n kongyu -f values.yaml jaeger-5.1.9.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=jaeger
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=jaeger
```

**使用服务**

获取访问地址

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[0].nodePort}" services jaeger-query)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

访问服务

```
URL: http://192.168.1.10:14785
```

**删除服务以及数据**

```
helm uninstall -n kongyu jaeger
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=jaeger
```

