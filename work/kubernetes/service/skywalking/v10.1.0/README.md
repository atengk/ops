# Apache SkyWalking

分布式系统的应用程序性能监控工具，特别为微服务、云原生和基于容器（Kubernetes）架构设计。

- [官网链接](https://skywalking.apache.org/)

- [下载链接](https://skywalking.apache.org/downloads/#KubernetesHelm)

**前提条件**

- 需要外部数据库：[ElasticSearch](/work/kubernetes/service/elasticsearch/v7.17.26/all-in-one/) 或者 [PostgreSQL（建议使用）](/work/kubernetes/service/postgresql/v17.2.0/standalone/)

**下载chart**

```
wget https://dlcdn.apache.org/skywalking/kubernetes/4.7.0/skywalking-helm-4.7.0.tgz
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 全局名称：fullnameOverride
- 镜像地址：*.image
- java参数：oap.javaOpts
- 外部数据库：elasticsearch或者postgresql
- 其他配置：...

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/skywalking="true"
```

**创建服务**

```
helm install skywalking -n kongyu -f values.yaml skywalking-helm-4.7.0.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app=skywalking
kubectl logs -f -n kongyu -l app=skywalking,component=oap
```

**获取端口**

oap grpc

```
kubectl get svc ateng-skywalking-oap -n kongyu -o=jsonpath='{.spec.ports[?(@.name=="grpc")].nodePort}'
```

ui web

```
kubectl get svc ateng-skywalking-ui -n kongyu -o=jsonpath='{.spec.ports[0].nodePort}'
```

**使用服务**

```
OAP GRPC: 192.168.1.10:8128
Web URL: http://192.168.1.10:13566
```

**删除服务以及数据**

```
helm uninstall -n kongyu skywalking
```

