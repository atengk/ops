# Kafka UI



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-kafka-ui --network kongyu \
    -p 20003:8080 --restart=always \
    -e KAFKA_CLUSTERS_0_NAME=local-kafka \
    -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kongyu-kafka:9092 \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/kafka-ui:latest
docker logs -f kongyu-kafka-ui
```

- 使用docker-compose的方式


```
mkdir -p /data/service/kafka-ui
cat > /data/service/kafka-ui/docker-compose.yaml <<"EOF"
version: '3'

services:
  kafka-ui:
    image: registry.lingo.local/service/kafka-ui:latest
    container_name: kongyu-kafka-ui
    networks:
      - kongyu
    ports:
      - "20003:8080"
    restart: always
    environment:
      - KAFKA_CLUSTERS_0_NAME=local-kafka
      - KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kongyu-kafka:9092
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/kafka-ui/docker-compose.yaml up -d 
docker-compose -f /data/service/kafka-ui/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
http://192.168.1.101:20003/
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-kafka-ui
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/kafka-ui/docker-compose.yaml down
```

