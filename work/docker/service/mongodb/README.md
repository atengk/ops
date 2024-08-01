# MongoDB 6.0.2



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/mongodb/data
chown -R 1001 /data/service/mongodb
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-mongodb --network kongyu \
    -p 20001:27017 --restart=always \
    -v /data/service/mongodb/data:/bitnami/mongodb \
    -e MONGODB_ROOT_USER=root \
    -e MONGODB_ROOT_PASSWORD=Admin@123 \
    -e MONGODB_USERNAME=kongyu \
    -e MONGODB_PASSWORD=kongyu \
    -e MONGODB_DATABASE=kongyu \
    -e MONGODB_DISABLE_SYSTEM_LOG=true \
    -e MONGODB_SYSTEM_LOG_VERBOSITY='0' \
    -e MONGODB_ENABLE_JOURNAL=false \
    -e MONGODB_EXTRA_FLAGS='--wiredTigerCacheSizeGB=2' \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/mongodb:6.0.2
docker logs -f kongyu-mongodb
```

- 使用docker-compose的方式


```
cat > /data/service/mongodb/docker-compose.yaml <<"EOF"
version: '3'

services:
  mongodb:
    image: registry.lingo.local/service/mongodb:6.0.2
    container_name: kongyu-mongodb
    networks:
      - kongyu
    ports:
      - "20001:27017"
    restart: always
    volumes:
      - /data/service/mongodb/data:/bitnami/mongodb
    environment:
      - MONGODB_ROOT_USER=root
      - MONGODB_ROOT_PASSWORD=Admin@123
      - MONGODB_USERNAME=kongyu
      - MONGODB_PASSWORD=kongyu
      - MONGODB_DATABASE=kongyu
      - MONGODB_DISABLE_SYSTEM_LOG=true
      - MONGODB_SYSTEM_LOG_VERBOSITY=0
      - MONGODB_ENABLE_JOURNAL=false
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/mongodb/docker-compose.yaml up -d 
docker-compose -f /data/service/mongodb/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
docker run -it --rm --network kongyu registry.lingo.local/service/mongodb:6.0.2 mongosh --host kongyu-mongodb --username root --password Admin@123 --authenticationDatabase admin --eval "show databases"
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-mongodb
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/mongodb/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/mongodb
```

