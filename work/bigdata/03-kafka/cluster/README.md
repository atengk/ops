# 安装Kafka3

> Kafka with KRaft 引入了一种新的分布式协调协议，称为 KRaft，以替代传统的 ZooKeeper。KRaft 提供了更简化的架构，将 Kafka 的元数据存储在一组专用的 Kafka brokers 中，而不是依赖外部的 ZooKeeper 集群。
>
> https://kafka.apache.org/

文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                |
| ------------- | --------- | ------------------- |
| 192.168.1.131 | bigdata01 | Controller & Broker |
| 192.168.1.132 | bigdata02 | Controller & Broker |
| 192.168.1.133 | bigdata03 | Controller & Broker |



## 基础环境配置

解压软件包

```
tar -zxvf kafka_2.13-3.6.1.tgz -C /usr/local/software/
ln -s /usr/local/software/kafka_2.13-3.6.1 /usr/local/software/kafka
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## KAFKA_HOME
export KAFKA_HOME=/usr/local/software/kafka
export PATH=$PATH:$KAFKA_HOME/bin
EOF
source ~/.bash_profile
```



## 集群配置

> 在bigdata01节点配置文件，然后分发到其他节点上

### 配置server.properties

```
cp $KAFKA_HOME/config/kraft/server.properties{,_bak}
cat > $KAFKA_HOME/config/kraft/server.properties <<"EOF"
process.roles=controller,broker
node.id=1
controller.quorum.voters=1@bigdata01:9093,2@bigdata02:9093,3@bigdata03:9093
inter.broker.listener.name=INTERNAL
controller.listener.names=CONTROLLER
listeners=CLIENT://bigdata01:9092,CONTROLLER://bigdata01:9093,INTERNAL://bigdata01:9094,EXTERNAL://bigdata01:9095
advertised.listeners=CLIENT://bigdata01:9092,INTERNAL://bigdata01:9094,EXTERNAL://14.104.200.4:19092
listener.security.protocol.map=CLIENT:PLAINTEXT,INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT
log.dirs=/data/service/kafka/data/01,/data/service/kafka/data/02
num.io.threads=8
num.network.threads=3
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=3
default.replication.factor=3
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
auto.create.topics.enable=true
delete.topic.enable=true
log.retention.hours=72
log.retention.bytes=1073741824
log.retention.check.interval.ms=300000
log.segment.bytes=1073741824
max.partition.fetch.bytes=104857600
max.request.size=104857600
message.max.bytes=104857600
EOF
```

### 分发配置文件

分发配置文件

```
scp $KAFKA_HOME/config/kraft/server.properties bigdata02:$KAFKA_HOME/config/kraft/
scp $KAFKA_HOME/config/kraft/server.properties bigdata03:$KAFKA_HOME/config/kraft/
```

### 修改其他节点配置

修改node.id

> 所有server的id在集群中必须保持唯一

```
[admin@bigdata02 ~]$ sed -i "s#node.id=.*#node.id=2#" $KAFKA_HOME/config/kraft/server.properties
[admin@bigdata03 ~]$ sed -i "s#node.id=.*#node.id=3#" $KAFKA_HOME/config/kraft/server.properties
```

修改listeners

```
[admin@bigdata02 ~]$ sed -i "s#listeners=.*#listeners=CLIENT://bigdata02:9092,CONTROLLER://bigdata02:9093,INTERNAL://bigdata02:9094,EXTERNAL://bigdata02:9095#" $KAFKA_HOME/config/kraft/server.properties

[admin@bigdata03 ~]$ sed -i "s#listeners=.*#listeners=CLIENT://bigdata03:9092,CONTROLLER://bigdata03:9093,INTERNAL://bigdata03:9094,EXTERNAL://bigdata03:9095#" $KAFKA_HOME/config/kraft/server.properties
```

修改advertised.listeners

```
[admin@bigdata02 ~]$ sed -i "s#advertised.listeners=.*#advertised.listeners=CLIENT://bigdata02:9092,INTERNAL://bigdata02:9094,EXTERNAL://14.104.200.4:19092#" $KAFKA_HOME/config/kraft/server.properties

[admin@bigdata03 ~]$ sed -i "s#advertised.listeners=.*#advertised.listeners=CLIENT://bigdata03:9092,INTERNAL://bigdata03:9094,EXTERNAL://14.104.200.4:19092#" $KAFKA_HOME/config/kraft/server.properties
```



### 设置日志目录格式

生成集群 UUID

> 在bigdata01节点生成UUID，用做集群的ID

```
kafka-storage.sh random-uuid
```

格式化目录

> 使用以上生成的UUID，在所有节点格式化目录

```
kafka-storage.sh format -t NonEOQviS621cjG0UXb7NQ -c $KAFKA_HOME/config/kraft/server.properties
```



## 启动集群

启动服务

> bigdata01: Controller、Broker
>
> bigdata02: Controller、Broker
>
> bigdata03: Controller、Broker
>
> Controller Address: bigdata01:9093

```
kafka-server-start.sh -daemon $KAFKA_HOME/config/kraft/server.properties
```

关闭服务

```
kafka-server-stop.sh
```



## 设置服务自启

### Kafka 服务

> bigdata01、bigdata02、bigdata03节点设置

```
$ sudo vi /etc/systemd/system/kafka.service
[Unit]
Description=Kafka Server
Documentation=https://kafka.apache.org
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/kafka
Environment="JAVA_HOME=/usr/local/software/jdk1.8.0"
Environment="KAFKA_HOME=/usr/local/software/kafka"
Environment="LOG_DIR=/data/service/kafka/logs"
Environment="KAFKA_HEAP_OPTS=-Xmx1g -Xms1g"
ExecStart=/usr/local/software/kafka/bin/kafka-server-start.sh /usr/local/software/kafka/config/kraft/server.properties
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable kafka.service
sudo systemctl start kafka.service
sudo systemctl status kafka.service
```



## 使用服务

创建topic

```
kafka-topics.sh --create \
    --topic quickstart-events \
    --partitions 3 --replication-factor 3 \
    --bootstrap-server bigdata01:9092,bigdata02:9092,bigdata03:9092
```

查看topic

```
kafka-topics.sh --bootstrap-server bigdata01:9092,bigdata02:9092,bigdata03:9092 --list
kafka-topics.sh --describe --topic quickstart-events --bootstrap-server bigdata01:9092,bigdata02:9092,bigdata03:9092
```

写入消息

```
$ kafka-console-producer.sh --topic quickstart-events --bootstrap-server bigdata01:9092,bigdata02:9092,bigdata03:9092
This is my first event
This is my second event
```

读取消息

```
$ kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server bigdata01:9092,bigdata02:9092,bigdata03:9092
This is my first event
This is my second event
```

删除topic

```
kafka-topics.sh \
    --delete --topic quickstart-events \
    --bootstrap-server bigdata01:9092,bigdata02:9092,bigdata03:9092 
```

