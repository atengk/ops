# Kafka 3.3.1



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/kafka/data
chown -R 1001 /data/service/kafka
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-kafka --network kongyu \
    -p 20002:9094 --restart=always \
    -v /data/service/kafka/data:/bitnami/kafka \
    -e ALLOW_ANONYMOUS_LOGIN=yes \
    -e KAFKA_HEAP_OPTS="-Xmx4g -Xms2g" \
    -e KAFKA_CFG_ZOOKEEPER_CONNECT=kongyu-zookeeper:2181 \
    -e ALLOW_PLAINTEXT_LISTENER=yes \
    -e KAFKA_ZOOKEEPER_PROTOCOL=PLAINTEXT \
    -e KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL \
    -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP="INTERNAL:PLAINTEXT,CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT" \
    -e KAFKA_CFG_LISTENERS="INTERNAL://:9093,CLIENT://:9092,EXTERNAL://:9094" \
    -e KAFKA_CFG_ADVERTISED_LISTENERS="INTERNAL://:9093,CLIENT://:9092,EXTERNAL://:9094" \
    -e KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true \
    -e KAFKA_CFG_DELETE_TOPIC_ENABLE=true \
    -e KAFKA_CFG_LOG_RETENTION_BYTES=1073741824 \
    -e KAFKA_CFG_LOG_RETENTION_HOURS=36 \
    -e KAFKA_CFG_MESSAGE_MAX_BYTES=104857600 \
    -e KAFKA_CFG_LOG_SEGMENT_BYTES=1073741824 \
    -e KAFKA_CFG_SOCKET_REQUEST_MAX_BYTES=104857600 \
    -e KAFKA_CFG_MAX_REQUEST_SIZE=104857600 \
    -e KAFKA_CFG_MAX_PARTITION_FETCH_BYTES=104857600 \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/kafka:3.3.1
docker logs -f kongyu-kafka
```

- 使用docker-compose的方式


```
cat > /data/service/kafka/docker-compose.yaml <<"EOF"
version: '3'

services:
  kafka:
    image: registry.lingo.local/service/kafka:3.3.1
    container_name: kongyu-kafka
    depends_on:
      - kongyu-zookeeper
    networks:
      - kongyu
    ports:
      - "20002:9094"
    restart: always
    volumes:
      - /data/service/kafka/data:/bitnami/kafka
    environment:
      - ALLOW_ANONYMOUS_LOGIN=yes
      - KAFKA_HEAP_OPTS=-Xmx4g -Xms2g
      - KAFKA_CFG_ZOOKEEPER_CONNECT=kongyu-zookeeper:2181
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_ZOOKEEPER_PROTOCOL=PLAINTEXT
      - KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:PLAINTEXT,CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT
      - KAFKA_CFG_LISTENERS=INTERNAL://:9093,CLIENT://:9092,EXTERNAL://:9094
      - KAFKA_CFG_ADVERTISED_LISTENERS=INTERNAL://:9093,CLIENT://:9092,EXTERNAL://:9094
      - KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true
      - KAFKA_CFG_DELETE_TOPIC_ENABLE=true
      - KAFKA_CFG_LOG_RETENTION_BYTES=1073741824
      - KAFKA_CFG_LOG_RETENTION_HOURS=36
      - KAFKA_CFG_MESSAGE_MAX_BYTES=104857600
      - KAFKA_CFG_LOG_SEGMENT_BYTES=1073741824
      - KAFKA_CFG_SOCKET_REQUEST_MAX_BYTES=104857600
      - KAFKA_CFG_MAX_REQUEST_SIZE=104857600
      - KAFKA_CFG_MAX_PARTITION_FETCH_BYTES=104857600
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/kafka/docker-compose.yaml up -d 
docker-compose -f /data/service/kafka/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
docker run -it --rm --network kongyu registry.lingo.local/service/kafka:3.3.1 bash
```

内部访问

```
kafka-console-producer.sh --broker-list kongyu-kafka:9092 --topic test
kafka-console-consumer.sh --bootstrap-server kongyu-kafka:9092 --topic test --from-beginning
```

外部访问

```
kafka-console-producer.sh --broker-list 192.168.1.101:20002 --topic test
kafka-console-consumer.sh --bootstrap-server 192.168.1.101:20002 --topic test --from-beginning
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-kafka
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/kafka/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/kafka
```

