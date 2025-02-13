# Zipkin

Zipkin 是一个分布式追踪系统，用于收集、存储和分析应用程序中的时序数据，帮助开发者跟踪请求的流动、诊断性能问题及优化服务响应时间。它支持多种数据存储后端，并提供丰富的可视化功能。通过整合不同微服务的数据，Zipkin 能有效提高系统的可观察性和故障排查效率。

- [官网链接](ttps://zipkin.io/)

**查看版本**

```
helm search repo bitnami/zipkin -l
```

**下载chart**

```
helm pull bitnami/zipkin --version 1.1.3
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数：replicaCount
- 其他配置：...
- 外部cassandra数据库：externalDatabase，如果需要使用外部cassandra数据库，会出现配置生成错误，待后续更新是否会解决该问题。就是把最终生成的yaml的secretKeyRef是zipkin-externaldb的key补为db-password就行了

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/zipkin="true"
```

**创建服务**

```
helm install zipkin -n kongyu -f values.yaml zipkin-1.1.3.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zipkin
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=zipkin
```

**使用服务**

```
URL: http://192.168.1.10:42590
```

**删除服务以及数据**

```
helm uninstall -n kongyu zipkin
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=zipkin
```

