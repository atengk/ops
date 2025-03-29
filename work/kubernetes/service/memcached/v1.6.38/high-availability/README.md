# Memcached

Memcached 是一种高性能、分布式的内存对象缓存系统，主要用于加速动态 Web 应用程序，减少数据库负载。它采用键值存储（Key-Value Store）方式，将常用数据缓存在内存中，实现快速访问。Memcached 具有轻量级、高并发、易扩展的特点，广泛应用于社交网络、电商、内容分发等场景。其简单的 API 使开发者能够快速集成，提高系统响应速度和可扩展性。

- [官网地址](https://memcached.org/)



**查看版本**

```
helm search repo bitnami/memcached -l
```

**下载chart**

```
helm pull bitnami/memcached --version 7.7.1
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/memcached="true"
```

**创建服务**

```
helm install memcached -n kongyu -f values.yaml memcached-7.7.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=memcached
kubectl logs -f -n kongyu memcached-0
```

**连接服务**

```
telnet 192.168.1.10 26292
```

**存储数据**

格式：

```
set <key> <flags> <exptime> <bytes>
<data>
```

示例：

```
set mykey 0 60 11
Hello World
```

**读取数据**

```
get mykey
```

quit退出

**删除服务以及数据**

```
helm uninstall -n kongyu memcached
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=memcached
```

