# Redis

Redis 是一个开源的内存数据库，支持多种数据结构，如字符串、哈希、列表、集合和有序集合等。它常用于缓存、会话管理和实时数据分析等场景，具有高性能和低延迟的特点。Redis 支持数据持久化，可以将内存中的数据保存到磁盘，重启后恢复数据。

- [官方文档](https://redis.io/)

**下载镜像**

```
docker pull bitnami/redis:7.4.1
```

**推送到仓库**

```
docker tag bitnami/redis:7.4.1 registry.lingo.local/bitnami/redis:7.4.1
docker push registry.lingo.local/bitnami/redis:7.4.1
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/redis:7.4.1 | gzip -c > image-redis_7.4.1.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/redis/{data,config}
sudo chown -R 1001 /data/container/redis
```

**创建配置文件**

```
sudo tee /data/container/redis/config/override.conf <<"EOF"
databases 20
appendonly yes
appendfsync always
save ""
maxclients 1024
maxmemory 8GB
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
maxmemory-policy volatile-lru
io-threads 10
io-threads-do-reads yes
EOF
```

**运行服务**

```
docker run -d --name ateng-redis \
  -p 20003:6379 --restart=always \
  -v /data/container/redis/config/override.conf:/opt/bitnami/redis/mounted-etc/overrides.conf:ro \
  -v /data/container/redis/data:/bitnami/redis/data \
  -e REDIS_PASSWORD=Admin@123 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/redis:7.4.1
```

**查看日志**

```
docker logs -f ateng-redis
```

**使用服务**

进入容器

```
docker exec -it ateng-redis bash
```

访问服务

```
export REDISCLI_AUTH=Admin@123
redis-cli -h 172.16.0.149 -p 20003 info server
```

**删除服务**

停止服务

```
docker stop ateng-redis
```

删除服务

```
docker rm ateng-redis
```

删除目录

```
sudo rm -rf /data/container/redis
```

