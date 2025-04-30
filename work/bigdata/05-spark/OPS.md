# Spark运维

# Spark SQL

## 创建表

### 进入SparkSQL

```
$ spark-sql
spark-sql (default)>
```

### 创建数据库

```sql
-- 创建数据库并设置hdfs存储位置和注释
CREATE DATABASE IF NOT EXISTS my_database
COMMENT 'This is a sample database for demonstration purposes.'
LOCATION 'hdfs://server01:8020/hive/warehouse/my_database';
-- 查看数据库信息
DESCRIBE DATABASE my_database;
-- 切换到my_database
use my_database;
```

### 创建普通表

TEXTFILE 存储格式

> TEXTFILE 是一种简单的文本存储格式，每行都是纯文本，适合存储人类可读的数据。TEXTFILE 格式适用于存储非结构化和文本数据，但通常在大数据环境中不如列式存储格式效率高。

```sql
-- 创建表
DROP TABLE IF EXISTS user_textfile;
CREATE TABLE IF NOT EXISTS user_textfile (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
-- 查看信息
DESCRIBE EXTENDED user_textfile;
-- 插入数据
INSERT INTO user_textfile VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob');
-- 查看数据
select * from user_textfile;
```

PARQUET 存储格式

> PARQUET 是一种列式存储格式，旨在提供高性能、高效的数据压缩和查询性能。PARQUET 通常在大数据分析场景中被广泛使用，因为它支持高效的列式存储和压缩，适用于快速分析查询。

```sql
-- 创建表
DROP TABLE IF EXISTS user_rarquet;
CREATE TABLE IF NOT EXISTS user_rarquet (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
STORED AS PARQUET;
-- 查看信息
DESCRIBE EXTENDED user_rarquet;
-- 插入数据
INSERT INTO user_rarquet VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob');
-- 查看数据
select * from user_rarquet;
```

### 创建外部表

外部表（External Table）是数据库中的一种表，其数据存储在数据库管理系统之外的外部位置，而不是被数据库系统直接管理。在大多数数据库系统中，外部表与普通表（托管表或内部表）不同，其数据不存储在数据库的默认位置，而是存储在用户指定的路径或外部存储系统中。

> 如果需要创建外部S3存储，例如MinIO，需要吧LOCATION改为's3a://test/spark/db'，还需要两个依赖hadoop-aws-3.3.4.jar（我本身Hadoop是3.3.6，spark3.5是对应Hadoop版本3.3.4）和aws-java-sdk-bundle-1.12.367.jar（直接把Hadoop tools里面的考过去也行），其他的请参考Hive文档中创建外部MinIO表。

```sql
-- 创建表
DROP TABLE IF EXISTS user_external;
CREATE EXTERNAL TABLE IF NOT EXISTS user_external (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
LOCATION '/hive/external/user_external'
STORED AS PARQUET;
-- 查看信息
DESCRIBE EXTENDED user_external;
-- 插入数据
INSERT INTO user_external VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob');
-- 查看数据
select * from user_external;
```

### 创建分区表

> 分区表是一种数据库表的组织方式，其中数据根据某个或某些列的值被划分成多个分区，每个分区存储一组具有相同或相近特征的数据。这种组织结构有助于提高查询性能、简化数据管理，并在某些情况下减少存储成本。

根据id创建分区表

```sql
-- 创建表
DROP TABLE IF EXISTS user_partitioned;
CREATE TABLE IF NOT EXISTS user_partitioned (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
PARTITIONED BY (department_id INT)
STORED AS PARQUET;
-- 查看信息
DESCRIBE EXTENDED user_partitioned;
-- 插入数据
INSERT INTO user_partitioned PARTITION (department_id = 104) VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob');
-- 查看数据
select * from user_partitioned where department_id=104;
-- 查看分区
SHOW PARTITIONS user_partitioned;
```

根据日期创建分区表

```sql
-- 创建表
DROP TABLE IF EXISTS user_partitioned2;
CREATE TABLE IF NOT EXISTS user_partitioned2 (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
PARTITIONED BY (date_partition STRING)
STORED AS PARQUET;
-- 查看信息
DESCRIBE EXTENDED user_partitioned2;
-- 插入数据
INSERT INTO user_partitioned2 PARTITION (date_partition = "2024-01-31") VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob');
-- 查看数据
select * from user_partitioned2 where date_partition="2024-01-31";
-- 查看分区
SHOW PARTITIONS user_partitioned2;
```



### 创建聚簇(分桶)表

聚簇表（Clustered Table）是一种数据库表的组织方式，它在物理存储层面上根据某个或某些列的值对数据进行聚集（Clustering）。聚簇表的目的是将具有相似或相关值的行物理上存储在一起，以提高查询性能和降低磁盘 I/O 操作。

```sql
-- 创建表
DROP TABLE IF EXISTS user_clustered;
CREATE TABLE IF NOT EXISTS user_clustered (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
CLUSTERED BY (id) INTO 5 BUCKETS
STORED AS PARQUET;
-- 查看信息
DESCRIBE EXTENDED user_clustered;
-- 插入数据
INSERT INTO user_clustered VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob'),
    (4, 'Eva'),
    (5, 'Kas');
-- 查看数据
select * from user_clustered;
```



### 创建表时指定表的附加属性

```sql
-- 创建表
DROP TABLE IF EXISTS user_properties;
CREATE TABLE IF NOT EXISTS user_properties (
    id BIGINT,
    name STRING
) COMMENT 'User Information'
TBLPROPERTIES ("created_by"="admin", "created_on"="2024-01-31")
STORED AS PARQUET;
-- 查看信息
DESCRIBE EXTENDED user_properties;
-- 插入数据
INSERT INTO user_properties VALUES
    (1, 'John'),
    (2, 'Alice'),
    (3, 'Bob');
-- 查看数据
select * from user_properties;
```



## 创建外部表

### MySQL

下载依赖

```
wget -P tools https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
```

拷贝依赖到jars下后再启动spark-sql

```
cp tools/mysql-connector-j-8.0.33.jar $SPARK_HOME/jars
```

进入SparkSQL

```
$ spark-sql
spark-sql (default)> use my_database;
spark-sql (my_database)>
```

MySQL创建表

```sql
DROP TABLE IF EXISTS my_user;
CREATE TABLE IF NOT EXISTS my_user (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,          -- 用户唯一标识，主键自动递增
    name        VARCHAR(50) DEFAULT NULL,                   -- 增加name字段长度，并设置默认值为NULL
    age         INT DEFAULT NULL,                           -- 年龄，默认为NULL
    score       DOUBLE DEFAULT 0.0,                         -- 成绩，默认为0.0
    birthday    DATE DEFAULT NULL,                          -- 生日，默认为NULL
    province    VARCHAR(50) DEFAULT NULL,                   -- 省份，增加字段长度
    city        VARCHAR(50) DEFAULT NULL,                   -- 城市，增加字段长度
    create_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),  -- 创建时间，默认当前时间
    INDEX idx_name (name),                                  -- 如果name经常用于查询，可以考虑为其加索引
    INDEX idx_province_city (province, city)                -- 如果经常根据省市进行查询，创建联合索引
);
```

创建表

```sql
-- 创建表
DROP TABLE IF EXISTS user_ext_mysql;
CREATE TABLE IF NOT EXISTS user_ext_mysql
USING org.apache.spark.sql.jdbc
OPTIONS (
  driver "com.mysql.cj.jdbc.Driver",
  url "jdbc:mysql://192.168.1.10:35725/kongyu",
  dbtable "my_user",
  user 'root',
  password 'Admin@123'
);
-- 查看信息
DESCRIBE EXTENDED user_ext_mysql;
-- 插入数据
INSERT INTO user_ext_mysql (name, age, score, birthday, province, city) VALUES ('阿腾', 25, 99.99, CAST('2025-01-24 12:12:12' AS TIMESTAMP), '重庆', '重庆');
-- 查看数据
select * from user_ext_mysql;
```

### PostgreSQL

下载依赖

```
wget -P tools https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
```

拷贝依赖到jars下后再启动spark-sql

```
cp tools/postgresql-42.7.1.jar $SPARK_HOME/jars
```

进入SparkSQL

```
$ spark-sql
spark-sql (default)> use my_database;
spark-sql (my_database)>
```

PostgreSQL创建表

```sql
DROP TABLE IF EXISTS my_user;
CREATE TABLE IF NOT EXISTS my_user (
    id          BIGSERIAL PRIMARY KEY,                         -- BIGSERIAL 自动递增主键
    name        VARCHAR(50) DEFAULT NULL,                      -- 增加 name 字段长度，默认 NULL
    age         INTEGER DEFAULT NULL,                          -- 使用 INTEGER 替代 INT
    score       DOUBLE PRECISION DEFAULT 0.0,                  -- 使用 DOUBLE PRECISION
    birthday    DATE DEFAULT NULL,                             -- 生日字段，默认 NULL
    province    VARCHAR(50) DEFAULT NULL,                      -- 省份字段，增加长度
    city        VARCHAR(50) DEFAULT NULL,                      -- 城市字段，增加长度
    create_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3)      -- 创建时间字段，默认当前时间
);
-- 创建普通索引
CREATE INDEX idx_name ON my_user(name);                       -- 为 name 字段创建普通索引
CREATE INDEX idx_province_city ON my_user(province, city);     -- 为 province 和 city 字段创建联合索引
```

创建表

```sql
-- 创建表
DROP TABLE IF EXISTS user_ext_postgresql;
CREATE TABLE IF NOT EXISTS user_ext_postgresql
USING org.apache.spark.sql.jdbc
OPTIONS (
  driver "org.postgresql.Driver",
  url "jdbc:postgresql://192.168.1.10:32297/kongyu",
  dbtable "public.my_user",
  user 'postgres',
  password 'Lingo@local_postgresql_5432'
);
-- 查看信息
DESCRIBE EXTENDED user_ext_postgresql;
-- 插入数据
INSERT INTO user_ext_postgresql (id, name, age, score, birthday, province, city) VALUES (10000, '阿腾', 25, 99.99, CAST('2025-01-24 12:12:12' AS TIMESTAMP), '重庆', '重庆');
-- 查看数据
select * from user_ext_postgresql;
```

### Doris

参考：[官方文档](https://doris.apache.org/zh-CN/docs/ecosystem/spark-doris-connector#%E4%BD%BF%E7%94%A8%E7%A4%BA%E4%BE%8B)

下载依赖

```
wget -P tools https://repo1.maven.org/maven2/org/apache/doris/spark-doris-connector-spark-3.5/24.0.0/spark-doris-connector-spark-3.5-24.0.0.jar
```

拷贝依赖到jars下后再启动spark-sql

```
cp tools/spark-doris-connector-spark-3.5-24.0.0.jar $SPARK_HOME/jars
```

进入SparkSQL

```
$ spark-sql
spark-sql (default)> use my_database;
spark-sql (my_database)>
```

Doris创建表

```sql
-- 创建表
drop table if exists my_user_doris;
create table if not exists my_user_doris
(
    id          bigint      not null auto_increment comment '主键',
    create_time datetime(3) not null default current_timestamp(3) comment '数据创建时间',
    name        varchar(20) not null comment '姓名',
    age         int comment '年龄',
    score       double comment '分数',
    birthday    datetime(3) comment '生日',
    province    varchar(50) comment '所在省份',
    city        varchar(50) comment '所在城市'
)
UNIQUE KEY(id)
COMMENT "用户表"
DISTRIBUTED BY HASH(id) BUCKETS AUTO
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1"
);
show create table my_user_doris;
-- 插入数据
insert into my_user_doris (name, age, score, birthday, province, city)
values  ('阿腾', 25, 118.124, '1993-03-15 06:34:51.619', '重庆市', '重庆市'),
        ('沈烨霖', 36, 8.124, '1993-03-15 06:34:51.619', '吉林省', '荣成'),
        ('宋文博', 28, 26.38, '1986-05-17 21:06:30.511', '广西省', '阳江'),
        ('萧伟宸', 1, 9.699, '1991-04-02 18:21:24.825', '福建省', '厦门');
```

SparkSQL创建Doris表

```sql
CREATE TEMPORARY VIEW spark_doris
   USING doris
   OPTIONS(
   "table.identifier"="kongyu.my_user_doris",
   "fenodes"="192.168.1.12:9040",
   "user"="admin",
   "password"="Admin@123"
);
```

查看数据

```sql
select * from spark_doris;
```

插入数据

```sql
insert into spark_doris (id, name, age, score, birthday, province, city, create_time)
values  (1, '阿腾', 25, 118.124, '1993-03-15 06:34:51.619', '重庆市', '重庆市', now()),
        (2, '沈烨霖', 36, 8.124, '1993-03-15 06:34:51.619', '吉林省', '荣成', now()),
        (3, '宋文博', 28, 26.38, '1986-05-17 21:06:30.511', '广西省', '阳江', now()),
        (4, '萧伟宸', 1, 9.699, '1991-04-02 18:21:24.825', '福建省', '厦门', now());
```



## Catalog

在 Spark SQL 中，**Catalog** 是用于管理数据库、表、视图、函数和其他元数据的接口。通过 Catalog，可以方便地操作元数据，也可以查看和管理当前 Spark 会话中的临时表、全局视图以及用户定义的函数。

### Doris

参考：[官方文档](https://doris.apache.org/zh-CN/docs/ecosystem/spark-doris-connector#dataframe-3)

下载依赖

```
wget -P tools https://repo1.maven.org/maven2/org/apache/doris/spark-doris-connector-spark-3.5/24.0.0/spark-doris-connector-spark-3.5-24.0.0.jar
```

拷贝依赖到jars下后再启动spark-sql

```
cp tools/spark-doris-connector-spark-3.5-24.0.0.jar $SPARK_HOME/jars
```

编辑配置文件，添加Doris Catalog的配置

```
$ vi $SPARK_HOME/conf/spark-defaults.conf
## Spark Doris Catalog
spark.sql.catalog.doris_catalog=org.apache.doris.spark.catalog.DorisTableCatalog
spark.sql.catalog.doris_catalog.doris.fenodes=192.168.1.12:9040
spark.sql.catalog.doris_catalog.doris.query.port=9030
spark.sql.catalog.doris_catalog.doris.user=admin
spark.sql.catalog.doris_catalog.doris.password=Admin@123
spark.sql.defaultCatalog=doris_catalog
```

进入SparkSQL

```
$ spark-sql
```

查看Catalog

```
spark-sql ()> SHOW CATALOGS;
doris_catalog
spark_catalog
```

查看当前使用的Catalog

```
spark-sql ()> SELECT current_catalog();
doris_catalog
```

切换Catalog

```
spark-sql ()> use doris_catalog;
```

查看数据库

```
spark-sql ()> SHOW DATABASES IN doris_catalog;
__internal_schema
kongyu_flink
kongyu
mysql
```

查看表

```
spark-sql ()> SHOW TABLES IN doris_catalog.kongyu;
my_user
example_tbl_unique
sink_my_user_spark
user_info
my_user_doris
```

在Doris中创建表

```sql
-- 创建表
drop table if exists kongyu.my_user_doris;
create table if not exists kongyu.my_user_doris
(
    id          bigint      not null auto_increment comment '主键',
    create_time datetime(3) not null default current_timestamp(3) comment '数据创建时间',
    name        varchar(20) not null comment '姓名',
    age         int comment '年龄',
    score       double comment '分数',
    birthday    datetime(3) comment '生日',
    province    varchar(50) comment '所在省份',
    city        varchar(50) comment '所在城市'
)
UNIQUE KEY(id)
COMMENT "用户表"
DISTRIBUTED BY HASH(id) BUCKETS AUTO
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1"
);
show create table kongyu.my_user_doris;
-- 插入数据
insert into kongyu.my_user_doris (name, age, score, birthday, province, city)
values  ('阿腾', 25, 118.124, '1993-03-15 06:34:51.619', '重庆市', '重庆市'),
        ('沈烨霖', 36, 8.124, '1993-03-15 06:34:51.619', '吉林省', '荣成'),
        ('宋文博', 28, 26.38, '1986-05-17 21:06:30.511', '广西省', '阳江'),
        ('萧伟宸', 1, 9.699, '1991-04-02 18:21:24.825', '福建省', '厦门');
```

查看表数据

```sql
spark-sql ()> select * from doris_catalog.kongyu.my_user_doris;
1       2025-01-25 08:55:38.202 阿腾    25      118.124 1993-03-15 06:34:51.619 重庆市  重庆市
4       2025-01-25 08:55:38.202 萧伟宸  1       9.699   1991-04-02 18:21:24.825 福建省  厦门
2       2025-01-25 08:55:38.202 沈烨霖  36      8.124   1993-03-15 06:34:51.619 吉林省  荣成
3       2025-01-25 08:55:38.202 宋文博  28      26.38   1986-05-17 22:06:30.511 广西省  阳江
Time taken: 0.206 seconds, Fetched 4 row(s)
```

插入数据

```sql
insert into doris_catalog.kongyu.my_user_doris (id, name, age, score, birthday, province, city, create_time)
values  (1, '阿腾', 25, 118.124, '1993-03-15 06:34:51.619', '重庆市', '重庆市', now()),
        (2, '沈烨霖', 36, 8.124, '1993-03-15 06:34:51.619', '吉林省', '荣成', now()),
        (3, '宋文博', 28, 26.38, '1986-05-17 21:06:30.511', '广西省', '阳江', now()),
        (4, '萧伟宸', 1, 9.699, '1991-04-02 18:21:24.825', '福建省', '厦门', now());
```



### Iceberg

参考：[使用Iceberg文档](https://atengk.github.io/ops/#/work/bigdata/06-iceberg/?id=spark)

**下载依赖包**

iceberg-spark-runtime，用于spark集成iceberg

```
wget -P tools/ https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar
```

iceberg-aws-bundle，用于spark集成iceberg后数据写入s3（MinIO）中

```
wget -P tools/ https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.6.1/iceberg-aws-bundle-1.6.1.jar
```

postgresql，用于连接数据库的JDBC驱动

```
wget -P tools/ https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
```

**拷贝依赖**

```
cp tools/{iceberg-spark-runtime-3.5_2.12-1.6.1.jar,iceberg-aws-bundle-1.6.1.jar,postgresql-42.7.1.jar} $SPARK_HOME/jars
```

**编辑配置文件**

配置Iceberg Catalog的信息

```
$ vi $SPARK_HOME/conf/spark-defaults.conf
## Spark Iceberg Catalog
spark.sql.extensions                   org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions
spark.sql.catalog.iceberg_catalog                 org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.iceberg_catalog.warehouse       s3://iceberg-bucket/warehouse
spark.sql.catalog.iceberg_catalog.s3.endpoint     http://192.168.1.13:9000
spark.sql.catalog.iceberg_catalog.io-impl         org.apache.iceberg.aws.s3.S3FileIO
spark.sql.catalog.iceberg_catalog.catalog-impl    org.apache.iceberg.jdbc.JdbcCatalog
spark.sql.catalog.iceberg_catalog.uri             jdbc:postgresql://192.168.1.10:32297/iceberg
spark.sql.catalog.iceberg_catalog.jdbc.user       postgres
spark.sql.catalog.iceberg_catalog.jdbc.password   Lingo@local_postgresql_5432
spark.sql.catalog.iceberg_catalog.jdbc.schema-version V1
spark.sql.defaultCatalog               iceberg_catalog
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

**启动SparkSQL**

```
spark-sql
```

**Catalog使用**

查看Catalog，其他Catalog不会显示出来，但是可以直接USE

```
spark-sql ()> SHOW CATALOGS;
doris_catalog
iceberg_catalog
spark_catalog
```

查看当前使用的Catalog

```
spark-sql ()> SELECT current_catalog();
iceberg_catalog
```

切换Catalog

```
spark-sql ()> use iceberg_catalog;
```

**创建表**

```
create database iceberg_catalog.spark;
use iceberg_catalog.spark;
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



## 数据查询

### 数据准备

进入 `tools/` 目录下，将 `my_user_data.zip` 数据包解压，然后上传到hdfs中

```
cd tools/
unzip -d my_user_data my_user_data.zip
hadoop fs -put my_user_data /data
hadoop fs -ls /data/my_user_data
```

### 创建表导入数据

```
$ spark-sql
spark-sql (default)> use my_database;
spark-sql (my_database)>
```

为了方便测试，这里创建文本类型的表并导入数据，生产环境建议使用PARQUET

```
CREATE TABLE my_user (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday DATE,
  province STRING,
  city STRING,
  create_time TIMESTAMP
) COMMENT 'User Information'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");
DESCRIBE EXTENDED my_user;
```

导入数据

```
LOAD DATA INPATH '/data/my_user_data/my_user_big.csv' INTO TABLE my_user;
```

查看数据

```
select * from my_user limit 10;
```

### 聚合查询

**计算总数**

```
SELECT COUNT(*) AS total_count FROM my_user;
```

**计算平均值**

```
SELECT AVG(score) AS average_score FROM my_user;
```

**计算最大值和最小值**

```
SELECT MAX(score) AS max_score, MIN(score) AS min_score FROM my_user;
```

**按列分组聚合**

```
SELECT city, AVG(score) AS average_score
FROM my_user
GROUP BY city;
```

### 复杂查询

**子查询**

```
SELECT count(*) AS count
FROM my_user
WHERE score > (SELECT AVG(score) FROM my_user);
```

**聚合与分组结合**

```
SELECT city, COUNT(*) AS count, AVG(score) AS average_score
FROM my_user
GROUP BY city
HAVING count > 1500;
```

**排序与限制**

```
SELECT id, name, score
FROM my_user
ORDER BY score DESC
LIMIT 5;
```

**使用窗口函数**

> **分区**：首先，整个结果集会根据 `province` 列的值分成多个分区。每个分区包含具有相同 `province` 值的所有行。
>
> **排序**：在每个分区内，数据会根据 `score` 列的值进行降序排序。
>
> **行号**：`ROW_NUMBER()` 为每个分区内的行分配一个唯一的递增整数值，按照排序规则（`score DESC`）赋值。排序后的第一行将获得值1，第二行将获得值2，以此类推。

```
SELECT id, name, score,
       ROW_NUMBER() OVER (PARTITION BY city ORDER BY score DESC) AS row_num
FROM my_user
LIMIT 1000;
```

**联合查询（UNION）**

```
SELECT COUNT(*)
FROM (
SELECT id, name, score FROM my_user WHERE age = 24
UNION
SELECT id, name, score FROM my_user WHERE city = '北京市'
) result;
```

**复杂过滤条件**

```
SELECT *
FROM my_user
WHERE (age BETWEEN 25 AND 35) AND (score > 80.0 OR city = 'Shanghai')
LIMIT 10;
```


