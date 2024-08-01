# 创建ETCD集群

查看版本

```
helm search repo bitnami/etcd -l
```

下载chart

```
helm pull bitnami/etcd --version 8.7.2
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```
helm install etcd -n kongyu -f values-etcd.yaml etcd-8.7.2.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/name=etcd
kubectl logs -f -n kongyu etcd-0
```

访问服务

```
etcdctl member list --write-out=table --endpoints=http://192.168.1.19:49609/
```

删除服务以及数据

```
helm uninstall -n kongyu etcd
kubectl delete -n kongyu pvc -l app.kubernetes.io/name=etcd
```

