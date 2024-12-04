# RabbitMQ

RabbitMQ 是一个开源的消息中间件，基于 AMQP（高级消息队列协议）协议，提供可靠的消息传递、异步处理和分布式系统的解耦。它支持多种消息传输模式，如点对点、发布/订阅等，适用于分布式应用程序、微服务架构和高并发环境。RabbitMQ 提供了高可用性、消息确认、死信队列等功能，广泛应用于数据交换和任务调度。

- [官网链接](https://www.rabbitmq.com/)

**查看版本**

```
helm search repo bitnami/rabbitmq -l
```

**下载chart**

```
helm pull bitnami/rabbitmq --version 15.0.4
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 认证配置：auth.username auth.password
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/rabbitmq="true"
kubectl label nodes server03.lingo.local kubernetes.service/rabbitmq="true"
```

**创建服务**

> 如果需要装插件，参考文件 `values-plugins.yaml`

```shell
helm install rabbitmq -n kongyu -f values.yaml rabbitmq-15.0.4.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=rabbitmq
kubectl logs -f -n kongyu rabbitmq-0
```

**使用服务**

进入容器

```
kubectl exec -n kongyu -it rabbitmq-0 -- bash
```

查看集群信息

```
rabbitmqctl cluster_status
rabbitmq-plugins list
```

Web访问

> AMQP: 5672
>
> Web: 15672

```
AMQP URL: http://192.168.1.10:26822/
WebURL: http://192.168.1.10:48887/
Username: admin
Password: Admin@123
```

**服务扩缩容**

> 将服务扩展至5个副本

```
helm upgrade rabbitmq -n kongyu -f values.yaml --set replicaCount=5 rabbitmq-15.0.4.tgz
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=rabbitmq
```

**删除服务以及数据**

```
helm uninstall -n kongyu rabbitmq
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=rabbitmq
```

