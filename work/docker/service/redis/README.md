# Redis 6.2.14



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录和配置文件

```
mkdir -p /data/service/redis/{data,config}
chown -R 1001 /data/service/redis
cat > /data/service/redis/config/my_custom.cnf <<"EOF"
databases 256
appendfsync always
save ""
maxclients 10000
maxmemory 50GB
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
maxmemory-policy volatile-lru
EOF
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-redis --network kongyu \
    -p 20001:6379 --restart=always \
    -v /data/service/redis/config/my_custom.cnf:/opt/bitnami/redis/mounted-etc/overrides.conf \
    -v /data/service/redis/data:/bitnami/redis/data \
    -e REDIS_PASSWORD=Admin@123 \
    -e REDIS_IO_THREADS=10 \
    -e REDIS_IO_THREADS_DO_READS=yes \
    -e REDIS_AOF_ENABLED=yes \
    -e REDIS_DISABLE_COMMANDS=FLUSHDB,FLUSHALL,CONFIG \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/redis:6.2.14
docker logs -f kongyu-redis
```

- 使用docker-compose的方式


```
cat > /data/service/redis/docker-compose.yaml <<"EOF"
version: '3'

services:
  redis:
    image: registry.lingo.local/service/redis:6.2.14
    container_name: kongyu-redis
    networks:
      - kongyu
    ports:
      - "20001:6379"
    restart: always
    volumes:
      - /data/service/redis/config/my_custom.cnf:/opt/bitnami/redis/mounted-etc/overrides.conf
      - /data/service/redis/data:/bitnami/redis/data
    environment:
      - REDIS_PASSWORD=Admin@123
      - REDIS_IO_THREADS=10
      - REDIS_IO_THREADS_DO_READS=yes
      - REDIS_AOF_ENABLED=yes
      - REDIS_DISABLE_COMMANDS=FLUSHDB,FLUSHALL,CONFIG
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/redis/docker-compose.yaml up -d
docker-compose -f /data/service/redis/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
docker run -it --rm --network kongyu -e REDISCLI_AUTH=Admin@123 registry.lingo.local/service/redis:6.2.14 redis-cli -h kongyu-redis info
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-redis
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/redis/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/redis
```

