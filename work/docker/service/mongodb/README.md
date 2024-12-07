# MongoDB

MongoDB 是一种基于文档的 NoSQL 数据库，以高性能、易扩展和灵活的文档存储而著称。它由 C++ 语言编写，于 2009 年首次发布。与传统的关系型数据库（如 MySQL、PostgreSQL）不同，MongoDB 采用非结构化的数据存储方式，不使用表和行，而是通过集合（Collection）和文档（Document）来组织数据。

- [官网链接](https://www.mongodb.com/zh-cn/)

**下载镜像**

```
docker pull bitnami/mongodb:8.0.3
```

**推送到仓库**

```
docker tag bitnami/mongodb:8.0.3 registry.lingo.local/bitnami/mongodb:8.0.3
docker push registry.lingo.local/bitnami/mongodb:8.0.3
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/mongodb:8.0.3 | gzip -c > image-mongodb_8.0.3.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/mongodb/data
sudo chown -R 1001 /data/container/mongodb
```

**运行服务**

```
docker run -d --name ateng-mongodb \
  -p 20008:27017 --restart=always \
  -v /data/container/mongodb/data:/bitnami/mongodb \
  -e MONGODB_ROOT_USER=root \
  -e MONGODB_ROOT_PASSWORD=Admin@123 \
  -e MONGODB_EXTRA_USERNAMES="kongyu01,kongyu02" \
  -e MONGODB_EXTRA_DATABASES="kongyu01,kongyu02" \
  -e MONGODB_EXTRA_PASSWORDS="kongyu01,kongyu02" \
  -e MONGODB_EXTRA_FLAGS='--wiredTigerCacheSizeGB=2' \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/mongodb:8.0.3
```

**查看日志**

```
docker logs -f ateng-mongodb
```

**使用服务**

进入容器

```
docker exec -it ateng-mongodb bash
```

访问服务

```
mongosh --host 192.168.1.114:20008 --username root --password Admin@123 --authenticationDatabase admin --eval "db.serverStatus().connections"
```

**删除服务**

停止服务

```
docker stop ateng-mongodb
```

删除服务

```
docker rm ateng-mongodb
```

删除目录

```
sudo rm -rf /data/container/mongodb
```

