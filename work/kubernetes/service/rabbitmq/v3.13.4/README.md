# 创建RabbitMQ

查看版本

```
helm search repo bitnami/rabbitmq -l
```

下载chart

```
helm pull bitnami/rabbitmq --version 14.5.0
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/rabbitmq="true"
kubectl label nodes server03.lingo.local kubernetes.service/rabbitmq="true"
```

创建服务

```shell
helm install rabbitmq -n kongyu -f values.yaml rabbitmq-14.5.0.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=rabbitmq
kubectl logs -f -n kongyu rabbitmq-0
```

使用服务

```
AMQP URL: http://192.168.1.19:26822/
WebURL: http://192.168.1.19:48887/
Username: admin
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n kongyu rabbitmq
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=rabbitmq
```

