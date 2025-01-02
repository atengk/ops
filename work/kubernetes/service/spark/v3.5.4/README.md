# Spark3

Apache Spark 是一个开源的大数据处理框架，旨在快速处理大规模数据集。它提供了分布式计算能力，支持批处理和流处理。Spark 提供了丰富的API，支持多种编程语言（如Java、Scala、Python、R），并且能在不同的集群管理器（如Hadoop YARN、Kubernetes）上运行。Spark 通过内存计算和高度优化的执行引擎，显著提高了数据处理速度，广泛应用于数据分析、机器学习和图计算等领域。

- [官网链接](https://spark.apache.org/)



**查看版本**

```
helm search repo bitnami/spark -l
```

**下载chart**

```
helm pull bitnami/spark --version 9.2.14
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- master和worker的资源分配：master.resources worker.resources
- worker数量：worker.replicaCount
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/spark="true"
kubectl label nodes server03.lingo.local kubernetes.service/spark="true"
```

**创建服务**

```
helm install spark -n kongyu -f values.yaml spark-9.2.14.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app.kubernetes.io/instance=spark
kubectl logs -f -n kongyu spark-master-0
```

**使用服务**

访问Web

> service为spark-master-svc的80端口

```
URL: http://192.168.1.10:14175
```

进入容器

```
kubectl run spark-client --rm --tty -i --restart='Never' --image  registry.lingo.local/bitnami/spark:3.5.4 --namespace kongyu --command -- bash
```

提交任务

```
spark-submit --master spark://spark-master-svc.kongyu:7077 \
    --class org.apache.spark.examples.SparkPi \
    --deploy-mode cluster \
    examples/jars/spark-examples_2.12-3.5.4.jar 100
```

**删除服务**

```
helm uninstall -n kongyu spark
```

