# Valkey

**Valkey** 是一个基于 Redis 7.2.4 的完全开源分支，采用 BSD 许可证，旨在为那些不希望受 Redis 新许可政策限制的开发者提供替代方案。它继续保持 Redis 的高性能和功能，同时避免了云服务商商业化使用的限制。Valkey 由 Linux 基金会支持，适用于各种云平台和自托管环境。

- [官方文档](https://valkey.io/)

**查看版本**

```
helm search repo bitnami/valkey -l
```

**下载chart**

```
helm pull bitnami/valkey --version 2.4.7
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/valkey="true"
```

**创建服务**

```
helm install valkey -n kongyu -f values.yaml valkey-2.4.7.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=valkey
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=valkey
```

**使用服务**

创建客户端容器

```
kubectl run valkey-client --rm --tty -i --restart='Never' --image  registry.lingo.local/bitnami/valkey:8.0.2 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- bash
```

内部网络访问-headless

```
valkey-cli -h valkey-primary-0.valkey-headless.kongyu info server
```

内部网络访问

```
valkey-cli -h valkey-primary.kongyu info server
```

集群网络访问

> 使用集群+NodePort访问

```
valkey-cli -h 192.168.1.10 -p 29129 info server
```

**删除服务以及数据**

```
helm uninstall -n kongyu valkey
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=valkey
```

