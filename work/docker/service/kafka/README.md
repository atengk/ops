# Kafka

Kafka是一个开源的分布式流处理平台，主要用于处理实时数据流。它可以高效地发布和订阅消息，存储数据流，并处理这些数据。Kafka通常用于构建数据管道和流应用，能够保证高吞吐量、低延迟和高可扩展性。

- [官网链接](https://kafka.apache.org/)

**下载镜像**

```
docker pull bitnami/kafka:3.8.1
```

**推送到仓库**

```
docker tag bitnami/kafka:3.8.1 registry.lingo.local/bitnami/kafka:3.8.1
docker push registry.lingo.local/bitnami/kafka:3.8.1
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/kafka:3.8.1 | gzip -c > image-kafka_3.8.1.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/kafka/{data,config}
sudo chown -R 1001 /data/container/kafka
```

**创建配置文件**

注意advertised.listeners的EXTERNAL的值需要和最终外部访问的地址一致

```
sudo tee /data/container/kafka/config/server.properties <<"EOF"
listeners=CLIENT://:9092,INTERNAL://:9094,EXTERNAL://:9095,CONTROLLER://:9093
advertised.listeners=CLIENT://:9092,INTERNAL://:9094,EXTERNAL://192.168.1.114:20004
listener.security.protocol.map=CLIENT:PLAINTEXT,INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT
node.id=0
process.roles=controller,broker
controller.listener.names=CONTROLLER
controller.quorum.voters=0@localhost:9093
log.dir=/bitnami/kafka/data
logs.dir=/opt/bitnami/kafka/logs
inter.broker.listener.name=INTERNAL
num.io.threads=3
num.network.threads=3
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
default.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
auto.create.topics.enable=true
delete.topic.enable=true
log.retention.hours=8
log.retention.bytes=1073741824
log.retention.check.interval.ms=300000
log.segment.bytes=1073741824
max.partition.fetch.bytes=104857600
max.request.size=104857600
message.max.bytes=104857600
fetch.max.bytes=104857600
replica.fetch.max.bytes=104857600
EOF
```

**运行服务**

```
docker run -d --name ateng-kafka \
  -p 20004:9095 --restart=always \
  -v /data/container/kafka/config/server.properties:/opt/bitnami/kafka/config/server.properties:ro \
  -v /data/container/kafka/data:/bitnami/kafka \
  -e KAFKA_ENABLE_KRAFT=true \
  -e KAFKA_KRAFT_CLUSTER_ID=WQxMl2IwSEOq3qDG66N4VQ \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/kafka:3.8.1
```

**查看日志**

```
docker logs -f ateng-kafka
```

**使用服务**

进入容器

```
docker exec -it ateng-kafka bash
```

生产消息

```
kafka-console-producer.sh --broker-list 192.168.1.114:20004 --topic test
```

消费消息

```
kafka-console-consumer.sh --bootstrap-server 192.168.1.114:20004 --topic test --from-beginning
```

**删除服务**

停止服务

```
docker stop ateng-kafka
```

删除服务

```
docker rm ateng-kafka
```

删除目录

```
sudo rm -rf /data/container/kafka
```

