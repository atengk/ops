# Seata

Seata 是一款开源的分布式事务解决方案，致力于提供高性能和简单易用的分布式事务服务。Seata 将为用户提供了 AT、TCC、SAGA 和 XA 事务模式，为用户打造一站式的分布式解决方案。



**下载SQL**

```
https://raw.githubusercontent.com/apache/incubator-seata/v2.0.0/script/server/db/mysql.sql
```

**下载镜像**

```
docker pull seataio/seata-server:2.0.0
```

**创建**

> 开发环境下使用**seata-server-dev.yaml**，因为Seata服务注册到nacos后是容器的IP地址后端口，在开发环境下就无法访问这个地址，就需要改一下8091端口的地址，这里改成38091

```
kubectl apply -n kongyu -f seata-server.yaml
```

**查看**

```
kubectl get -n kongyu pod,svc
```

