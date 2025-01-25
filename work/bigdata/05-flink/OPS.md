# Flink使用文档



## Flink SQL

### 启动SQL Client

**启动集群和history**

Flink Web: http://bigdata01:8082/

Flink History Server Web: http://bigdata01:8083/

```
$FLINK_HOME/bin/start-cluster.sh
$FLINK_HOME/bin/historyserver.sh start
```

**拷贝依赖包**

```
cp $FLINK_HOME/opt/flink-sql-client-1.19.1.jar $FLINK_HOME/lib/
```

**启动SQL Client**

```
$FLINK_HOME/bin/sql-client.sh
```

**设置参数**

在屏幕上直接以表格格式显示结果

```
SET sql-client.execution.result-mode=tableau;
```



### 创建表

#### 创建datagen表

该表作为后续的数据源表，用于将生成的数据插入到其他表中

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-datagen/1.19.1/flink-connector-datagen-1.19.1.jar
```

拷贝依赖到lib下后再启动sql client

```
cp lib/flink-connector-datagen-1.19.1.jar $FLINK_HOME/lib/
```

创建表

```
CREATE TABLE my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3)
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '100',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

查看数据

```
select * from my_user;
```

#### 创建Kafka表

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.3.0-1.19/flink-connector-kafka-3.3.0-1.19.jar
wget -P lib https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.8.1/kafka-clients-3.8.1.jar
```

拷贝依赖到lib下后再启动sql client，需要重启Flink服务

```
cp lib/{flink-connector-kafka-3.3.0-1.19.jar,kafka-clients-3.8.1.jar} $FLINK_HOME/lib/
```

创建表

> Kafka的并行度最好和Topic的分区数保存整数倍关系
>
> scan.startup.mode如果使用Kafka的group-offsets，需要保证Topic的消费者组有其信息，步骤如下：
>
> 1. 首先创建Kafka的消费者
>
> kafka-consumer-groups.sh --bootstrap-server 192.168.1.10:9094 --group ateng_sql --reset-offsets --to-earliest --execute --topic ateng_flink_json
>
> 2. 设置Flink的scan.startup.mode=group-offsets

```
SET parallelism.default = 3;
CREATE TABLE my_user_kafka( 
  my_event_time TIMESTAMP(3) METADATA FROM 'timestamp' VIRTUAL,
  my_partition BIGINT METADATA FROM 'partition' VIRTUAL,
  my_offset BIGINT METADATA FROM 'offset' VIRTUAL,
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
  'connector' = 'kafka',
  'properties.bootstrap.servers' = '192.168.1.10:9094',
  'properties.group.id' = 'ateng_sql',
  -- 'earliest-offset', 'latest-offset', 'group-offsets', 'timestamp' and 'specific-offsets'
  'scan.startup.mode' = 'earliest-offset',
  'topic' = 'ateng_flink_json',
  'format' = 'json'
);
```

插入数据

```
insert into my_user_kafka select * from my_user;
```

查看数据

```
select * from my_user_kafka;
```

#### 创建文件表(HDFS)

创建表

```sql
CREATE TABLE my_user_file(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
  'connector' = 'filesystem',
  'path' = 'hdfs://bigdata01:8020/flink/database/my_user_file',
  'format' = 'csv'
);
```

插入数据

> 这里设置较长的checkpoint的时间是防止产生过多的小文件

```
set execution.checkpointing.interval=120s;
insert into my_user_file select * from my_user;
```

查看数据

```
select * from my_user_file;
```

#### 创建文件表(Hive)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.19.1/flink-sql-parquet-1.19.1.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-parquet-1.19.1.jar $FLINK_HOME/lib/
```

创建表

```sql
CREATE TABLE my_user_hive(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
) WITH (
  'connector' = 'filesystem',
  'path' = 'hdfs://bigdata01:8020/hive/warehouse/my_user_hive',
  'format' = 'parquet'
);
```

插入数据

>这里设置较长的checkpoint的时间是防止产生过多的小文件

```
set execution.checkpointing.interval=120s;
insert into my_user_hive select * from my_user;
```

查看数据

> 进入Hive创建表

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
CREATE EXTERNAL TABLE my_user_hive (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
)
STORED AS PARQUET
LOCATION 'hdfs://bigdata01:8020/hive/warehouse/my_user_hive';
select * from my_user_hive;
select age,count(*) from my_user_hive group by age;
```

#### 创建文件表(Hive分区表)

> 推荐使用Hive Catalog的方式，因为这种方式需要手动加载分区数据

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.19.1/flink-sql-parquet-1.19.1.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-parquet-1.19.1.jar $FLINK_HOME/lib/
```

创建表

```sql
CREATE TABLE my_user_hive_part(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3),
  t_date STRING,
  t_hour STRING
) PARTITIONED BY (t_date, t_hour) WITH (
  'connector' = 'filesystem',
  'path' = 'hdfs://bigdata01:8020/hive/warehouse/my_user_hive_part',
  'format' = 'parquet',
  'sink.partition-commit.policy.kind'='success-file'
);
```

插入数据

> 这里设置较长的checkpoint的时间是防止产生过多的小文件

```
set execution.checkpointing.interval=120s;
insert into my_user_hive_part
select
  id,
  name,
  age,
  score,
  birthday,
  province,
  city,
  create_time,
  DATE_FORMAT(create_time, 'yyyy-MM-dd') AS t_date,
  DATE_FORMAT(create_time, 'HH') AS t_hour
from my_user;
```

查看数据

```sql
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
CREATE EXTERNAL TABLE my_user_hive_part (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
)
PARTITIONED BY (t_date STRING, t_hour STRING)
STORED AS PARQUET
LOCATION 'hdfs://bigdata01:8020/hive/warehouse/my_user_hive_part';

MSCK REPAIR TABLE my_user_hive_part; --- 加载分区
select * from my_user_hive_part;
select age,count(*) from my_user_hive_part group by age;
```

#### 创建文件表(MinIO)

> [参考文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/deployment/filesystems/s3/)

在`config.yaml`添加MinIO相关属性

```
$ vi $FLINK_HOME/conf/config.yaml
...
# MinIO
s3:
  access-key: admin
  secret-key: Lingo@local_minio_9000
  endpoint: http://192.168.1.13:9000
  path.style.access: true
```

配置s3插件，需要重启Flink服务

```
mkdir -p $FLINK_HOME/plugins/s3-fs-hadoop
cp $FLINK_HOME/opt/flink-s3-fs-hadoop-1.19.1.jar $FLINK_HOME/plugins/s3-fs-hadoop/
```

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.19.1/flink-sql-parquet-1.19.1.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-parquet-1.19.1.jar $FLINK_HOME/lib/
```

创建表

> 请勿使用**csv**格式，不然流式写入会报错**Stream closed.**，原因不祥。

```sql
CREATE TABLE my_user_file_minio (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
) WITH (
    'connector' = 'filesystem',
    'path' = 's3a://test/flink/my_user_file_minio',
    'format' = 'parquet'
);
```

插入数据

> 这里设置较长的checkpoint的时间是防止产生过多的小文件

```sql
set execution.checkpointing.interval=120s;
insert into my_user_file_minio select * from my_user;
```

查看数据

```
select * from my_user_file_minio;
```

#### 创建文件表(MinIO分区表)

> [参考文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/deployment/filesystems/s3/)

在`flink-conf.yaml`添加MinIO相关属性

```
$ vi $FLINK_HOME/conf/flink-conf.yaml
...
## MinIO
s3.access-key: admin
s3.secret-key: Lingo@local_minio_9000
s3.endpoint: http://192.168.1.13:9000
s3.path.style.access: true
```

配置s3插件，需要重启Flink服务

```
mkdir -p $FLINK_HOME/plugins/s3-fs-hadoop
cp $FLINK_HOME/opt/flink-s3-fs-hadoop-1.19.1.jar $FLINK_HOME/plugins/s3-fs-hadoop/
```

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-parquet/1.19.1/flink-sql-parquet-1.19.1.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-parquet-1.19.1.jar $FLINK_HOME/lib/
```

创建表

> 请勿使用**csv**格式，不然流式写入会报错**Stream closed.**，原因不祥。
>
> 可以使用**json**格式

```sql
CREATE TABLE my_user_file_minio_part (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3),
  t_date STRING,
  t_hour STRING
) PARTITIONED BY (t_date, t_hour) WITH (
    'connector' = 'filesystem',
    'path' = 's3://test/flink/my_user_file_minio_part',
    'format' = 'parquet',
    'sink.partition-commit.policy.kind'='success-file'
);
```

插入数据

> 这里设置较长的checkpoint的时间是防止产生过多的小文件

```sql
set execution.checkpointing.interval=120s;
insert into my_user_file_minio_part
select
  id,
  name,
  age,
  score,
  birthday,
  province,
  city,
  create_time,
  DATE_FORMAT(create_time, 'yyyy-MM-dd') AS t_date,
  DATE_FORMAT(create_time, 'HH') AS t_hour
from my_user;
```

查看数据

```
select * from my_user_file_minio_part;
```

#### 创建JDBC(MySQL)表

MySQL创建表

```sql
CREATE TABLE `my_user_mysql` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户姓名',
  `age` int DEFAULT NULL COMMENT '用户年龄',
  `score` double DEFAULT NULL COMMENT '分数',
  `birthday` datetime(3) DEFAULT NULL COMMENT '用户生日',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户所在省份',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户所在城市',
  `create_time` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户表';
```

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.2.0-1.19/flink-connector-jdbc-3.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/mysql-connector-j-8.0.33.jar $FLINK_HOME/lib/
cp lib/flink-connector-jdbc-3.2.0-1.19.jar $FLINK_HOME/lib/
```

创建表

```sql
CREATE TABLE my_user_mysql(
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
) WITH (
    'connector'='jdbc',
    'url' = 'jdbc:mysql://192.168.1.10:35725/kongyu_flink',
    'username' = 'root',
    'password' = 'Admin@123',
    'connection.max-retry-timeout' = '60s',
    'table-name' = 'my_user_mysql',
    'sink.buffer-flush.max-rows' = '500',
    'sink.buffer-flush.interval' = '5s',
    'sink.max-retries' = '3',
    'sink.parallelism' = '1'
);
```

插入数据

> MySQL的id字段是自增，这里就不需要id字段

```
INSERT INTO my_user_mysql (name, age, score, birthday, province, city, create_time)
SELECT name, age, score, birthday, province, city, create_time
FROM my_user;
```

查看数据

```
select * from my_user_mysql;
```

#### 创建JDBC(PostgreSQL)表

PostgreSQL创建表

```sql
CREATE TABLE my_user_postgresql (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) DEFAULT NULL,
  age INT DEFAULT NULL,
  score DOUBLE PRECISION DEFAULT NULL,
  birthday TIMESTAMP(3) DEFAULT NULL,
  province VARCHAR(255) DEFAULT NULL,
  city VARCHAR(255) DEFAULT NULL,
  create_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3)
); 
-- 表级注释
COMMENT ON TABLE my_user_postgresql IS '用户表';
-- 列级注释
COMMENT ON COLUMN my_user_postgresql.id IS '自增ID';
COMMENT ON COLUMN my_user_postgresql.name IS '用户姓名';
COMMENT ON COLUMN my_user_postgresql.age IS '用户年龄';
COMMENT ON COLUMN my_user_postgresql.score IS '分数';
COMMENT ON COLUMN my_user_postgresql.birthday IS '用户生日';
COMMENT ON COLUMN my_user_postgresql.province IS '用户所在省份';
COMMENT ON COLUMN my_user_postgresql.city IS '用户所在城市';
COMMENT ON COLUMN my_user_postgresql.create_time IS '创建时间';
```

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.2.0-1.19/flink-connector-jdbc-3.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/postgresql-42.7.1.jar $FLINK_HOME/lib/
cp lib/flink-connector-jdbc-3.2.0-1.19.jar $FLINK_HOME/lib/
```

创建表

> PostgreSQL的id字段是自增，这里就不需要id字段

```sql
CREATE TABLE my_user_postgresql(
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
) WITH (
    'connector'='jdbc',
    'url' = 'jdbc:postgresql://192.168.1.10:32297/kongyu_flink?currentSchema=public&stringtype=unspecified',
    'username' = 'postgres',
    'password' = 'Lingo@local_postgresql_5432',
    'connection.max-retry-timeout' = '60s',
    'table-name' = 'my_user_postgresql',
    'sink.buffer-flush.max-rows' = '500',
    'sink.buffer-flush.interval' = '5s',
    'sink.max-retries' = '3',
    'sink.parallelism' = '1'
);
```

插入数据

> PostgreSQL的id字段是自增，这里就不需要id字段

```
INSERT INTO my_user_postgresql (name, age, score, birthday, province, city, create_time)
SELECT name, age, score, birthday, province, city, create_time
FROM my_user;
```

查看数据

```
select * from my_user_postgresql;
```

#### 创建Doris表

> [参考文档](https://doris.apache.org/zh-CN/docs/ecosystem/flink-doris-connector)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/doris/flink-doris-connector-1.19/24.1.0/flink-doris-connector-1.19-24.1.0.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-doris-connector-1.19-24.1.0.jar $FLINK_HOME/lib/
```

doris创建表

```sql
CREATE TABLE kongyu.my_user_doris (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday DATETIME,
  province STRING,
  city STRING,
  create_time DATETIME
) 
DISTRIBUTED BY HASH(id) BUCKETS 10
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
```

创建表

```sql
CREATE TABLE my_user_doris(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
  'connector' = 'doris',
  'fenodes' = '192.168.1.12:9040', -- FE_IP:HTTP_PORT
  'table.identifier' = 'kongyu.my_user_doris',
  'username' = 'admin',
  'password' = 'Admin@123',
  'sink.label-prefix' = 'doris_label'
);
```

插入数据

```
insert into my_user_doris select * from my_user;
```

查看数据

```
select * from my_user_doris;
```

#### 创建MongoDB表

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-mongodb/1.2.0-1.19/flink-sql-connector-mongodb-1.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-connector-mongodb-1.2.0-1.19.jar $FLINK_HOME/lib/
```

创建表

```sql
CREATE TABLE my_user_mongo(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
   'connector' = 'mongodb',
   'uri' = 'mongodb://root:Admin%40123@192.168.1.10:33627',
   'database' = 'kongyu',
   'collection' = 'my_user_mongo'
);
```

插入数据

```
insert into my_user_mongo select * from my_user;
```

查看数据

```
select * from my_user_mongo;
```

#### 创建ElasticSearch表

> 使用**OpenSearch**的connector，适用于es7
>
> [官方文档](https://opensearch.org/blog/OpenSearch-Flink-Connector/)
>
> [官方文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/connectors/table/opensearch/)
>
> [下载地址](https://central.sonatype.com/artifact/org.apache.flink/flink-sql-connector-opensearch/overview)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-opensearch/1.2.0-1.19/flink-sql-connector-opensearch-1.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-connector-opensearch-1.2.0-1.19.jar $FLINK_HOME/lib/
```

创建表

```sql
CREATE TABLE my_user_es(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
    'connector' = 'opensearch',
    'hosts' = 'http://192.168.1.10:34683',
    'index' = 'my_user_es_{create_time|yyyy-MM-dd}',
    'username' = 'elastic',
    'password' = 'Admin@123'
);
```

插入数据

```
insert into my_user_es select * from my_user;
```

#### 创建OpenSearch表

> 使用OpenSearch 1.3.19测试通过
>
> [官方文档](https://opensearch.org/blog/OpenSearch-Flink-Connector/)
>
> [官方文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/connectors/table/opensearch/)
>
> [下载地址](https://central.sonatype.com/artifact/org.apache.flink/flink-sql-connector-opensearch/overview)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-opensearch/1.2.0-1.19/flink-sql-connector-opensearch-1.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/flink-sql-connector-opensearch-1.2.0-1.19.jar $FLINK_HOME/lib/
```

创建表

```sql
CREATE TABLE my_user_os(
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
    'connector' = 'opensearch',
    'hosts' = 'http://192.168.1.10:44771',
    'index' = 'my_user_os_{create_time|yyyy-MM-dd}'
);
```

> 如果是HTTPS使用以下参数：
> WITH (
>     'connector' = 'opensearch',
>     'hosts' = 'https://192.168.1.10:44771',
>     'index' = 'my_user_es_{create_time|yyyy-MM-dd}',
>     'username' = 'admin',
>     'password' = 'Admin@123',
>     'allow-insecure' = 'true'
> );

插入数据

```
insert into my_user_os select * from my_user;
```



### 时间窗口查询

#### Datagen

创建表并设置水位线

```sql
CREATE TABLE my_user_window_kafka_datagen (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  event_time AS cast(CURRENT_TIMESTAMP as timestamp(3)), --事件时间
  proc_time AS PROCTIME(), --处理时间
  WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '1',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

事件时间滚动窗口(2分钟)查询

```sql
SELECT
  window_start,
  window_end,
  window_time,
  avg(score) as avg_score,
  max(age) as age_max,
  count(id) as id_count
FROM TABLE(
  TUMBLE(
    TABLE my_user_window_kafka_datagen,
    DESCRIPTOR(event_time),
    INTERVAL '2' MINUTE
  )
)
GROUP BY window_start, window_end, window_time;
```

处理时间滚动窗口(2分钟)查询

```sql
SELECT
  window_start,
  window_end,
  window_time,
  avg(score) as avg_score,
  max(age) as age_max,
  count(id) as id_count
FROM TABLE(
  TUMBLE(
    TABLE my_user_window_kafka_datagen,
    DESCRIPTOR(proc_time),
    INTERVAL '2' MINUTE
  )
)
GROUP BY window_start, window_end, window_time;
```



#### Kafka

> [官方文档](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/table/kafka/)

创建表并设置水位线

> Kafka的并行度最好和Topic的分区数保存整数倍关系
>
> scan.startup.mode如果使用Kafka的group-offsets，需要保证Topic的消费者组有其信息，步骤如下：
>
> 1. 首先创建Kafka的消费者
>
> kafka-consumer-groups.sh --bootstrap-server 192.168.1.10:9094 --group ateng_sql --reset-offsets --to-earliest --execute --topic ateng_flink_json
>
> 2. 设置Flink的scan.startup.mode=group-offsets

```sql
SET parallelism.default = 3;
CREATE TABLE my_user_window_kafka (
  my_timestamp TIMESTAMP(3) METADATA FROM 'timestamp' VIRTUAL,
  my_partition BIGINT METADATA FROM 'partition' VIRTUAL,
  my_offset BIGINT METADATA FROM 'offset' VIRTUAL,
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  createTime TIMESTAMP(3),
  WATERMARK FOR createTime AS createTime - INTERVAL '5' SECOND
) WITH (
  'connector' = 'kafka',
  'topic' = 'ateng_flink_json',
  'properties.group.id' = 'ateng_sql_window',
  'properties.enable.auto.commit' = 'true',
  'properties.auto.commit.interval.ms' = '1000',
  'properties.partition.discovery.interval.ms' = '10000',
  -- 'earliest-offset', 'latest-offset', 'group-offsets', 'timestamp' and 'specific-offsets'
  'scan.startup.mode' = 'latest-offset',
  'properties.bootstrap.servers' = '192.168.1.10:9094',
  'format' = 'json'
);
```

插入一条数据

```
INSERT INTO my_user_window_kafka 
VALUES (
  1,
  'John',
  30,
  85.5,
  CAST('1990-01-01 10:00:00' AS TIMESTAMP(3)),
  'Shanghai',
  'Beijing',
  CAST('2025-01-05 12:00:00' AS TIMESTAMP(3))
);
```

插入数据

```
INSERT INTO my_user_window_kafka (id, name, age, score, birthday, province, city, createTime)
SELECT id, name, age, score, birthday, province, city, event_time
FROM my_user_window_kafka_datagen;
```

事件时间滚动窗口(2分钟)查询

```sql
SELECT
  window_start,
  window_end,
  window_time,
  avg(score) as avg_score,
  max(age) as age_max,
  count(id) as id_count
FROM TABLE(
  TUMBLE(
    TABLE my_user_window_kafka,
    DESCRIPTOR(createTime),
    INTERVAL '2' MINUTE
  )
)
GROUP BY window_start, window_end, window_time;
```

处理时间滚动窗口(2分钟)查询

```sql
SELECT
  window_start,
  window_end,
  window_time,
  avg(score) as avg_score,
  max(age) as age_max,
  count(id) as id_count
FROM TABLE(
  TUMBLE(
    TABLE my_user_window_kafka,
    DESCRIPTOR(eventTime),
    INTERVAL '2' MINUTE
  )
)
GROUP BY window_start, window_end, window_time;
```



### Catalog

Catalog 提供了元数据信息，例如数据库、表、分区、视图以及数据库或其他外部系统中存储的函数和信息。

数据处理最关键的方面之一是管理元数据。 元数据可以是临时的，例如临时表、或者通过 TableEnvironment 注册的 UDF。 元数据也可以是持久化的，例如 Hive Metastore 中的元数据。Catalog 提供了一个统一的API，用于管理元数据，并使其可以从 Table API 和 SQL 查询语句中来访问。

参考：[官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.19/zh/docs/dev/table/catalogs)

#### Hive

参考：[官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.19/zh/docs/connectors/table/hive/overview/)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.19.1/flink-sql-connector-hive-3.1.3_2.12-1.19.1.jar
```

拷贝依赖到lib下后再启动sql client，需要重启Flink服务

```
cp lib/flink-sql-connector-hive-3.1.3_2.12-1.19.1.jar $FLINK_HOME/lib/
```

启动SQL Client

```
$FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建

```
CREATE CATALOG hive_catalog WITH (
    'type'='hive',
    'hive-conf-dir'='/usr/local/software/hive/conf',
    'default-database'='default'
);
```

查看

```
show catalogs;
```

切换hive_catalog

```
use catalog hive_catalog;
```

在hive中创建表

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
CREATE TABLE my_user_hive_flink (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
)
PARTITIONED BY (t_date STRING, t_hour STRING)
STORED AS PARQUET
TBLPROPERTIES (
  'sink.partition-commit.policy.kind'='metastore,success-file'
);
```

数据生成

```
CREATE TABLE default_catalog.default_database.my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3)
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '100',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

插入数据

```
set execution.checkpointing.interval=120s;
insert into my_user_hive_flink
select
  id,
  name,
  age,
  score,
  birthday,
  province,
  city,
  create_time,
  DATE_FORMAT(create_time, 'yyyy-MM-dd') AS t_date,
  DATE_FORMAT(create_time, 'HH') AS t_hour
from
default_catalog.default_database.my_user;
```

查看表数据

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
select count(*) from my_user_hive_flink;
```



#### Hive（MinIO）

添加依赖和重启服务

> 如果是Flink Standalone模式就需要添加依赖，Flink on Yarn则不需要

```
cp $HADOOP_HOME/share/hadoop/tools/lib/{hadoop-aws-3.3.6.jar,aws-java-sdk-bundle-1.12.367.jar} $FLINK_HOME/lib
sudo systemctl restart flink-*
```

启动SQL Client

```
$FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建

```
CREATE CATALOG hive_catalog WITH (
    'type'='hive',
    'hive-conf-dir'='/usr/local/software/hive/conf',
    'default-database'='default'
);
```

查看

```
show catalogs;
```

切换hive_catalog

```
use catalog hive_catalog;
```

在hive中创建表

> 参考：[Hive创建外部存储MinIO表](https://kongyu666.github.io/ops/#/work/bigdata/04-hive/OPS?id=%e5%a4%96%e9%83%a8%e8%a1%a8%ef%bc%88minio%ef%bc%89)

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
CREATE TABLE my_user_hive_flink_minio (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
)
PARTITIONED BY (t_date STRING, t_hour STRING)
STORED AS PARQUET
LOCATION 's3a://test/hive/my_user_hive_flink_minio'
TBLPROPERTIES (
  'sink.partition-commit.policy.kind'='metastore,success-file'
);
```

数据生成

```
CREATE TABLE default_catalog.default_database.my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3)
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '100',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

插入数据

```
set execution.checkpointing.interval=120s;
insert into my_user_hive_flink_minio
select
  id,
  name,
  age,
  score,
  birthday,
  province,
  city,
  create_time,
  DATE_FORMAT(create_time, 'yyyy-MM-dd') AS t_date,
  DATE_FORMAT(create_time, 'HH') AS t_hour
from
default_catalog.default_database.my_user;
```

查看表数据

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
select count(*) from my_user_hive_flink_minio;
```



#### JDBC(MySQL)

参考：[官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.19/zh/docs/connectors/table/jdbc/#jdbc-catalog)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.2.0-1.19/flink-connector-jdbc-3.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/mysql-connector-j-8.0.33.jar $FLINK_HOME/lib/
cp lib/flink-connector-jdbc-3.2.0-1.19.jar $FLINK_HOME/lib/
```

启动SQL Client

```
$FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建

```
CREATE CATALOG mysql_catalog WITH (
    'type' = 'jdbc',
    'base-url' = 'jdbc:mysql://192.168.1.10:35725',
    'username' = 'root',
    'password' = 'Admin@123',
    'default-database' = 'kongyu'
);
```

查看

```
show catalogs;
```

切换mysql_catalog

```
use catalog mysql_catalog;
```

查看数据库

```
show databases;
```

查看表

```
use kongyu;
show tables;
```

MySQL创建表

```sql
-- 创建表
DROP TABLE IF EXISTS `my_user_flink_catalog`;
CREATE TABLE IF NOT EXISTS `my_user_flink_catalog` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID' primary key,
  `name` varchar(255) NOT NULL COMMENT '用户姓名',
  `age` int COMMENT '用户年龄',
  `score` double COMMENT '分数',
  `birthday` datetime(3) COMMENT '用户生日',
  `province` varchar(255) COMMENT '用户所在省份',
  `city` varchar(255) COMMENT '用户所在城市',
  `create_time` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  KEY `idx_name` (`name`),
  KEY `idx_province_city` (`province`, `city`),
  KEY `idx_create_time` (`create_time`)
) COMMENT='用户表';
-- 插入数据
insert into my_user_flink_catalog (name, age, score, birthday, province, city)
values  ('阿腾', 25, 118.124, '1993-03-15 06:34:51.619', '重庆市', '重庆市'),
        ('沈烨霖', 36, 8.124, '1993-03-15 06:34:51.619', '吉林省', '荣成'),
        ('宋文博', 28, 26.38, '1986-05-17 21:06:30.511', '广西省', '阳江'),
        ('萧伟宸', 1, 9.699, '1991-04-02 18:21:24.825', '福建省', '厦门');
```

查看数据

```
select * from my_user_flink_catalog limit 10;
```

数据生成

```
CREATE TABLE default_catalog.default_database.my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3)
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '100',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

写入数据

```
set execution.checkpointing.interval=120s;
insert into my_user_flink_catalog
select
  id,
  name,
  age,
  score,
  birthday,
  province,
  city,
  create_time
from
default_catalog.default_database.my_user;
```



#### JDBC(PostgreSQL)

参考：[官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.19/zh/docs/connectors/table/jdbc/#jdbc-catalog)

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.2.0-1.19/flink-connector-jdbc-3.2.0-1.19.jar
```

拷贝依赖到lib下后再启动sql clientt，需要重启Flink服务

```
cp lib/postgresql-42.7.1.jar $FLINK_HOME/lib/
cp lib/flink-connector-jdbc-3.2.0-1.19.jar $FLINK_HOME/lib/
```

启动SQL Client

```
$FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建

```
CREATE CATALOG postgresql_catalog WITH (
    'type' = 'jdbc',
    'base-url' = 'jdbc:postgresql://192.168.1.10:32297',
    'username' = 'postgres',
    'password' = 'Lingo@local_postgresql_5432',
    'default-database' = 'kongyu_flink'
);
```

查看

```
show catalogs;
```

切换postgresql_catalog

```
use catalog postgresql_catalog;
```

查看数据库

```
show databases;
```

查看表

> 实际的TableName前面有一个Schema

```
Flink SQL> use kongyu_flink;
[INFO] Execute statement succeed.

Flink SQL> show tables;
+---------------------------+
|                table name |
+---------------------------+
|             ateng.my_user |
|            public.my_user |
| public.my_user_postgresql |
+---------------------------+
3 rows in set
```

PostgreSQL创建表

```sql
-- 创建表
CREATE TABLE my_user_flink_catalog (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) DEFAULT NULL,
  age INT DEFAULT NULL,
  score DOUBLE PRECISION DEFAULT NULL,
  birthday TIMESTAMP(3) DEFAULT NULL,
  province VARCHAR(255) DEFAULT NULL,
  city VARCHAR(255) DEFAULT NULL,
  create_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3)
); 
-- 表级注释
COMMENT ON TABLE my_user_postgresql IS '用户表';
-- 列级注释
COMMENT ON COLUMN my_user_postgresql.id IS '自增ID';
COMMENT ON COLUMN my_user_postgresql.name IS '用户姓名';
COMMENT ON COLUMN my_user_postgresql.age IS '用户年龄';
COMMENT ON COLUMN my_user_postgresql.score IS '分数';
COMMENT ON COLUMN my_user_postgresql.birthday IS '用户生日';
COMMENT ON COLUMN my_user_postgresql.province IS '用户所在省份';
COMMENT ON COLUMN my_user_postgresql.city IS '用户所在城市';
COMMENT ON COLUMN my_user_postgresql.create_time IS '创建时间';
-- 插入数据
insert into my_user_flink_catalog (name, age, score, birthday, province, city)
values  ('阿腾', 25, 118.124, '1993-03-15 06:34:51.619', '重庆市', '重庆市'),
        ('沈烨霖', 36, 8.124, '1993-03-15 06:34:51.619', '吉林省', '荣成'),
        ('宋文博', 28, 26.38, '1986-05-17 21:06:30.511', '广西省', '阳江'),
        ('萧伟宸', 1, 9.699, '1991-04-02 18:21:24.825', '福建省', '厦门');
```

查看数据

```
select * from `public.my_user_postgresql` limit 10;
```

数据生成

```
CREATE TABLE default_catalog.default_database.my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3)
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '100',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

写入数据

```
set execution.checkpointing.interval=120s;
insert into my_user_flink_catalog
select
  id,
  name,
  age,
  score,
  birthday,
  province,
  city,
  create_time
from
default_catalog.default_database.my_user;
```

#### Iceberg

参考：[使用Iceberg文档](https://kongyu666.github.io/ops/#/work/bigdata/06-iceberg/?id=spark)

**下载依赖包**

iceberg-flink-runtime，用于flink集成iceberg

```
wget -P lib https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.19/1.6.1/iceberg-flink-runtime-1.19-1.6.1.jar
```

iceberg-aws-bundle，用于spark集成iceberg后数据写入s3（MinIO）中

```
wget -P lib https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.6.1/iceberg-aws-bundle-1.6.1.jar
```

postgresql，用于连接数据库的JDBC驱动

```
wget -P lib https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
```

**拷贝依赖**

```
cp lib/{iceberg-flink-runtime-1.19-1.6.1.jar,iceberg-aws-bundle-1.6.1.jar,postgresql-42.7.1.jar} $FLINK_HOME/lib
```

**配置MinIO环境变量**

使用sql-client需要加载MinIO配置的环境变量到当前终端

```
cat >> /data/service/flink/config/env.conf <<EOF
## MinIO Config
AWS_ACCESS_KEY_ID=admin
AWS_SECRET_ACCESS_KEY=Lingo@local_minio_9000
AWS_REGION=us-east-1
EOF
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=Lingo@local_minio_9000
export AWS_REGION=us-east-1
```

**重启服务**

```
sudo systemctl restart flink-historyserver.service flink-jobmanager.service flink-taskmanager.service
```

**创建Catalog**

启动SQL Client

```
$FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建Catalog

```
CREATE CATALOG iceberg_catalog
WITH (
    'type'='iceberg',
    'catalog-impl'='org.apache.iceberg.jdbc.JdbcCatalog',
    'io-impl'='org.apache.iceberg.aws.s3.S3FileIO',
    'uri'='jdbc:postgresql://192.168.1.10:32297/iceberg?user=postgres&password=Lingo@local_postgresql_5432',
    'warehouse'='s3://iceberg-bucket/warehouse',
    's3.endpoint'='http://192.168.1.13:9000'
);
```

查看并切换

```
show catalogs;
use catalog iceberg_catalog;
```

创建数据库

```
create database flink;
use flink;
```

**创建数据源表**

```
CREATE TABLE default_catalog.default_database.my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '100',
  'fields.id.min' = '1',
  'fields.id.max' = '100000',
  'fields.name.length' = '10',
  'fields.age.min' = '18',
  'fields.age.max' = '60',
  'fields.score.min' = '0',
  'fields.score.max' = '100',
  'fields.province.length' = '5',
  'fields.city.length' = '5'
);
```

**创建表**

```
CREATE TABLE IF NOT EXISTS my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3)
) WITH (
  'write.format.default' = 'parquet'
);
```

**查看表**

```
SHOW CREATE TABLE my_user;
```

**插入数据**

```
set execution.checkpointing.interval=120s;
insert into my_user select * from default_catalog.default_database.my_user;
```

**查看数据**

```
SELECT * FROM my_user;
SELECT count(*) FROM my_user;
```



## Flink CDC

Flink CDC源是Apache Flink®的一组源连接器，使用更改数据捕获（CDC）从不同的数据库摄取更改。一些CDC源集成了Debezium作为捕获数据变化的引擎。所以它可以充分利用Debezium的能力。

- [官网链接](https://nightlies.apache.org/flink/flink-cdc-docs-release-3.2/zh/docs/connectors/flink-sources/overview/)

### MySQL CDC

下载依赖

```
wget -P lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-mysql-cdc/3.2.1/flink-sql-connector-mysql-cdc-3.2.1.jar
wget -P lib https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
```

拷贝依赖到lib下后再启动sql client，需要重启Flink服务

```
cp lib/{flink-sql-connector-mysql-cdc-3.2.1.jar,mysql-connector-j-8.0.33.jar} $FLINK_HOME/lib/
```

创建数据库表

```sql
--- mysql
CREATE TABLE kongyu_flink.my_user (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(10),
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province VARCHAR(20),
  city VARCHAR(20),
  create_time TIMESTAMP(3),
  PRIMARY KEY (id)
);

--- doris
CREATE TABLE kongyu_flink.my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday DATETIME,
  province STRING,
  city STRING,
  create_time DATETIME
) 
UNIQUE KEY(`id`)
DISTRIBUTED BY HASH(id) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
```

进入FlinkSQL

```
$ $FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建MySQL CDC

```
CREATE TABLE cdc_mysql_source (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3),
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
 'connector' = 'mysql-cdc',
 'hostname' = '192.168.1.10',
 'port' = '35725',
 'username' = 'root',
 'password' = 'Admin@123',
 'database-name' = 'kongyu_flink',
 'table-name' = 'my_user'
);
```

创建Doris

```
CREATE TABLE doris_sink (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3)
)
WITH (
  'connector' = 'doris',
  'fenodes' = '192.168.1.12:9040',
  'table.identifier' = 'kongyu_flink.my_user',
  'username' = 'admin',
  'password' = 'Admin@123',
  'sink.properties.format' = 'json',
  'sink.properties.read_json_by_line' = 'true',
  'sink.enable-delete' = 'true',  -- 同步删除事件
  'sink.properties.partial_columns' = 'true', -- 开启部分列更新
  'sink.label-prefix' = 'doris_label'
);
```

同步数据

```
insert into doris_sink select * from cdc_mysql_source;
```



### PostgreSQL CDC

下载依赖

```
wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/3.2.1/flink-sql-connector-postgres-cdc-3.2.1.jar
```

创建数据库表

> 注意PostgreSQ需要设置**wal_level = 'logical**参数，还需要安装**[Postgres Decoderbufs插件](https://github.com/debezium/postgres-decoderbufs)**

```sql
--- postgresql
create table if not exists public.my_user
(
    id          serial primary key,
    name        varchar(10),
    age         integer,
    score       double precision,
    birthday    timestamp,
    province    varchar(20),
    city        varchar(20),
    create_time timestamp
);
```

进入FlinkSQL

```
$ $FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建Postgresql CDC

```
CREATE TABLE cdc_postgres_source (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3),
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
 'connector' = 'postgres-cdc',
 'hostname' = '192.168.1.10',
 'port' = '32297',
 'username' = 'postgres',
 'password' = 'Lingo@local_postgresql_5432',
 'database-name' = 'kongyu_flink',
 'schema-name' = 'public',
 'table-name' = 'my_user',
 'slot.name' = 'flink'
);
```

实时查看数据

```
select * from cdc_postgres_source;
```



### MongoDB CDC

下载依赖

```
wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-mongodb-cdc/3.2.1/flink-sql-connector-mongodb-cdc-3.2.1.jar
```

创建数据库表

> MongoDB必须是[replica sets](https://docs.mongodb.com/manual/replication/) or [sharded clusters](https://docs.mongodb.com/manual/sharding/)

```sql
// mongodb
db.my_user.insertOne({
    id: 1, // MongoDB 会自动生成 _id 字段作为主键，你可以省略 id 字段
    name: "Alice",
    age: 30,
    score: 85.5,
    birthday: new Date("1992-03-25T00:00:00Z"),
    province: "Beijing",
    city: "Beijing",
    create_time: new Date()
});
```

进入FlinkSQL

```
$ $FLINK_HOME/bin/sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

创建MongoDB CDC

```
CREATE TABLE cdc_mongodb_source (
  _id STRING,
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP(3),
  PRIMARY KEY (_id) NOT ENFORCED
) WITH (
 'connector' = 'mongodb-cdc',
  'hosts' = '192.168.1.10:19868',
  'username' = 'root',
  'password' = 'Admin@123',
  'database' = 'kongyu_flink',
  'collection' = 'my_user'
);
```

实时查看数据

```
select * from cdc_mongodb_source;
```

### 
