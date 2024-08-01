# Zookeeper 3.8.0



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/zookeeper/data
chown -R 1001 /data/service/zookeeper
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-zookeeper --network kongyu \
    -p 20001:2181 --restart=always \
    -v /data/service/zookeeper/data:/bitnami/zookeeper \
    -e ALLOW_ANONYMOUS_LOGIN=yes \
    -e ZOO_HEAP_SIZE=2048 \
    -e ZOO_LOG_LEVEL=ERROR \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/zookeeper:3.8.0
docker logs -f kongyu-zookeeper
```

- 使用docker-compose的方式


```
cat > /data/service/zookeeper/docker-compose.yaml <<"EOF"
version: '3'

services:
  zookeeper:
    image: registry.lingo.local/service/zookeeper:3.8.0
    container_name: kongyu-zookeeper
    networks:
      - kongyu
    ports:
      - "20001:2181"
    restart: always
    volumes:
      - /data/service/zookeeper/data:/bitnami/zookeeper
    environment:
      - ALLOW_ANONYMOUS_LOGIN=yes
      - ZOO_HEAP_SIZE=1024
      - ZOO_LOG_LEVEL=ERROR
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/zookeeper/docker-compose.yaml up -d 
docker-compose -f /data/service/zookeeper/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
docker run -it --rm --network kongyu registry.lingo.local/service/zookeeper:3.8.0 zkCli.sh -server kongyu-zookeeper:2181
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-zookeeper
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/zookeeper/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/zookeeper
```

