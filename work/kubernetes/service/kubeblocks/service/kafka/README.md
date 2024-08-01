# 使用 KubeBlocks 管理 Kafka服务

以下步骤将指导您如何使用 KubeBlocks 和 `kbcli` 工具来管理 Kafka服务。

https://cn.kubeblocks.io/docs/preview/user-docs/kubeblocks-for-postgresql/cluster-management/create-and-connect-a-kafka-cluster

### 1. 查看服务版本

要查看当前 Kafka服务的版本信息，使用以下命令：
```sh
kbcli clusterversion list --cluster-definition=kafka
```

### 2. 创建服务

使用 Kubernetes 配置文件创建 Kafka服务。确保 `cluster.yaml` 文件已正确配置。
```sh
kubectl apply -f cluster.yaml
```

配置参数

```
kbcli cluster -n kongyu configure kafka-cluster \
  --set=auto.create.topics.enable=true \
  --set=delete.topic.enable=true \
  --set=log.retention.hours=8 \
  --set=log.retention.bytes=1073741824 \
  --set=log.retention.check.interval.ms=300000 \
  --set=log.segment.bytes=1073741824 \
  --set=max.partition.fetch.bytes=104857600 \
  --set=max.request.size=104857600 \
  --set=message.max.bytes=104857600
```

### 3. 查看服务状态

#### 查看日志
查看 Kafka服务的实时日志：
```sh
kbcli cluster -n kongyu logs -f kafka-cluster
```

#### 列出服务
列出 Kafka集群的所有服务：
```sh
kbcli cluster -n kongyu list kafka-cluster
```

#### 描述服务
获取 Kafka集群的详细信息：
```sh
kbcli cluster -n kongyu describe kafka-cluster
```

#### 查看资源
查看指定命名空间下的 Pod、服务和 PVC 的详细信息：

```sh
kubectl get -n kongyu pod,svc,pvc -o wide
```

### 4. 查看密码

获取 Kafka服务的连接密码，使用以下命令：
```sh

```

### 5. 访问服务

使用 `kbcli` 连接到 Kafka服务：
```sh

```

### 6. 管理服务

#### 重启服务
重启 Kafka服务：
```sh
kbcli cluster -n kongyu restart kafka-cluster
```

#### 停止服务
停止 Kafka服务：
```sh
kbcli cluster -n kongyu stop kafka-cluster
```

#### 启动服务
启动已停止的 Kafka服务：
```sh
kbcli cluster -n kongyu start kafka-cluster
```

#### 删除服务
删除 Kafka服务：
```sh
kbcli cluster -n kongyu delete kafka-cluster
```
删除数据：
```sh
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=kafka-cluster
```

---

以上步骤将帮助您使用 KubeBlocks 和 `kbcli` 工具来创建、管理和访问 Kafka服务。如果在使用过程中遇到任何问题，请参考 KubeBlocks 的[官方文档](https://cn.kubeblocks.io/docs/preview/user-docs/kubeblocks-for-postgresql/apecloud-postgresql-intro/)获取更多信息。