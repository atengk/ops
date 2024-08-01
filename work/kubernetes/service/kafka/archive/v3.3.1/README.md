# Zookeeper

创建Zookeeper

```
helm install zookeeper -n kongyu -f ./values-zookeeper.yaml ./zookeeper-10.2.4.tgz
```

查看Zookeeper

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/name=zookeeper
```

访问Zookeeper

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get --namespace kongyu -o jsonpath="{.spec.ports[0].nodePort}" services zookeeper)
echo zkCli.sh -server $NODE_IP:$NODE_PORT
```

删除Zookeeper

```
helm uninstall -n kongyu zookeeper
kubectl delete -n kongyu pvc data-zookeeper-{0..2}
```



# Kafka

创建Kafka

```
helm install kafka -n kongyu -f ./values-kafka.yaml ./kafka-19.0.1.tgz
```

查看Kafka

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/name=kafka
```

查看Kafka

```
export NODE_IP=$(kubectl get nodes --namespace kongyu -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORTS=$(kubectl get --namespace kongyu services -l "app.kubernetes.io/name=kafka,app.kubernetes.io/instance=kafka,app.kubernetes.io/component=kafka,pod" -o jsonpath='{.items[*].spec.ports[0].nodePort}' | tr ' ' '\n')
for port in ${NODE_PORTS};do echo ${NODE_IP}:${port};done
```

删除Kafka

```
helm uninstall -n kongyu kafka
kubectl delete -n kongyu pvc data-kafka-{0..2}
```

