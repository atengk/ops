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

**创建自定义证书**

- 参考`cert/README.md`目录下的文档

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）

- 镜像地址：image.registry
- root密码：auth.rbac.rootPassword
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
kubectl apply -n kongyu -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: etcd-client
spec:
  containers:
  - name: etcd-client
    image: registry.lingo.local/bitnami/etcd:3.5.17
    command: ["sleep"]
    args: ["infinity"]
    env:
      - name: ETCDCTL_CACERT
        value: "/etc/ssl/etcd/ca.pem"
      - name: ETCDCTL_KEY
        value: "/etc/ssl/etcd/etcd-client-key.pem"
      - name: ETCDCTL_CERT
        value: "/etc/ssl/etcd/etcd-client.pem"
    volumeMounts:
      - name: etcd-client-certs
        mountPath: /etc/ssl/etcd
        readOnly: true
  volumes:
    - name: etcd-client-certs
      secret:
        secretName: etcd-client-certs
EOF
```

进入容器

```
kubectl exec -n kongyu -it etcd-client -- bash
```

内部网络访问-headless

```
export ETCDCTL_ENDPOINTS="https://etcd-0.etcd-headless.kongyu.svc.cluster.local:2379,https://etcd-1.etcd-headless.kongyu.svc.cluster.local:2379,https://etcd-2.etcd-headless.kongyu.svc.cluster.local:2379"
etcdctl member list --write-out=table
```

内部网络访问

```
export ETCDCTL_ENDPOINTS="https://etcd.kongyu.svc.cluster.local:2379"
etcdctl member list --write-out=table
```

集群网络访问

> 使用集群+NodePort访问

```
export ETCDCTL_ENDPOINTS="https://192.168.1.10:42800"
etcdctl member list --write-out=table
```

读写数据

> 读写数据需要账号密码

```
etcdctl put foo "hello world"
etcdctl get foo
```

删除客户端

```
kubectl delete -n kongyu pod etcd-client
```

**删除服务以及数据**

```
helm uninstall -n kongyu etcd
kubectl delete -n kongyu pvc -l app.kubernetes.io/name=etcd
```

