# MySQL

MySQL 是一个流行的开源关系型数据库管理系统（RDBMS），广泛用于Web应用、企业系统和数据仓库等场景。它采用结构化查询语言（SQL）进行数据管理，支持多种存储引擎、事务处理和复杂查询操作。MySQL 以高性能、可靠性和易用性著称，同时具有强大的社区支持和广泛的第三方工具兼容性，适合各种规模的应用程序。

- [官网链接](https://www.mysql.com/)

**下载镜像**

```
docker pull bitnami/mysql:8.4.3
```

**推送到仓库**

```
docker tag bitnami/mysql:8.4.3 registry.lingo.local/bitnami/mysql:8.4.3
docker push registry.lingo.local/bitnami/mysql:8.4.3
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/mysql:8.4.3 | gzip -c > image-mysql_8.4.3.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/mysql/{data,config}
sudo chown -R 1001 /data/container/mysql
```

**创建配置文件**

```
sudo tee /data/container/mysql/config/my_custom.cnf <<"EOF"
[mysqld]
authentication_policy=caching_sha2_password
max_allowed_packet=100M
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
slow_query_log=1
slow_query_log_file=/bitnami/mysql/data/slow_query.log
long_query_time=10.0
default_time_zone = "+8:00"
lower_case_table_names = 0
max_connections = 1024
max_connect_errors = 1024
server-id=1
log-bin=mysql-bin
max_binlog_size=1024M
binlog_expire_logs_seconds=2592000
EOF
```

**运行服务**

```
docker run -d --name ateng-mysql \
  -p 20001:3306 --restart=always \
  -v /data/container/mysql/config/my_custom.cnf:/opt/bitnami/mysql/conf/my_custom.cnf:ro \
  -v /data/container/mysql/data:/bitnami/mysql/data \
  -e MYSQL_ROOT_USER=root \
  -e MYSQL_ROOT_PASSWORD=Admin@123 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/mysql:8.4.3
```

**查看日志**

```
docker logs -f ateng-mysql
```

**使用服务**

进入容器

```
docker exec -it ateng-mysql bash
```

访问服务

```
export MYSQL_PWD=Admin@123
mysql -h192.168.1.114 -P20001 -uroot
```

**删除服务**

停止服务

```
docker stop ateng-mysql
```

删除服务

```
docker rm ateng-mysql
```

删除目录

```
sudo rm -rf /data/container/mysql
```

