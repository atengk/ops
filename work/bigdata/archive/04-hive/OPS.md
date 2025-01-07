

# 使用Hive

连接hive

```
beeline -u jdbc:hive2://bigdata01:10000 -n admin
```

创建数据库

```
CREATE DATABASE IF NOT EXISTS kongyu;
use kongyu;
```



## 创建表

### **内部表**

内部表的数据存储在 Hive 的仓库目录中，当删除表时，数据也会被删除。

```
CREATE TABLE internal_table (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
) STORED AS PARQUET;
DESCRIBE EXTENDED internal_table;
```

插入数据

```
INSERT INTO internal_table (id, name, age, score, birthday, province, city, create_time)
VALUES 
(1, 'Alice', 30, 85.5, TIMESTAMP '1994-05-12 00:00:00', 'Guangdong', 'Guangzhou', CURRENT_TIMESTAMP),
(2, 'Bob', 25, 78.5, TIMESTAMP '1998-07-20 00:00:00', 'Beijing', 'Beijing', CURRENT_TIMESTAMP),
(3, 'Charlie', 28, 88.5, TIMESTAMP '1995-09-10 00:00:00', NULL, NULL, CURRENT_TIMESTAMP);
```

查询数据

```
SELECT * FROM internal_table;
```



### **外部表**

外部表的数据存储在 Hive 的仓库目录之外，删除表时不会删除数据。

```
CREATE EXTERNAL TABLE external_table (
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
LOCATION '/data/hive/warehouse/external_table';
DESCRIBE EXTENDED external_table;
```

### **外部表**（MinIO）

外部表的数据存储在 Hive 的仓库目录之外，删除表时不会删除数据。

添加配置文件

```
$ vi $HADOOP_HOME/etc/hadoop/core-site.xml
<configuration>
    ....
    <!-- 配置S3A访问的access key -->
    <property>
        <name>fs.s3a.access.key</name>
        <value>admin</value>
    </property>

    <!-- 配置S3A访问的secret key -->
    <property>
        <name>fs.s3a.secret.key</name>
        <value>Lingo@local_minio_9000</value>
    </property>

    <!-- 配置S3A的endpoint地址 -->
    <property>
        <name>fs.s3a.endpoint</name>
        <value>http://192.168.1.12:9000</value>
    </property>

    <!-- 禁用S3A连接的SSL -->
    <property>
        <name>fs.s3a.connection.ssl.enabled</name>
        <value>false</value>
    </property>

    <!-- 启用S3A的路径风格访问 -->
    <property>
        <name>fs.s3a.path.style.access</name>
        <value>true</value>
    </property>

    <!-- 配置S3A文件系统实现 -->
    <property>
        <name>fs.s3a.impl</name>
        <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
    </property>

    <!-- 配置S3A的最大连接数 -->
    <property>
        <name>fs.s3a.connection.maximum</name>
        <value>100</value>
    </property>
</configuration>

$ vi $HIVE_HOME/conf/hive-site.xml
</configuration>
    ...
    <!-- 显式设置 hive.conf.hidden.list，排除 S3A 相关的参数-->
    <property>
        <name>hive.conf.hidden.list</name>
        <value>hive.security.authorization.manager,hive.security.metastore.authorization.manager,hive.metastore.ds.connection.password</value>
    </property>
</configuration>
```

添加依赖

```
cp $HADOOP_HOME/share/hadoop/tools/lib/{hadoop-aws-3.3.6.jar,aws-java-sdk-bundle-1.12.367.jar} $HADOOP_HOME/share/hadoop/common/lib
```

重启Hadoop YARN和Hive

```
sudo systemctl restart hadoop-yarn-* hive-*
```

创建表

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
CREATE EXTERNAL TABLE external_table_minio (
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
LOCATION 's3a://test/hive/external_table_minio';
DESCRIBE EXTENDED external_table_minio;
```

插入数据

```sql
INSERT INTO external_table_minio (id, name, age, score, birthday, province, city, create_time)
VALUES 
(1, 'Alice', 30, 85.5, TIMESTAMP '1994-05-12 00:00:00', 'Guangdong', 'Guangzhou', null),
(2, 'Bob', 25, 78.5, TIMESTAMP '1998-07-20 00:00:00', 'Beijing', 'Beijing', CURRENT_TIMESTAMP),
(3, 'Charlie', 28, 88.5, TIMESTAMP '1995-09-10 00:00:00', NULL, NULL, CURRENT_TIMESTAMP);
```

查看数据

```
select * from external_table_minio;
select count(*) from external_table_minio;
```



### **分区表**

分区表将数据按指定列分区，便于查询时的过滤和优化。

> 如果需要通过Flink实时写入数据，需要添加属性
>
> TBLPROPERTIES (
>   'sink.partition-commit.policy.kind'='metastore,success-file'
> );

```
CREATE TABLE partitioned_table (
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
STORED AS PARQUET;
```

插入数据到分区

```
ALTER TABLE partitioned_table ADD PARTITION (t_date='2024-04-07', t_hour='15');
INSERT INTO TABLE partitioned_table PARTITION (t_date='2024-04-07', t_hour='15')
VALUES 
(1, 'Alice', 30, 85.5, TIMESTAMP '1994-05-12 00:00:00', 'Guangdong', 'Guangzhou', CURRENT_TIMESTAMP),
(2, 'Bob', 25, 78.5, TIMESTAMP '1998-07-20 00:00:00', 'Beijing', 'Beijing', CURRENT_TIMESTAMP),
(3, 'Charlie', 28, 88.5, TIMESTAMP '1995-09-10 00:00:00', NULL, NULL, CURRENT_TIMESTAMP);
```

查询数据

```
SELECT * FROM partitioned_table WHERE t_date='2024-04-07' AND t_hour='15';
```



### **桶表**

桶表根据指定列进行哈希分桶，便于分布式处理。

```
CREATE TABLE bucketed_table (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
)
CLUSTERED BY (id) INTO 10 BUCKETS
STORED AS PARQUET;
```

插入数据

```
INSERT INTO bucketed_table (id, name, age, score, birthday, province, city, create_time)
VALUES 
(10, 'Jack', 24, 85.0, TIMESTAMP '1999-05-17 00:00:00', 'Hubei', 'Wuhan', CURRENT_TIMESTAMP),
(11, 'Kara', 26, 88.5, TIMESTAMP '1997-08-23 00:00:00', 'Shaanxi', 'Xi\'an', CURRENT_TIMESTAMP),
(12, 'Leo', 32, 70.0, TIMESTAMP '1985-12-01 00:00:00', 'Guangdong', 'Shenzhen', CURRENT_TIMESTAMP);
```

查询数据

```
SELECT * FROM bucketed_table WHERE id = 10;
```



## 导入导出数据

从hdfs中的文件加载

### 导入

**导出TEXTFILE文本格式**

```
LOAD DATA INPATH '/data/hive/my_user.csv' INTO TABLE internal_table;
```

**导出TEXTFILE文本格式到PARQUET格式表**

先创建一个TEXTFILE格式的中间表，将my_user.csv文件导入到这个中间表，然后在使用`INSERT INTO TABLE parquet_table SELECT * FROM textfile_table;`写入到这个表中，最后删除这个中间表。



### 导出

**导出TEXTFILE文本格式**

默认就是文本格式

```
INSERT OVERWRITE DIRECTORY '/data/hive/export/my_user'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT * FROM my_user;
```

**导出指定格式**

```
INSERT OVERWRITE DIRECTORY '/data/hive/export/internal_table'
STORED AS PARQUET
SELECT * FROM internal_table;
```



## 查询数据

### 数据准备

为了方便测试，这里创建文本类型的表并导入数据，生产环境建议使用PARQUET

```
CREATE TABLE my_user (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday TIMESTAMP,
  province STRING,
  city STRING,
  create_time TIMESTAMP
) COMMENT 'User Information'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
DESCRIBE EXTENDED my_user;
```

插入数据

```
LOAD DATA INPATH '/data/hive/my_user.csv' INTO TABLE my_user;
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
HAVING count > 150000;
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