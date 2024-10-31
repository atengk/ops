# MinIO

MinIO 是一个高性能的对象存储系统，兼容 Amazon S3 API，专为存储海量非结构化数据而设计。它使用 Golang 编写，支持本地部署和云环境，适用于私有云、混合云和边缘计算等场景。MinIO 提供数据冗余、加密和高可用性，是构建数据湖、备份与恢复等解决方案的理想选择。

MinIO 的官网地址是：[https://min.io/](https://min.io/)

**查看版本**

```
helm search repo bitnami/minio -l
```

**下载chart**

```
helm pull bitnami/minio --version 14.8.0
```

**修改配置**

根据环境做出相应的修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/minio="true"
```

**创建服务**

```
helm install minio -n kongyu -f values.yaml minio-14.8.0.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=minio
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=minio
```

**使用服务**

创建客户端容器

```
kubectl run --namespace kongyu minio-client \
     --rm --tty -i --restart='Never' \
     --image registry.lingo.local/service/minio-client:2024.10.8 -- bash
```

内部网络访问

```
mc config host add minio http://minio.kongyu:9000 admin Admin@123 --api s3v4
mc admin info minio
```

集群网络访问

> 使用集群+NodePort访问，使用minio服务的9000对应的端口

```
mc config host add minio http://192.168.1.10:25607 admin Admin@123 --api s3v4
mc admin info minio
```

访问Web

> 使用集群+NodePort访问，使用minio服务的9001对应的端口

```
URL: http://192.168.1.19:24879/
Username: admin
Password: Admin@123
```

**删除服务以及数据**

```
helm uninstall -n kongyu minio
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=minio
```



