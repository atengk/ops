# FoundationDB

FoundationDB 是一个开源的分布式数据库系统，最初由 FoundationDB 公司开发，后被 Apple 收购并开源。它的设计目标是高性能、可扩展性和强一致性，并且支持多种数据模型。通过其独特的架构，FoundationDB 提供了一个统一的、键值对存储的底层数据库，其他数据模型（如文档、关系型等）都可以基于它构建。

- [GitHub地址](https://github.com/FoundationDB/fdb-kubernetes-operator)
- [官方文档](https://apple.github.io/foundationdb/configuration.html?highlight=fdbserver#fdbserver-section)



**下载配置文件**

- 下载链接中的三个crd文件：[下载地址](https://github.com/FoundationDB/fdb-kubernetes-operator/tree/v1.52.0/config/crd/bases)

**安装CRD**

```
kubectl apply -f apps.foundationdb.org_foundationdbclusters.yaml
kubectl apply -f apps.foundationdb.org_foundationdbbackups.yaml
kubectl apply -f apps.foundationdb.org_foundationdbrestores.yaml
```

**安装Operator**

官网提供了一个[示例](https://github.com/FoundationDB/fdb-kubernetes-operator/blob/v1.52.0/config/samples/deployment.yaml)，这里修改了以下配置

- 修改了DNS的配置
- 修改了镜像地址
- 删减了其他版本的sidecar

```
kubectl create ns foundationdb
kubectl apply -n foundationdb -f deployment.yaml
```

**查看Operator**

```
kubectl get -n foundationdb pod
kubectl logs -f -n foundationdb deploy/fdb-kubernetes-operator-controller-manager
```

**创建集群**

官网提供了一个[示例](https://github.com/FoundationDB/fdb-kubernetes-operator/blob/v1.52.0/config/samples/cluster.yaml)，这里修改了以下配置

- 修改了DNS的配置
- 修改了镜像地址
- 存储类相关

```
kubectl apply -n foundationdb -f cluster.yaml
```

**查看集群**

```
kubectl get -n foundationdb pod,svc,pvc -l foundationdb.org/fdb-cluster-name=ateng-cluster
kubectl get -n foundationdb fdb
```

**获取集群配置文件**

```
kubectl get cm -n foundationdb ateng-cluster-config  -o jsonpath='{.data.cluster-file}'
```

**使用服务**

进入容器

```
kubectl exec -it -n foundationdb $(kubectl get -n foundationdb pod -l foundationdb.org/fdb-process-class=cluster_controller -o jsonpath="{.items[0].metadata.name}") -- bash
```

进入客户端

```
fdbcli -C /var/dynamic-conf/fdb.cluster
```

查看集群

```
fdb> status details
```

使用集群

```
fdb> writemode on
fdb> set mykey myvalue
fdb> get mykey
fdb> clear mykey
fdb> writemode off
```



**删除服务**

删除集群

```
kubectl delete -n foundationdb -f cluster.yaml
```

删除Operator

```
kubectl delete -n foundationdb -f deployment.yaml
```

删除CRD

```
kubectl delete -f apps.foundationdb.org_foundationdbclusters.yaml
kubectl delete -f apps.foundationdb.org_foundationdbbackups.yaml
kubectl delete -f apps.foundationdb.org_foundationdbrestores.yaml
```

