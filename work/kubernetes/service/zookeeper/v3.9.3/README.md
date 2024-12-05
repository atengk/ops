# Zookeeper

Zookeeper 是一个开源的分布式协调服务，用于构建分布式应用程序中的同步和协调机制。它提供了高可用的服务，可以用于分布式锁、配置管理、命名服务、选举机制等场景。Zookeeper 采用类似于文件系统的层次结构来存储数据，所有的数据都会同步到集群中的所有节点，确保一致性。它通常用于大规模分布式系统中，支持高效的协调和故障恢复。

- [官网链接](https://zookeeper.apache.org/)

**查看版本**

```
helm search repo bitnami/zookeeper -l
```

**下载chart**

```
helm pull bitnami/zookeeper --version 13.6.0
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 堆内存：heapSize
- 副本数量：replicaCount
- 镜像地址：image.registry
- 存储配置：persistence.size
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/zookeeper="true"
kubectl label nodes server03.lingo.local kubernetes.service/zookeeper="true"
```

**创建服务**

```
helm install zookeeper -n kongyu -f values.yaml zookeeper-13.6.0.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zookeeper
kubectl logs -f -n kongyu zookeeper-0
```

**使用服务**

创建客户端容器

```
kubectl run zookeeper-client --rm --tty -i --restart='Never' --image  registry.lingo.local/bitnami/zookeeper:3.9.3 --namespace kongyu --command -- bash
```

内部网络访问-headless

```
zkCli.sh -server zookeeper-0.zookeeper-headless.kongyu:2181,zookeeper-2.zookeeper-headless.kongyu:2181,zookeeper-3.zookeeper-headless.kongyu:2181
```

内部网络访问

```
zkCli.sh -server zookeeper.kongyu:2181
```

集群网络访问

> 使用集群+NodePort访问

```
zkCli.sh -server 192.168.1.10:38378
```

使用命令

```
create /my_node "This is a test node"
get /my_node
```

**服务扩缩容**

> 将服务扩展至5个副本

```
helm upgrade zookeeper -n kongyu -f values.yaml --set replicaCount=5 zookeeper-13.6.0.tgz
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zookeeper
```

**删除服务以及数据**

```
helm uninstall -n kongyu zookeeper
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=zookeeper
```

