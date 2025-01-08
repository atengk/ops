# Flink CDC

Flink CDC 是一个基于流的数据集成工具，旨在为用户提供一套功能更加全面的编程接口（API）。 该工具使得用户能够以 YAML 配置文件的形式，优雅地定义其 ETL（Extract, Transform, Load）流程，并协助用户自动化生成定制化的 Flink 算子并且提交 Flink 作业。 Flink CDC 在任务提交过程中进行了优化，并且增加了一些高级特性，如表结构变更自动同步（Schema Evolution）、数据转换（Data Transformation）、整库同步（Full Database Synchronization）以及 精确一次（Exactly-once）语义。

Flink CDC 深度集成并由 Apache Flink 驱动，提供以下核心功能：

- ✅ 端到端的数据集成框架
- ✅ 为数据集成的用户提供了易于构建作业的 API
- ✅ 支持在 Source 和 Sink 中处理多个表
- ✅ 整库同步
- ✅具备表结构变更自动同步的能力（Schema Evolution）



- [官网链接](https://nightlies.apache.org/flink/flink-cdc-docs-release-3.2/zh/)
- [Flink Doris Connector](https://doris.apache.org/zh-CN/docs/ecosystem/flink-doris-connector/)



## 使用flink-cdc.sh

**下载软件包**

```
wget https://archive.apache.org/dist/flink/flink-cdc-3.2.1/flink-cdc-3.2.1-bin.tar.gz
```

**解压软件包**

```
tar -zxf flink-cdc-3.2.1-bin.tar.gz
cd flink-cdc-3.2.1
```

**创建配置文件**

### MySQL => Doris

**编辑配置文件**

将MySQL中 `kongyu_flink` 数据库中的所有表同步到Doris的同名数据库中（需要再Doris提前创建好该库）

```
cat > mysql-to-doris.yaml <<"EOF"
source:
  type: mysql
  hostname: 192.168.1.10
  port: 35725
  username: root
  password: Admin@123
  tables: kongyu_flink.\.*
  server-id: 5400-5404
  server-time-zone: Asia/Shanghai

sink:
  type: doris
  fenodes: 192.168.1.12:9040
  username: admin
  password: "Admin@123"
  table.create.properties.light_schema_change: true
  table.create.properties.replication_num: 1

pipeline:
  name: Sync MySQL Database to Doris
  parallelism: 2
EOF
```

**下载依赖**

MySQL pipeline connector

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-mysql/3.2.1/flink-cdc-pipeline-connector-mysql-3.2.1.jar
```

Apache Doris pipeline connector

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-doris/3.2.1/flink-cdc-pipeline-connector-doris-3.2.1.jar
```

MySQL Connector Java

> 这个包需要放在Flink lib目录下，然后重启服务

```
wget -P lib https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
cp lib/mysql-connector-j-8.0.33.jar $FLINK_HOME/lib
```

**运行cdc**

```
bin/flink-cdc.sh mysql-to-doris.yaml
```

### MySQL => Kafka

**编辑配置文件**

并行度最好配置和Kafka topic的分区数一致

```
cat > mysql-to-kafka.yaml <<"EOF"
source:
  type: mysql
  hostname: 192.168.1.10
  port: 35725
  username: root
  password: Admin@123
  tables: kongyu_flink.\.*
  server-id: 5101-5105
  server-time-zone: Asia/Shanghai

sink:
  type: kafka
  name: Kafka Sink
  properties.bootstrap.servers: PLAINTEXT://192.168.1.10:9094
  partition.strategy: hash-by-key

pipeline:
  name: Sync MySQL Database to Kafka
  parallelism: 3
EOF
```

**下载依赖**

MySQL pipeline connector

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-mysql/3.2.1/flink-cdc-pipeline-connector-mysql-3.2.1.jar
```

Apache Kafka pipeline connector

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-kafka/3.2.1/flink-cdc-pipeline-connector-kafka-3.2.1.jar
```

MySQL Connector Java

> 这个包需要放在Flink lib目录下，然后重启服务

```
wget -P lib https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
cp lib/mysql-connector-j-8.0.33.jar $FLINK_HOME/lib
```

**运行cdc**

同步到Kafka后的topic是db_name.table_name这种结构

```
bin/flink-cdc.sh mysql-to-kafka.yaml
```

