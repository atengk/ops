# Iceberg

Iceberg是一个用于处理大数据的高性能表格式，支持对数据的高效读取和写入。

- [官方文档](https://iceberg.apache.org/)



## 前提条件

- 元数据存储：PostgreSQL，安装[参考链接](/work/service/postgresql/v17.2.0)，还有一个更好的元数据方案：[Polaris](https://github.com/apache/polaris)，该项目还在孵化中，等待。
- 数据存储：MinIO，安装[参考链接](/work/service/minio/v20241107)



## Spark

Iceberg可以与Apache Spark集成，使用Spark SQL进行数据操作。官方文档：[Spark Getting Started](https://iceberg.apache.org/docs/nightly/spark-getting-started/)

### 编辑配置

**下载依赖包**

iceberg-spark-runtime，用于spark集成iceberg

```
wget -P lib https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar
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
cp lib/{iceberg-spark-runtime-3.5_2.12-1.6.1.jar,iceberg-aws-bundle-1.6.1.jar,postgresql-42.7.1.jar} $SPARK_HOME/jars
```

**编辑配置文件**

注意修改以下配置

- spark.master：spark地址
- spark.sql.catalog.*：s3(MinIO)存储地址和桶、元数据PostgreSQL数据库信息

```
cp $SPARK_HOME/conf/spark-defaults.conf{,_bak}
cat > $SPARK_HOME/conf/spark-defaults.conf <<"EOF"
spark.master                           spark://bigdata01:7077
spark.eventLog.enabled                 true
spark.eventLog.dir                     /tmp/spark/spark-events
spark.history.fs.logDirectory          /tmp/spark/spark-events
spark.sql.extensions                   org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions
spark.sql.catalog.my_iceberg_catalog                 org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.my_iceberg_catalog.warehouse       s3://iceberg-bucket/warehouse
spark.sql.catalog.my_iceberg_catalog.s3.endpoint     http://192.168.1.13:9000
spark.sql.catalog.my_iceberg_catalog.io-impl         org.apache.iceberg.aws.s3.S3FileIO
spark.sql.catalog.my_iceberg_catalog.catalog-impl    org.apache.iceberg.jdbc.JdbcCatalog
spark.sql.catalog.my_iceberg_catalog.uri             jdbc:postgresql://192.168.1.10:32297/iceberg
spark.sql.catalog.my_iceberg_catalog.jdbc.user       postgres
spark.sql.catalog.my_iceberg_catalog.jdbc.password   Lingo@local_postgresql_5432
spark.sql.catalog.my_iceberg_catalog.jdbc.schema-version V1
spark.sql.defaultCatalog               my_iceberg_catalog
spark.sql.catalogImplementation        in-memory
EOF
```

**配置MinIO环境变量**

```
cat >> $SPARK_HOME/conf/spark-env.sh <<EOF
## MinIO Config
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=Lingo@local_minio_9000
export AWS_REGION=us-east-1
EOF
```

**创建目录**

```
mkdir -p /tmp/spark/spark-events
```

**重启服务**

```
sudo systemctl restart spark-*
```

### 创建表

**启动SparkSQL**

```
spark-sql
```

**创建表**

```
create database spark;
use spark;
CREATE TABLE my_user (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
) USING iceberg;
DESCRIBE EXTENDED my_user;
```

**插入数据**

```
INSERT INTO my_user VALUES 
(1, 'Alice', 30, 85.5, TIMESTAMP '1993-01-15 10:00:00', 'Beijing', 'Beijing', TIMESTAMP '2023-07-01 10:00:00'),
(2, 'Bob', 25, 90.0, TIMESTAMP '1998-06-20 14:30:00', 'Shanghai', 'Shanghai', TIMESTAMP '2023-07-01 11:00:00'),
(3, 'Carol', 28, 95.0, TIMESTAMP '1995-12-05 09:45:00', 'Guangdong', 'Guangzhou', TIMESTAMP '2023-07-02 09:00:00');
```

**查看数据**

```
SELECT * FROM my_user;
SELECT count(*) FROM my_user;
```

### 创建分区表

**创建分区表**

按日期(`t_date`)和小时(`t_hour`)进行分区

```
CREATE TABLE my_user_part (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP,
  t_date STRING,
  t_hour STRING
)
USING iceberg
PARTITIONED BY (t_date, t_hour);
DESCRIBE EXTENDED my_user_part;
```

**插入数据**

```
INSERT INTO my_user_part VALUES 
(1, 'Alice', 30, 85.5, TIMESTAMP '1993-01-15 10:00:00', 'Beijing', 'Beijing', TIMESTAMP '2023-07-01 10:00:00', '2023-07-01', '10'),
(2, 'Bob', 25, 90.0, TIMESTAMP '1998-06-20 14:30:00', 'Shanghai', 'Shanghai', TIMESTAMP '2023-07-01 11:00:00', '2023-07-01', '11'),
(3, 'Carol', 28, 95.0, TIMESTAMP '1995-12-05 09:45:00', 'Guangdong', 'Guangzhou', TIMESTAMP '2023-07-02 09:00:00', '2023-07-02', '09');
```

**查看数据**

```
SELECT * FROM my_user_part;
SELECT count(*) FROM my_user_part;
```



### **快照管理**

**查看快照**

```
SELECT * FROM spark.my_user_part.snapshots;
```

**查询特定快照的数据**

```
SELECT * FROM my_iceberg_catalog.spark.my_user_part 
FOR SYSTEM_TIME AS OF '2024-07-27 07:29:11.295';
```

**回滚到特定快照**

```
CALL my_iceberg_catalog.system.rollback_to_snapshot(
  table => 'spark.my_user_part',
  snapshot_id => 4707849331217926668
);
```

**删除快照**

删除指定快照ID的快照数据

```
CALL my_iceberg_catalog.system.expire_snapshots(
  table => 'spark.my_user_part', snapshot_ids => ARRAY(8336474812628234189,4707849331217926668)
);
```

删除指定时间前的快照数据

> 如果要删除数据，需要delete from...后再清理快照才能真正的删除数据

```
CALL my_iceberg_catalog.system.expire_snapshots(
  table => 'spark.my_user_part', older_than => TIMESTAMP '2024-07-27 07:57:24.126'
);
```



## Flink

Iceberg也可以与Apache Flink集成，利用Flink进行流式数据处理。官方文档：[Flink Getting Started](https://iceberg.apache.org/docs/latest/flink-getting-started/)

### 编辑配置

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
sudo systemctl restart flink-*
```

### 创建Catalog

**启动FlinkSQL**

```
sql-client.sh
SET sql-client.execution.result-mode=tableau;
```

**创建Catalog**

```
CREATE CATALOG my_iceberg_catalog
WITH (
    'type'='iceberg',
    'catalog-impl'='org.apache.iceberg.jdbc.JdbcCatalog',
    'io-impl'='org.apache.iceberg.aws.s3.S3FileIO',
    'uri'='jdbc:postgresql://192.168.1.10:32297/iceberg?user=postgres&password=Lingo@local_postgresql_5432',
    'warehouse'='s3://iceberg-bucket/warehouse',
    's3.endpoint'='http://192.168.1.13:9000'
);
```

**查看并切换**

```
show catalogs;
use catalog my_iceberg_catalog;
```

**创建数据库**

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
  'write.format.default' = 'parquet'
);
```

**查看表**

```
SHOW CREATE TABLE my_user;
```

**插入数据**

```
insert into my_user select * from default_catalog.default_database.my_user;
```

**查看数据**

```
SELECT * FROM my_user;
SELECT count(*) FROM my_user;
```

### **创建分区表**

**创建表**

```
CREATE TABLE my_user_part (
  id BIGINT NOT NULL,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP(3),
  province STRING,
  city STRING,
  create_time TIMESTAMP_LTZ(3),
  t_date STRING,
  t_hour STRING
) PARTITIONED BY (t_date, t_hour) WITH (
  'write.format.default' = 'parquet'
);
```

**查看表**

```
SHOW CREATE TABLE my_user_part;
```

**插入数据**

```
insert into my_user_part
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
from default_catalog.default_database.my_user;
```

**查看数据**

```
SELECT * FROM my_user_part;
SELECT count(*) FROM my_user_part;
```



### 单独创建表

**切换回默认的Catalog**

```
show catalogs;
use catalog default_catalog;
```

**创建表**

```
CREATE TABLE iceberg_flink_my_user (
    id BIGINT NOT NULL,
    name STRING,
    age INT,
    score DOUBLE,
    birthday TIMESTAMP,
    province STRING,
    city STRING,
    create_time TIMESTAMP
) WITH (
    'connector'='iceberg',
    'catalog-impl'='org.apache.iceberg.jdbc.JdbcCatalog',
    'io-impl'='org.apache.iceberg.aws.s3.S3FileIO',
    'uri'='jdbc:postgresql://192.168.1.10:32297/iceberg?user=postgres&password=Lingo@local_postgresql_5432',
    'warehouse'='s3://iceberg-bucket/warehouse',
    's3.endpoint'='http://192.168.1.13:9000',
    'catalog-name'='my_iceberg_catalog',
    'catalog-database'='flink',
    'catalog-table'='iceberg_flink_my_user'
);
```

**插入数据**

```
insert into iceberg_flink_my_user select * from my_user;
```

**查看数据**

```
SELECT * FROM iceberg_flink_my_user;
SELECT count(*) FROM iceberg_flink_my_user;
```



