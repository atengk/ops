# 创建RabbitMQ

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install rabbitmq -n kongyu -f values.yaml rabbitmq-12.5.6.tgz
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
kubectl delete pvc -n kongyu data-rabbitmq-{0..2}
```

