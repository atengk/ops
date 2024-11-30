# ETCD

etcd 是一个分布式键值存储系统，专为分布式系统提供一致性和高可用性的数据存储。它使用 [Raft](https://raft.github.io/) 一致性算法，确保多个节点间的数据一致性，适合在容器编排和微服务环境中管理配置数据、服务发现等任务。etcd 是 Kubernetes 的核心组件之一，为其提供数据存储和分布式协调服务。

更多信息请参考：[etcd GitHub 仓库](https://github.com/etcd-io/etcd)

**查看版本**

```
helm search repo bitnami/etcd -l
```

**下载chart**

```
helm pull bitnami/etcd --version 10.5.3
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）

- 镜像地址：image.registry
- 是否启动备份：disasterRecovery
- 是否启用碎片整理：defrag
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/etcd="true"
kubectl label nodes server03.lingo.local kubernetes.service/etcd="true"
```

**创建服务**

```
helm install etcd -n kongyu -f values-etcd.yaml etcd-10.5.3.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc,cronjob -l app.kubernetes.io/name=etcd
kubectl logs -f -n kongyu etcd-0
```

**使用服务**

创建客户端容器

```
kubectl run etcd-client --rm --tty -i --restart='Never' --image \
  registry.lingo.local/bitnami/etcd:3.5.17 --namespace kongyu --command -- bash
```

内部网络访问-headless

```
export ETCDCTL_ENDPOINTS="http://etcd-0.etcd-headless.kongyu:2379,http://etcd-1.etcd-headless.kongyu:2379,http://etcd-2.etcd-headless.kongyu:2379"
etcdctl member list --write-out=table
```

内部网络访问

```
export ETCDCTL_ENDPOINTS="http://etcd.kongyu:2379"
etcdctl member list --write-out=table
```

集群网络访问

> 使用集群+NodePort访问

```
export ETCDCTL_ENDPOINTS="http://192.168.1.10:25751"
etcdctl member list --write-out=table
```

读写数据

```
etcdctl put foo "hello world"
etcdctl get foo
```

**删除服务以及数据**

```
helm uninstall -n kongyu etcd
kubectl delete -n kongyu pvc -l app.kubernetes.io/name=etcd
```

