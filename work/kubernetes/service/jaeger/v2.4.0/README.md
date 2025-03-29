# Jaeger

Jaeger是一个开源的分布式追踪系统，旨在帮助开发者监控和分析微服务架构中的请求流。它能够追踪请求在不同服务间的传播过程，帮助识别性能瓶颈、故障定位以及优化系统响应时间。Jaeger支持多种数据存储后端，通常与Prometheus、Grafana等工具集成，提供丰富的可视化分析功能。

- [官网链接](https://www.jaegertracing.io/)



## 安装Jaeger

**查看版本**

```
helm search repo bitnami/jaeger -l
```

**下载chart**

```
helm pull bitnami/jaeger --version 5.1.12
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数：query.replicaCount collector.replicaCount
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/jaeger="true"
```

**创建服务**

```
helm install jaeger -n kongyu -f values.yaml jaeger-5.1.12.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=jaeger
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=jaeger
```

**使用服务**

获取Web访问地址，service/jaeger-query的16686是Web端口

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[?(@.name=='api')].nodePort}" services jaeger-query)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

获取Zipkin地址，service/jaeger-collector的9411是Zipkin端口

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get service jaeger-collector -n kongyu -o jsonpath="{.spec.ports[?(@.name=='zipkin')].nodePort}")
echo http://$NODE_IP:$NODE_PORT
```

获取OTLP的gRPC地址，service/jaeger-collector的4317是OTLP的gRPC端口

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get service jaeger-collector -n kongyu -o jsonpath="{.spec.ports[?(@.name=='otlp-grpc')].nodePort}")
echo http://$NODE_IP:$NODE_PORT
```

获取OTLP的HTTP地址，service/jaeger-collector的4318是OTLP的HTTP端口

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get service jaeger-collector -n kongyu -o jsonpath="{.spec.ports[?(@.name=='otlp-http')].nodePort}")
echo http://$NODE_IP:$NODE_PORT
```

**删除服务以及数据**

```
helm uninstall -n kongyu jaeger
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=jaeger
```



## 外部Cassandra数据库

**查看版本**

```
helm search repo bitnami/jaeger -l
```

**下载chart**

```
helm pull bitnami/jaeger --version 5.1.12
```

**修改配置**

values-ext.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数：query.replicaCount collector.replicaCount
- 其他配置：...
- 外部cassandra数据库：externalDatabase（chart有问题，需要修改一些配置）。

```
cat values-ext.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/jaeger="true"
```

**创建服务**

创建模版，然后修改BUG。没有Secret.jaeger-cassandra需要自己创建，CASSANDRA_PASSWORD使用该Secret的cassandra-password。具体参考 `jaeger-ext.yaml` 文件

```
helm template jaeger -n kongyu -f values-ext.yaml jaeger-5.1.12.tgz > jaeger-ext.yaml
```

创建应用

```
kubectl apply -f jaeger-ext.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=jaeger
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=jaeger
```

**使用服务**

获取Web访问地址，service/jaeger-query的16686是Web端口

```
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[?(@.name=='api')].nodePort}" services jaeger-query)
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

获取Zipkin地址，service/jaeger-collector的9411是Zipkin端口

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get service jaeger-collector -n kongyu -o jsonpath="{.spec.ports[?(@.name=='zipkin')].nodePort}")
echo http://$NODE_IP:$NODE_PORT
```

获取OTLP的gRPC地址，service/jaeger-collector的4317是OTLP的gRPC端口

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get service jaeger-collector -n kongyu -o jsonpath="{.spec.ports[?(@.name=='otlp-grpc')].nodePort}")
echo http://$NODE_IP:$NODE_PORT
```

获取OTLP的HTTP地址，service/jaeger-collector的4318是OTLP的HTTP端口

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get service jaeger-collector -n kongyu -o jsonpath="{.spec.ports[?(@.name=='otlp-http')].nodePort}")
echo http://$NODE_IP:$NODE_PORT
```

**删除服务以及数据**

```
kubectl delete -f jaeger-ext.yaml
```

