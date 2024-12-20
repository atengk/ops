# 创建kafka

查看版本

```
helm search repo bitnami/kafka -l
```

下载chart

```
helm pull bitnami/kafka --version 29.3.7
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/kafka="true"
```

创建服务

```
helm install kafka -n kongyu -f values.yaml kafka-29.3.7.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kafka
kubectl logs -f -n kongyu kafka-controller-0
```

使用服务

```
## 启动容器
kubectl run kafka-client -i --tty --rm --restart='Never' --image registry.lingo.local/service/kafka:3.7.1 --namespace kongyu --command -- bash
## 拷贝client.properties
kubectl cp --namespace kongyu client.properties kafka-client:/tmp/client.properties
## 生产数据
kafka-console-producer.sh \
    --producer.config /tmp/client.properties \
    --broker-list kafka:9092 \
    --topic test
## 消费数据
kafka-console-consumer.sh \
    --consumer.config /tmp/client.properties \
    --bootstrap-server kafka:9092 \
    --topic test \
    --from-beginning
```

删除服务以及数据

```
helm uninstall -n kongyu kafka
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=kafka
```

