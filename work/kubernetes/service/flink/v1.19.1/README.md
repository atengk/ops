# Flink

Flink 是一个开源的分布式流处理框架，专注于大规模数据流的实时处理。它提供了高吞吐量、低延迟的处理能力，支持有状态和无状态的数据流操作。Flink 可以处理事件时间、窗口化、流与批处理混合等复杂场景，广泛应用于实时数据分析、实时监控、机器学习等领域。其强大的容错机制和高可扩展性，使其成为大数据领域中的重要技术之一。

- [官网链接](https://nightlies.apache.org/flink/flink-docs-release-1.20/docs/dev/datastream/overview/)



**查看版本**

```
helm search repo bitnami/flink -l
```

**下载chart**

```
helm pull bitnami/flink --version 1.3.16
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- jobmanager和taskmanager的资源分配：jobmanager.extraEnvVars taskmanager.extraEnvVars
- taskmanager数量：worker.replicaCount
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/flink="true"
kubectl label nodes server03.lingo.local kubernetes.service/flink="true"
```

**创建服务**

```
helm install flink -n kongyu -f values.yaml flink-1.3.16.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app.kubernetes.io/instance=flink
kubectl logs -f -n kongyu deploy/flink-jobmanager
```

**使用服务**

访问Web

> service flink-jobmanager的8081端口

```
URL: http://192.168.1.10:34389
```

进入容器

```
kubectl run flink-client --rm --tty -i --restart='Never' --image  registry.lingo.local/bitnami/flink:1.19.1 --namespace kongyu --command -- bash
```

运行批处理任务

```
flink run \
  -m flink-jobmanager.kongyu:8081 \
  $FLINK_HOME/examples/batch/WordCount.jar
```

运行流处理任务

```
flink run -d \
  -m flink-jobmanager.kongyu:8081 \
  $FLINK_HOME/examples/streaming/TopSpeedWindowing.jar
```

查看任务

```
flink list -m flink-jobmanager.kongyu:8081
```

取消任务

```
flink cancel -m flink-jobmanager.kongyu:8081 b76a925eaebdd761a332c72948597831
```

**删除服务**

```
helm uninstall -n kongyu flink
```

