# Kafka

Kafka是一个开源的分布式流处理平台，主要用于处理实时数据流。它可以高效地发布和订阅消息，存储数据流，并处理这些数据。Kafka通常用于构建数据管道和流应用，能够保证高吞吐量、低延迟和高可扩展性。

## 常规模式

**查看版本**

```
helm search repo bitnami/kafka -l
```

**下载chart**

```
helm pull bitnami/kafka --version 30.1.2
```

**修改配置**

根据环境做出相应的修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/kafka="true"
```

**创建服务**

```
helm install kafka -n kongyu -f values.yaml kafka-30.1.2.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kafka
kubectl logs -f -n kongyu kafka-controller-0
```

**使用服务**

```
kubectl run kafka-client -i --tty --rm --restart='Never' --image registry.lingo.local/service/kafka:3.8.0 --namespace kongyu --command -- bash
kafka-console-producer.sh \
    --broker-list kafka:9092 \
    --topic test
kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --topic test \
    --from-beginning
```

**删除服务以及数据**

```
helm uninstall -n kongyu kafka
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=kafka
```



## 云公网模式

> 集群模式暂时不支持这样处理，如有需求参考**大数据**篇章的相关文档

**查看版本**

```
helm search repo bitnami/kafka -l
```

**下载chart**

```
helm pull bitnami/kafka --version 30.1.2
```

**修改配置**

根据环境做出相应的修改

```
cat values-public-ip.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/kafka="true"
```

**创建服务**

```
helm install kafka -n kongyu -f values-public-ip.yaml kafka-30.1.2.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kafka
kubectl logs -f -n kongyu kafka-controller-0
```

**修改服务**

修改ConfigMap，修改 `advertised.listeners` 的 `PUBLICIP://advertised-address-placeholder:9096`，将其修改为服务映射后的公网IP和端口 ，如下所示

```
# kubectl edit -n kongyu configmap kafka-controller-configuration
    ...
    advertised.listeners=CLIENT://advertised-address-placeholder:9092,INTERNAL://advertised-address-placeholder:9094,PUBLICIP://106.86.176.153:10101
```

新增公网IP服务

```
kubectl apply -f - <<EOF
kind: Service
apiVersion: v1
metadata:
  name: kafka-publicip
  namespace: kongyu
  labels:
    app.kubernetes.io/component: kafka
    app.kubernetes.io/instance: kafka
    app.kubernetes.io/name: kafka
    app.kubernetes.io/version: 3.8.0
spec:
  ports:
    - name: tcp-publicip
      protocol: TCP
      port: 9096
      targetPort: publicip
      nodePort: 29096
  selector:
    app.kubernetes.io/instance: kafka
    app.kubernetes.io/name: kafka
    app.kubernetes.io/part-of: kafka
  type: NodePort
EOF
```

**重启服务**

```
kubectl rollout restart -n kongyu statefulsets.apps kafka-controller
```

**使用服务**

```
kubectl run kafka-client -i --tty --rm --restart='Never' --image registry.lingo.local/service/kafka:3.8.0 --namespace kongyu --command -- bash
kafka-console-producer.sh \
    --broker-list 106.86.176.153:10101 \
    --topic test
kafka-console-consumer.sh \
    --bootstrap-server 106.86.176.153:10101 \
    --topic test \
    --from-beginning
```

**删除服务以及数据**

```
helm uninstall -n kongyu kafka
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=kafka
kubectl delete svc -n kongyu kafka-publicip
```

