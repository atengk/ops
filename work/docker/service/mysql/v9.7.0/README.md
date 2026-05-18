# MySQL

MySQL 是一个流行的开源关系型数据库管理系统（RDBMS），广泛用于 Web 应用、企业系统和数据仓库等场景。它采用结构化查询语言（SQL）进行数据管理，支持多种存储引擎、事务处理和复杂查询操作。MySQL 以高性能、可靠性和易用性著称，同时具有强大的社区支持和广泛的第三方工具兼容性，适合各种规模的应用程序。

- 官网链接：MySQL 官方网站
- 镜像来源：Docker Official Image
- 当前版本：9.7.0

## 基础配置

官方镜像的数据目录为 `/var/lib/mysql`，自定义配置目录为 `/etc/mysql/conf.d`，初始化环境变量使用 `MYSQL_ROOT_PASSWORD`。

## 下载镜像

拉取 Docker 官方 MySQL 9.7.0 镜像。

```bash
docker pull mysql:9.7.0
```

## 推送到仓库

将官方镜像重新标记为本地私有仓库镜像。

```bash
docker tag mysql:9.7.0 registry.lingo.local/service/mysql:9.7.0
docker push registry.lingo.local/service/mysql:9.7.0
```

## 保存镜像

将私有仓库镜像保存为离线包，便于在离线环境中导入。

```bash
docker save registry.lingo.local/service/mysql:9.7.0 | gzip -c > image-mysql_9.7.0.tar.gz
```

## 创建目录

创建 MySQL 数据目录和配置目录。官方镜像中 `mysql` 用户的 UID/GID 为 `999:999`，这里提前设置目录权限，避免挂载目录后出现权限问题。

```bash
sudo mkdir -p /data/container/mysql/{data,config}
sudo chown -R 999:999 /data/container/mysql/data
sudo chown -R root:root /data/container/mysql/config
```

## 创建配置文件

创建 MySQL 自定义配置文件。官方镜像会读取 `/etc/mysql/conf.d` 目录下的 `.cnf` 配置文件。

```bash
sudo tee /data/container/mysql/config/my_custom.cnf <<"EOF"
[client]
default_character_set=utf8mb4

[mysql]
default_character_set=utf8mb4

[mysqld]
# 监听配置
port=3306
bind_address=0.0.0.0

# 认证配置
authentication_policy=caching_sha2_password

# 连接配置
max_connections=1024
max_connect_errors=1024
connect_timeout=10
wait_timeout=28800
interactive_timeout=28800
max_allowed_packet=100M

# 字符集配置
character_set_server=utf8mb4
collation_server=utf8mb4_0900_ai_ci

# 时区配置
default_time_zone='+08:00'
log_timestamps=SYSTEM

# SQL 模式
sql_mode=ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION

# 表名大小写配置，数据目录初始化后不建议修改
lower_case_table_names=0

# 存储引擎配置
default_storage_engine=InnoDB
transaction_isolation=REPEATABLE-READ
innodb_file_per_table=ON
innodb_flush_log_at_trx_commit=1

# 安全配置
local_infile=OFF
secure_file_priv=/var/lib/mysql-files

# 慢查询日志
slow_query_log=ON
slow_query_log_file=/var/lib/mysql/slow_query.log
long_query_time=10

# 错误日志
log_error_verbosity=2

# Binlog 配置
server_id=1
log_bin=mysql-bin
binlog_format=ROW
binlog_row_image=FULL
sync_binlog=1
max_binlog_size=1G
binlog_expire_logs_seconds=2592000
EOF
```

## 运行服务

启动 MySQL 容器。官方镜像不支持 Bitnami 的 `MYSQL_ROOT_USER`，root 用户默认创建，只需要通过 `MYSQL_ROOT_PASSWORD` 设置 root 密码。

```bash
docker run -d --name ateng-mysql \
  -p 20001:3306 \
  --restart=always \
  -v /data/container/mysql/config/my_custom.cnf:/etc/mysql/conf.d/my_custom.cnf:ro \
  -v /data/container/mysql/data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=Admin@123 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/mysql:9.7.0
```

## 查看日志

查看容器启动日志，首次启动会初始化数据库，耗时会比后续启动更长。

```bash
docker logs -f ateng-mysql
```

## 使用服务

进入容器。

```bash
docker exec -it ateng-mysql bash
```

在容器内访问 MySQL。

```bash
export MYSQL_PWD=Admin@123
mysql -uroot
```

从宿主机或其他机器访问 MySQL。

```bash
export MYSQL_PWD=Admin@123
mysql -h192.168.1.114 -P20001 -uroot
```

## 验证服务

查看 MySQL 版本。

```bash
docker exec -it ateng-mysql mysql -uroot -pAdmin@123 -e "SELECT VERSION();"
```

查看数据库基础配置。

```bash
docker exec -it ateng-mysql mysql -uroot -pAdmin@123 -e "SHOW VARIABLES LIKE 'character_set_server';"
docker exec -it ateng-mysql mysql -uroot -pAdmin@123 -e "SHOW VARIABLES LIKE 'collation_server';"
docker exec -it ateng-mysql mysql -uroot -pAdmin@123 -e "SHOW VARIABLES LIKE 'lower_case_table_names';"
```

查看 Binlog 是否开启。

```bash
docker exec -it ateng-mysql mysql -uroot -pAdmin@123 -e "SHOW VARIABLES LIKE 'log_bin';"
```

## 删除服务

停止服务。

```bash
docker stop ateng-mysql
```

删除服务。

```bash
docker rm ateng-mysql
```

删除目录。该操作会删除 MySQL 数据，请谨慎执行。

```bash
sudo rm -rf /data/container/mysql
```

