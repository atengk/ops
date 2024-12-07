# Redis

Redis 是一个开源的内存数据库，支持多种数据结构，如字符串、哈希、列表、集合和有序集合等。它常用于缓存、会话管理和实时数据分析等场景，具有高性能和低延迟的特点。Redis 支持数据持久化，可以将内存中的数据保存到磁盘，重启后恢复数据。

[官方文档](https://redis.io/)

## 创建服务

**查看版本**

```
helm search repo bitnami/redis -l
```

**下载chart**

```
helm pull bitnami/redis --version 20.2.1
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
```

**创建服务**

```
helm install redis -n kongyu -f values.yaml redis-20.2.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=redis
```

**使用服务**

创建客户端容器

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- bash
```

内部网络访问-headless

```
redis-cli -h redis-master-0.redis-headless.kongyu info server
```

内部网络访问

```
redis-cli -h redis-master.kongyu info server
```

集群网络访问

> 使用集群+NodePort访问

```
redis-cli -h 192.168.1.10 -p 29129 info server
```

## 基于KubeSphere创建ServiceMonitor

### 查看pometheus的label

> 查看KubeSphere的Pometheus的标签，后续创建ServiceMonitor会用到

```shell
kubectl get prometheus -n kubesphere-monitoring-system k8s -o jsonpath="{.metadata.labels}"
```

> 例如，输出以下内容{"app.kubernetes.io/component":"prometheus","app.kubernetes.io/instance":"k8s","app.kubernetes.io/name":"prometheus","app.kubernetes.io/part-of":"kube-prometheus","app.kubernetes.io/version":"2.39.1"}

### 查看metrics的label

> 查看redis的svc的metrics的标签，后续创建ServiceMonitor会用到

```shell
kubectl get svc -n kongyu redis-metrics -o jsonpath="{.metadata.labels}"
```

> 例如，输出以下内容{"app.kubernetes.io/component":"metrics","app.kubernetes.io/instance":"redis","app.kubernetes.io/managed-by":"Helm","app.kubernetes.io/name":"redis","helm.sh/chart":"redis-16.13.2"}

### 创建ServiceMonitor

```shell
kubectl apply -f servicemonitor.yaml
```

### 查看Targets

> 登录prometheus的web，进入http://192.168.1.10:15082/targets，查看是否有创建的ServiceMonitor

```shell
kubectl get svc -n kubesphere-monitoring-system prometheus-k8s
```

## 删除服务以及数据

```
kubectl delete -f servicemonitor.yaml
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

# 
