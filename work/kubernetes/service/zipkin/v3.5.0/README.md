# Zipkin

Zipkin 是一个分布式追踪系统，用于收集、存储和分析应用程序中的时序数据，帮助开发者跟踪请求的流动、诊断性能问题及优化服务响应时间。它支持多种数据存储后端，并提供丰富的可视化功能。通过整合不同微服务的数据，Zipkin 能有效提高系统的可观察性和故障排查效率。

- [官网链接](ttps://zipkin.io/)



## 安装Zipkin

**查看版本**

```
helm search repo bitnami/zipkin -l
```

**下载chart**

```
helm pull bitnami/zipkin --version 1.3.1
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数：replicaCount
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/zipkin="true"
```

**创建服务**

```
helm install zipkin -n kongyu -f values.yaml zipkin-1.3.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zipkin
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=zipkin
```

**使用服务**

获取HTTP地址，service/zipkin的9411是HTTP端口

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[?(@.name=='http')].nodePort}" services zipkin)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

**删除服务以及数据**

```
helm uninstall -n kongyu zipkin
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=zipkin
```



## 外部Cassandra数据库

**查看版本**

```
helm search repo bitnami/zipkin -l
```

**下载chart**

```
helm pull bitnami/zipkin --version 1.3.1
```

**修改配置**

values-ext.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数：replicaCount
- 其他配置：...
- 外部cassandra数据库：externalDatabase，如果需要使用外部cassandra数据库，Chart的Bug

```
cat values-ext.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/zipkin="true"
```

**创建服务**

创建模版，修改配置，将应用中的的secret.zipkin-externaldb.CASSANDRA_PASSWORD的key补齐为db-password。

```
helm template zipkin -n kongyu -f values-ext.yaml zipkin-1.3.1.tgz > zipkin-ext.yaml
```

创建应用

```
kubectl apply -f zipkin-ext.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zipkin
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=zipkin
```

**使用服务**

获取HTTP地址，service/zipkin的9411是HTTP端口

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[?(@.name=='http')].nodePort}" services zipkin)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

**删除服务以及数据**

```
kubectl delete -f zipkin-ext.yaml
```

