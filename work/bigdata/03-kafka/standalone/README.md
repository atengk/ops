# Kafka3

Kafka with KRaft 引入了一种新的分布式协调协议，称为 KRaft，以替代传统的 ZooKeeper。KRaft 提供了更简化的架构，将 Kafka 的元数据存储在一组专用的 Kafka brokers 中，而不是依赖外部的 ZooKeeper 集群。

- [官网链接](https://kafka.apache.org/)



文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述  |
| ------------- | --------- | ----- |
| 192.168.1.109 | bigdata01 | Kafka |



## 基础配置

### 安装服务

**下载软件包**

```
wget https://dlcdn.apache.org/kafka/3.8.1/kafka_2.13-3.8.1.tgz
```

**解压软件包**

```
tar -zxvf kafka_2.13-3.8.1.tgz -C /usr/local/software/
ln -s /usr/local/software/kafka_2.13-3.8.1 /usr/local/software/kafka
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## KAFKA_HOME
export KAFKA_HOME=/usr/local/software/kafka
export PATH=$PATH:$KAFKA_HOME/bin
EOF
source ~/.bash_profile
```



## 集群配置

**配置server.properties**

注意修改以下配置：

- controller.quorum.voters：Controller 集群成员
- listeners：定义 Kafka 服务监听的地址和端口
- advertised.listeners：定义对外通告的监听地址，通告地址会被客户端和其他 Broker 用来连接到此节点
- 其他配置安装实际需求修改

```
cp $KAFKA_HOME/config/kraft/server.properties{,_bak}
cat > $KAFKA_HOME/config/kraft/server.properties <<"EOF"
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@bigdata01:9093
inter.broker.listener.name=INTERNAL
controller.listener.names=CONTROLLER
listeners=CLIENT://:9092,CONTROLLER://:9093,INTERNAL://:9094,EXTERNAL://:9095
advertised.listeners=CLIENT://bigdata01:9092,INTERNAL://bigdata01:9094,EXTERNAL://14.104.200.4:19092
listener.security.protocol.map=CLIENT:PLAINTEXT,INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT
log.dir=/data/service/kafka/data/server
num.io.threads=8
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

**生成集群 UUID**

```
KAFKA_CLUSTER_ID="$(kafka-storage.sh random-uuid)"
```

**设置日志目录格式**

```
kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c $KAFKA_HOME/config/kraft/server.properties
```



## 启动集群

**启动服务**

bigdata01: Kafka Controller、Kafka Broker

Controller Address: bigdata01:9093

Broker Client Address: bigdata01:9092

Broker Internal Address: bigdata01:9094

Broker External Address: 14.104.200.4:19092

```
export LOG_DIR=/data/service/kafka/logs
export KAFKA_HEAP_OPTS="-Xms1g -Xmx2g"
export JAVA_HOME=/usr/local/software/jdk8
kafka-server-start.sh -daemon $KAFKA_HOME/config/kraft/server.properties
```

**关闭服务**

```
kafka-server-stop.sh
```



## 设置服务自启

### Kafka 服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/kafka.service <<"EOF"
[Unit]
Description=Kafka
Documentation=https://kafka.apache.org
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/kafka
Environment="JAVA_HOME=/usr/local/software/jdk8"
Environment="KAFKA_HOME=/usr/local/software/kafka"
Environment="LOG_DIR=/data/service/kafka/logs"
Environment="KAFKA_HEAP_OPTS=-Xms1g -Xmx2g"
ExecStart=/usr/local/software/kafka/bin/kafka-server-start.sh /usr/local/software/kafka/config/kraft/server.properties
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable kafka.service
sudo systemctl start kafka.service
sudo systemctl status kafka.service
```



## 使用服务

**创建topic**

```
kafka-topics.sh --create --topic quickstart-events --bootstrap-server bigdata01:9092
```

**查看topic**

```
kafka-topics.sh --describe --topic quickstart-events --bootstrap-server bigdata01:9092
```

**写入消息**

```
$ kafka-console-producer.sh --topic quickstart-events --bootstrap-server bigdata01:9092
This is my first event
This is my second event
```

**读取消息**

```
$ kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server bigdata01:9092
This is my first event
This is my second event
```

