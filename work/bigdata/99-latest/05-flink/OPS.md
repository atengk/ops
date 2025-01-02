# Flink运维



## SQL Client

### 启动SQL Client

启动集群和history

> Flink Web: http://bigdata01:8082/
>
> Flink History Server Web: http://bigdata01:8083/

```
$FLINK_HOME/bin/start-cluster.sh
$FLINK_HOME/bin/historyserver.sh start
```

拷贝依赖包

```
cp $FLINK_HOME/opt/flink-sql-client-1.20.0.jar $FLINK_HOME/lib/
```

拷贝客户端依赖包

```
cp lib/*.jar $FLINK_HOME/lib/
```

启动SQL Client

```
$FLINK_HOME/bin/sql-client.sh
```

设置参数

```
## 在屏幕上直接以表格格式显示结果。
SET sql-client.execution.result-mode=tableau;
```



### 创建表

#### 创建datagen表

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

```
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

> 注意第一次如果没有Consumer Group是会报错的，请先使用earliest-offset或者latest-offset

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

```
set execution.checkpointing.interval=120s;
insert into my_user_file select * from my_user;
```

查看数据

```
select * from my_user_file;
```

#### 创建文件表(Hive)

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

配置s3插件

```
mkdir -p $FLINK_HOME/plugins/s3-fs-hadoop
cp $FLINK_HOME/opt/flink-s3-fs-hadoop-1.20.0.jar $FLINK_HOME/plugins/s3-fs-hadoop/
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

配置s3插件

```
mkdir -p $FLINK_HOME/plugins/s3-fs-hadoop
cp $FLINK_HOME/opt/flink-s3-fs-hadoop-1.20.0.jar $FLINK_HOME/plugins/s3-fs-hadoop/
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
select * from my_user_file_minio;
```

#### 创建JDBC(MySQL)表

MySQL创建表

```sql
CREATE TABLE `my_user_mysql` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
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

#### 创建Doris表

> [参考文档](https://doris.apache.org/zh-CN/docs/ecosystem/flink-doris-connector)

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
  'fenodes' = '192.168.1.115:9040',
  'table.identifier' = 'kongyu.my_user_doris',
  'username' = 'root',
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

> 使用**OpenSearch**的connector，适用于es7和es8
>
> [官方文档](https://opensearch.org/blog/OpenSearch-Flink-Connector/)
>
> [官方文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/connectors/table/opensearch/)
>
> [下载地址](https://central.sonatype.com/artifact/org.apache.flink/flink-sql-connector-opensearch/overview)

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
    'hosts' = 'http://dev.es.lingo.local:80',
    'index' = 'my_user_es_{create_time|yyyy-MM-dd}',
    'username' = 'elastic',
    'password' = 'Admin@123'
);
```

插入数据

```
insert into my_user_es select * from my_user;
```

查看数据

```
select * from my_user_es;
```

#### 创建OpenSearch表

> OpenSearch 1.3.18
>
> [官方文档](https://opensearch.org/blog/OpenSearch-Flink-Connector/)
>
> [官方文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/connectors/table/opensearch/)
>
> [下载地址](https://central.sonatype.com/artifact/org.apache.flink/flink-sql-connector-opensearch/overview)

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
    'hosts' = 'https://192.168.1.10:15135',
    'index' = 'my_user_es_{create_time|yyyy-MM-dd}',
    'username' = 'admin',
    'password' = 'Admin@123',
    'allow-insecure' = 'true'
);
```

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
  age,
  COUNT(name) AS cnt,
  TUMBLE_START(event_time, INTERVAL '2' MINUTE) AS window_start,
  TUMBLE_END(event_time, INTERVAL '2' MINUTE) AS window_end
FROM my_user_window_kafka_datagen
GROUP BY
  age,
  TUMBLE(event_time, INTERVAL '2' MINUTE);
```

处理时间滚动窗口(2分钟)查询

```sql
SELECT
  age,
  COUNT(name) AS cnt,
  TUMBLE_START(PROCTIME(), INTERVAL '2' MINUTE) AS window_start,
  TUMBLE_END(PROCTIME(), INTERVAL '2' MINUTE) AS window_end
FROM my_user_window_kafka_datagen
GROUP BY
  age,
  TUMBLE(PROCTIME(), INTERVAL '2' MINUTE);
```



#### Kafka

> [官方文档](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/table/kafka/)

创建表并设置水位线

```sql
CREATE TABLE my_user_window_kafka (
  eventTime TIMESTAMP(3) METADATA FROM 'timestamp' VIRTUAL,
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
  'scan.startup.mode' = 'group-offsets',
  'properties.bootstrap.servers' = '192.168.1.10:9094',
  'format' = 'json'
);
```

事件时间滚动窗口(2分钟)查询

```sql
SELECT
  age,
  COUNT(name) AS cnt,
  TUMBLE_START(createTime, INTERVAL '2' MINUTE) AS window_start,
  TUMBLE_END(createTime, INTERVAL '2' MINUTE) AS window_end
FROM my_user_window_kafka
GROUP BY
  age,
  TUMBLE(createTime, INTERVAL '2' MINUTE);
```

处理时间滚动窗口(2分钟)查询

```sql
SELECT
  age,
  COUNT(name) AS cnt,
  TUMBLE_START(PROCTIME(), INTERVAL '2' MINUTE) AS window_start,
  TUMBLE_END(PROCTIME(), INTERVAL '2' MINUTE) AS window_end
FROM my_user_window_kafka
GROUP BY
  age,
  TUMBLE(PROCTIME(), INTERVAL '2' MINUTE);
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
  CAST('2024-01-01 12:00:00' AS TIMESTAMP(3))
);
```

插入数据

```
INSERT INTO my_user_window_kafka (id, name, age, score, birthday, province, city, createTime)
SELECT id, name, age, score, birthday, province, city, event_time
FROM my_user_window_kafka_datagen;
```



### Catalog

#### 实时写入数据到Hive

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



#### 实时写入数据到Hive（MinIO）

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

