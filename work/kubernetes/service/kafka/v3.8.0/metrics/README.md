# 创建kafka

查看版本

```
helm search repo bitnami/kafka -l
```

下载chart

```
helm pull bitnami/kafka --version 30.1.2
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
helm install kafka -n kongyu -f values.yaml kafka-30.1.2.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kafka
kubectl logs -f -n kongyu kafka-controller-0
```

使用服务

```
kubectl run kafka-client -i --tty --rm --restart='Never' --image registry.lingo.local/service/kafka:3.8.0 --namespace kongyu --command -- bash
kafka-console-producer.sh \
    --broker-list kafka:9092 \
    --topic test
kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --topic test \
    --from-beginning
curl kafka-jmx-metrics:5556/metrics
```

删除服务以及数据

```
helm uninstall -n kongyu kafka
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=kafka
```

