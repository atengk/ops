# MinIO

MinIO 是一个高性能的对象存储系统，兼容 Amazon S3 API，专为存储海量非结构化数据而设计。它使用 Golang 编写，支持本地部署和云环境，适用于私有云、混合云和边缘计算等场景。MinIO 提供数据冗余、加密和高可用性，是构建数据湖、备份与恢复等解决方案的理想选择。

- [官网地址](https://min.io/)

**查看版本**

```
helm search repo bitnami/minio -l
```

**下载chart**

```
helm pull bitnami/minio --version 14.8.5
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 存储配置：persistence.size
- 认证配置：auth.rootUser auth.rootPassword
- 创建桶：defaultBuckets，填写了该配置会自动创建相关桶
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/minio="true"
```

**创建服务**

```
helm install minio -n kongyu -f values.yaml minio-14.8.5.tgz
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
     --image registry.lingo.local/bitnami/minio-client:2024.11.17 -- bash
```

内部网络访问

```
mc config host add minio http://minio.kongyu:9000 admin Admin@123 --api s3v4
mc admin info minio
```

集群网络访问

> 使用集群+NodePort访问，使用minio服务的9000对应的端口

```
mc config host add minio http://192.168.1.10:1972 admin Admin@123 --api s3v4
mc admin info minio
```

访问Web

> 使用集群+NodePort访问，使用minio服务的9001对应的端口

```
URL: http://192.168.1.19:19683/
Username: admin
Password: Admin@123
```

**删除服务以及数据**

```
helm uninstall -n kongyu minio
```

