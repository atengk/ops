# PostgreSQL

PostgreSQL 是一个功能强大的开源关系型数据库，支持标准 SQL 和面向对象特性，具备高扩展性、数据完整性和并发控制能力。通过 PostGIS 扩展，它还能处理地理空间数据，适用于企业级应用、数据分析和地理信息系统（GIS）等多种场景。

- [官网链接](https://www.postgresql.org/)

**下载镜像**

```
docker pull bitnami/postgresql:17.2.0
```

**推送到仓库**

```
docker tag bitnami/postgresql:17.2.0 registry.lingo.local/bitnami/postgresql:17.2.0
docker push registry.lingo.local/bitnami/postgresql:17.2.0
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/postgresql:17.2.0 | gzip -c > image-postgresql_17.2.0.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/postgresql/{data,config}
sudo chown -R 1001 /data/container/postgresql
```

**创建配置文件**

```
sudo tee /data/container/postgresql/config/override.conf <<"EOF"
max_connections = 1024
shared_buffers = 4GB
work_mem = 64MB
max_parallel_workers_per_gather = 4
max_parallel_maintenance_workers = 2
max_parallel_workers = 8
wal_level = logical
log_timezone = Asia/Shanghai
timezone = Asia/Shanghai
EOF
```

**运行服务**

```
docker run -d --name ateng-postgresql \
  -p 20002:5432 --restart=always \
  -v /data/container/postgresql/config/override.conf:/opt/bitnami/postgresql/conf/conf.d/override.conf:ro \
  -v /data/container/postgresql/data:/bitnami/postgresql \
  -e POSTGRESQL_POSTGRES_PASSWORD=Admin@123 \
  -e POSTGRESQL_USERNAME=kongyu \
  -e POSTGRESQL_PASSWORD=kongyu \
  -e POSTGRESQL_DATABASE=kongyu \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/postgresql:17.2.0
```

**查看日志**

```
docker logs -f ateng-postgresql
```

**使用服务**

进入容器

```
docker exec -it ateng-postgresql bash
```

访问服务

```
export PGPASSWORD=Admin@123
psql --host 172.16.0.149 -U postgres -d kongyu -p 20002 -c "\l"
```

**删除服务**

停止服务

```
docker stop ateng-postgresql
```

删除服务

```
docker rm ateng-postgresql
```

删除目录

```
sudo rm -rf /data/container/postgresql
```

