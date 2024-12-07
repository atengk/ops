# MinIO

MinIO 是一个高性能的对象存储系统，兼容 Amazon S3 API，专为存储海量非结构化数据而设计。它使用 Golang 编写，支持本地部署和云环境，适用于私有云、混合云和边缘计算等场景。MinIO 提供数据冗余、加密和高可用性，是构建数据湖、备份与恢复等解决方案的理想选择。

- [官网地址](https://min.io/)

**下载镜像**

```
docker pull bitnami/minio:2024.11.7
```

**推送到仓库**

```
docker tag bitnami/minio:2024.11.7 registry.lingo.local/bitnami/minio:2024.11.7
docker push registry.lingo.local/bitnami/minio:2024.11.7
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/minio:2024.11.7 | gzip -c > image-minio_2024.11.7.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/minio/data
sudo chown -R 1001 /data/container/minio
```

**运行服务**

```
docker run -d --name ateng-minio \
  -p 20006:9000 -p 20007:9001 --restart=always \
  -v /data/container/minio:/bitnami/minio/data \
  -e MINIO_ROOT_USER=admin \
  -e MINIO_ROOT_PASSWORD=Admin@123 \
  -e MINIO_DEFAULT_BUCKETS="bucket01:public,bucket02" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/minio:2024.11.7
```

**查看日志**

```
docker logs -f ateng-minio
```

**使用服务**

```
API URL: http://192.168.1.114:20006
Web URL: http://192.168.1.114:20007
Username: admin
Password: Admin@123
```

**删除服务**

停止服务

```
docker stop ateng-minio
```

删除服务

```
docker rm ateng-minio
```

删除目录

```
sudo rm -rf /data/container/minio
```

