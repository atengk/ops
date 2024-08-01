# MySQL 8.0.34



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录和配置文件

```
mkdir -p /data/service/mysql/{data,config}
chown -R 1001 /data/service/mysql
cat > /data/service/mysql/config/my_custom.cnf <<"EOF"
[mysqld]
max_allowed_packet=1G
default_time_zone = "+8:00"
lower_case_table_names = 1
max_connections = 10240
max_connect_errors = 1024
server-id=1
log-bin=mysql-bin
max_binlog_size=1G
binlog_expire_logs_seconds=604800
EOF
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-mysql --network kongyu \
  -p 20001:3306 --restart=always \
  -v /data/service/mysql/config/my_custom.cnf:/opt/bitnami/mysql/conf/my_custom.cnf:ro \
  -v /data/service/mysql/data:/bitnami/mysql/data \
  -e MYSQL_ROOT_USER=root \
  -e MYSQL_ROOT_PASSWORD=Admin@123 \
  -e MYSQL_AUTHENTICATION_PLUGIN=caching_sha2_password \
  -e MYSQL_CHARACTER_SET=utf8mb4 \
  -e MYSQL_COLLATE=utf8mb4_general_ci \
  -e MYSQL_ENABLE_SLOW_QUERY=1 \
  -e MYSQL_LONG_QUERY_TIME=10 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/mysql:8.0.34
docker logs -f kongyu-mysql
```

- 使用docker-compose的方式


```
cat > /data/service/mysql/docker-compose.yaml <<"EOF"
version: '3'

services:
  mysql:
    image: registry.lingo.local/service/mysql:8.0.34
    container_name: kongyu-mysql
    networks:
      - kongyu
    ports:
      - "20001:3306"
    restart: always
    volumes:
      - /data/service/mysql/config/my_custom.cnf:/opt/bitnami/mysql/conf/my_custom.cnf:ro
      - /data/service/mysql/data:/bitnami/mysql/data
    environment:
      - MYSQL_ROOT_USER=root
      - MYSQL_ROOT_PASSWORD=Admin@123
      - MYSQL_AUTHENTICATION_PLUGIN=caching_sha2_password
      - MYSQL_CHARACTER_SET=utf8mb4
      - MYSQL_COLLATE=utf8mb4_general_ci
      - MYSQL_ENABLE_SLOW_QUERY=1
      - MYSQL_LONG_QUERY_TIME=10
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF
docker-compose -f /data/service/mysql/docker-compose.yaml up -d 
docker-compose -f /data/service/mysql/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
docker run -it --rm --network kongyu registry.lingo.local/service/mysql:8.0.34 mysql -hkongyu-mysql -uroot -pAdmin@123 -e status
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-mysql
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/mysql/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/mysql
```

