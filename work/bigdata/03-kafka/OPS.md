# Kafka使用文档

## 主题管理

**创建主题**
 参数说明：

- `--replication-factor`：副本因子，常用值 `1`, `2`, `3`。
- `--partitions`：分区数，如 `1`, `3`, `5`。
- `--topic`：主题名称，用户自定义。

命令：

```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic <topic-name>
```

**列出所有主题**
 查看当前 Kafka 集群中存在的主题列表：

```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

**查看主题详情**
 参数说明：

- `--topic`：目标主题名称。

命令：

```bash
kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic <topic-name>
```

**删除主题**
 删除指定主题（需要删除权限）：

```bash
kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic <topic-name>
```

## 数据生产与消费

**生产消息**
 用于向主题发送消息。
 参数：

- `--broker-list`：Kafka 服务地址，格式 `host:port`。
- `--topic`：目标主题名称。

命令：

```bash
kafka-console-producer.sh --broker-list localhost:9092 --topic <topic-name>
```

**消费消息**
 从主题中消费消息。
 参数：

- `--bootstrap-server`：Kafka 服务地址。
- `--topic`：目标主题名称。
- `--from-beginning`：从消息开始位置消费（可选）。

命令：

```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic <topic-name> --from-beginning
```

------

## 消费者组管理

**列出消费者组**
 查看所有消费者组：

```bash
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
```

**查看消费者组详情**
 查看指定消费者组的消费状态。
 参数：

- `--group`：消费者组 ID。

命令：

```bash
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group <group-id>
```

**重置消费者组偏移量**
 将消费者组的偏移量重置到指定位置。
 参数：

- `--reset-offsets`：重置操作标志。
- `--to-earliest`：重置到最早偏移量。
- `--to-latest`: 重置到最新偏移量。
- `--execute`：确认执行。
- `--topic`：目标主题名称。

命令：

```bash
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group <group-id> --reset-offsets --to-earliest --execute --topic <topic-name>
```

------

## 测试工具

**生产性能测试**
 生成性能测试数据。
 参数：

- `--topic`：目标主题名称。
- `--num-records`：消息数量，如 `1000`, `10000`。
- `--record-size`：消息大小（字节）。
- `--throughput`：发送速率（条/秒），`-1` 表示无限制。

命令：

```bash
kafka-producer-perf-test.sh --topic <topic-name> --num-records 1000 --record-size 100 --throughput 500 --producer-props bootstrap.servers=localhost:9092
```

**消费性能测试**
 测试消费性能。
 参数：

- `--broker-list`：Kafka 服务地址。
- `--messages`：消费消息数量。
- `--topic`：目标主题名称。

命令：

```bash
kafka-consumer-perf-test.sh --broker-list localhost:9092 --messages 1000 --topic <topic-name>
```

------

## 数据转储

**导出数据到文件**
 将消费的消息保存到文件中：

```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic <topic-name> --from-beginning > output.txt
```

**从文件导入数据到主题**
 从文件中读取数据并发送到主题：

```bash
kafka-console-producer.sh --broker-list localhost:9092 --topic <topic-name> < input.txt
```



## Kafka Connect

Kafka Connect 是 Kafka 的数据集成工具，用于高效、可靠地实现数据导入和导出。以下是关于使用 **Kafka Connect** 进行数据导入和导出的详细说明。

Kafka Connect 支持两种模式：

- **Standalone 模式**：单节点部署，适用于小型任务或开发测试环境。
- **Distributed 模式**：多节点集群，支持任务高可用和负载均衡，适用于生产环境。

### 编辑配置文件

**创建plugins**

```
cd $KAFKA_HOME
mkdir -p plugins
cp libs/connect-file-3.8.1.jar plugins
```

**修改connect-standalone.properties**

```
$ vi config/connect-standalone.properties
plugin.path=/usr/local/software/kafka/plugins
key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter
```

### 导出数据导文件

将 Kafka 中的消息导出到外部系统（如文件、数据库、对象存储等）。

**编写连接器配置文件**

 以导出 Kafka 数据到文件为例，创建配置文件 `file-sink-connector.properties`：

```properties
name=file-sink-connector
connector.class=FileStreamSinkConnector
tasks.max=1
file=/tmp/file.txt
topics=test
```

参数说明：

- `name`：连接器名称。
- `connector.class`：连接器类，这里是 `FileStreamSink`。
- `tasks.max`：任务实例数。
- `file`：输出文件路径。
- `topics`：需要导出的 Kafka 主题。

**启动 Kafka Connect**
 在 Standalone 模式下启动：

```bash
connect-standalone.sh config/connect-standalone.properties file-sink-connector.properties
```

**验证数据导出**
 检查文件路径 `/path/to/output/file.txt` 是否生成导出的数据。

