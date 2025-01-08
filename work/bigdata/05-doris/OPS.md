# Doris使用文档

数据类型，见[官网文档](https://doris.apache.org/zh-CN/docs/table-design/data-type)

数据模型，见[官网文档](https://doris.apache.org/zh-CN/docs/table-design/data-model/overview)



# 表创建

## 明细模型

https://doris.apache.org/zh-CN/docs/table-design/data-model/duplicate

**创建表**

指定了按照 timestamp、type 和 error_code 三列进行排序。

```sql
CREATE TABLE IF NOT EXISTS example_tbl_by_default
(
    `timestamp` DATETIME NOT NULL COMMENT "日志时间",
    `type` INT NOT NULL COMMENT "日志类型",
    `error_code` INT COMMENT "错误码",
    `error_msg` VARCHAR(1024) COMMENT "错误详细信息",
    `op_id` BIGINT COMMENT "负责人id",
    `op_time` DATETIME COMMENT "处理时间"
)
DUPLICATE KEY(`timestamp`, `type`, `error_code`)
COMMENT "日志表"
DISTRIBUTED BY HASH(`type`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
show create table  example_tbl_by_default\G;
```

**插入示例数据**

```sql
INSERT INTO example_tbl_by_default (`timestamp`, `type`, `error_code`, `error_msg`, `op_id`, `op_time`)
VALUES
    ('2024-07-11 10:15:00', 1, NULL, 'Divide by zero error', 1001, '2024-07-11 10:20:00'),
    ('2024-07-11 11:30:00', 2, 404, 'Not found', 1002, '2024-07-11 11:35:00'),
    ('2024-07-11 12:45:00', 1, 500, 'Internal server error', 1001, '2024-07-11 12:50:00');
```

**查询所有数据**

```
SELECT * FROM example_tbl_by_default;
```

**查询特定条件的数据**

```sql
-- 查询处理时间在特定范围内的数据
SELECT * FROM example_tbl_by_default
WHERE op_time BETWEEN '2024-07-11 10:00:00' AND '2024-07-11 12:00:00';

-- 查询日志类型为 1 的数据
SELECT * FROM example_tbl_by_default
WHERE type = 1;

-- 查询错误码不为空的数据
SELECT * FROM example_tbl_by_default
WHERE error_code IS NOT NULL;

-- 查询负责人id为 1001且处理时间晚于'2024-07-11 12:00:00'的数据
SELECT * FROM example_tbl_by_default
WHERE op_id = 1001 AND op_time > '2024-07-11 12:00:00';
```

**删除数据示例**

```
-- 删除处理时间早于'2024-07-11 10:00:00'的记录
DELETE FROM example_tbl_by_default
WHERE op_time < '2024-07-11 10:00:00';
```



## 主键模型

https://doris.apache.org/zh-CN/docs/table-design/data-model/unique

**创建表**

```sql
CREATE TABLE IF NOT EXISTS example_tbl_unique
(
    `user_id` LARGEINT NOT NULL COMMENT "用户id",
    `username` VARCHAR(50) NOT NULL COMMENT "用户昵称",
    `city` VARCHAR(20) COMMENT "用户所在城市",
    `age` SMALLINT COMMENT "用户年龄",
    `sex` TINYINT COMMENT "用户性别",
    `phone` LARGEINT COMMENT "用户电话",
    `address` VARCHAR(500) COMMENT "用户地址",
    `register_time` DATETIME COMMENT "用户注册时间"
)
UNIQUE KEY(`user_id`, `username`)
COMMENT "用户表"
DISTRIBUTED BY HASH(`user_id`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
show create table  example_tbl_unique\G;
```

**插入示例数据**

```sql
INSERT INTO example_tbl_unique (`user_id`, `username`, `city`, `age`, `sex`, `phone`, `address`, `register_time`)
VALUES
    (1, 'Alice', 'New York', 25, 1, 1234567890, '123 5th Ave', '2024-01-01 10:00:00'),
    (2, 'Bob', 'Los Angeles', 30, 0, 2345678901, '456 Sunset Blvd', '2024-01-02 11:00:00'),
    (3, 'Charlie', 'Chicago', 35, 0, 3456789012, '789 Windy St', '2024-01-03 12:00:00'),
    (4, 'Diana', 'Houston', 28, 1, 4567890123, '1010 Space Rd', '2024-01-04 13:00:00'),
    (5, 'Eve', 'Phoenix', 22, 1, 5678901234, '2020 Desert Dr', '2024-01-05 14:00:00'),
    (5, 'Eve', 'Phoenix2', 22, 1, 5678901234, '2020 Desert Dr', '2024-01-05 14:00:00');
```

**查询所有数据**

```
SELECT * FROM example_tbl_unique;
```

**查询特定条件的数据**

```sql
-- 查询年龄大于30的用户
SELECT * FROM example_tbl_unique
WHERE age > 30;

-- 查询城市为 'New York' 的用户
SELECT * FROM example_tbl_unique
WHERE city = 'New York';

-- 查询性别为女性（1）的用户
SELECT * FROM example_tbl_unique
WHERE sex = 1;

-- 查询注册时间在特定范围内的用户
SELECT * FROM example_tbl_unique
WHERE register_time BETWEEN '2024-01-01 00:00:00' AND '2024-01-03 23:59:59';
```

**查询数据统计**

```sql
-- 按城市统计用户数量
SELECT city, COUNT(*) AS user_count
FROM example_tbl_unique
GROUP BY city;

-- 按性别统计用户数量
SELECT sex, COUNT(*) AS user_count
FROM example_tbl_unique
GROUP BY sex;

-- 按注册时间统计用户数量（按天）
SELECT DATE(register_time) AS register_date, COUNT(*) AS user_count
FROM example_tbl_unique
GROUP BY DATE(register_time);
```

**更新数据示例**

```sql
-- 更新用户Alice的电话
UPDATE example_tbl_unique
SET phone = 9876543210
WHERE user_id = 1 AND username = 'Alice';

-- 将所有用户的年龄增加1岁
UPDATE example_tbl_unique
SET age = age + 1;
```

**删除数据示例**

```sql
-- 删除年龄小于25岁的用户
DELETE FROM example_tbl_unique
WHERE age < 25;

-- 删除用户ID为5的用户
DELETE FROM example_tbl_unique
WHERE user_id = 5;
```



## 聚合模型

https://doris.apache.org/zh-CN/docs/table-design/data-model/aggregate

**创建表**

```sql
CREATE TABLE IF NOT EXISTS example_tbl_agg1
(
    `user_id` LARGEINT NOT NULL COMMENT "用户id",
    `date` DATE NOT NULL COMMENT "数据灌入日期时间",
    `city` VARCHAR(20) COMMENT "用户所在城市",
    `age` SMALLINT COMMENT "用户年龄",
    `sex` TINYINT COMMENT "用户性别",
    `last_visit_date` DATETIME REPLACE DEFAULT "1970-01-01 00:00:00" COMMENT "用户最后一次访问时间",
    `cost` BIGINT SUM DEFAULT "0" COMMENT "用户总消费",
    `max_dwell_time` INT MAX DEFAULT "0" COMMENT "用户最大停留时间",
    `min_dwell_time` INT MIN DEFAULT "99999" COMMENT "用户最小停留时间"
)
AGGREGATE KEY(`user_id`, `date`, `city`, `age`, `sex`)
COMMENT "用户信息表"
DISTRIBUTED BY HASH(`user_id`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
show create table  example_tbl_agg1\G;
```

**插入示例数据**

```sql
insert into example_tbl_agg1 values
(10000,"2017-10-01","北京",20,0,"2017-10-01 06:00:00",20,10,10),
(10000,"2017-10-01","北京",20,0,"2017-10-01 07:00:00",15,2,2),
(10001,"2017-10-01","北京",30,1,"2017-10-01 17:05:45",2,22,22),
(10002,"2017-10-02","上海",20,1,"2017-10-02 12:59:12",200,5,5),
(10003,"2017-10-02","广州",32,0,"2017-10-02 11:20:00",30,11,11),
(10004,"2017-10-01","深圳",35,0,"2017-10-01 10:00:15",100,3,3),
(10004,"2017-10-03","深圳",35,0,"2017-10-03 10:20:22",11,6,6);
```

**查询所有数据**

```
SELECT * FROM example_tbl_agg1;
```

**再导入数据**

```sql
insert into example_tbl_agg1 values
(10004,"2017-10-03","深圳",35,0,"2017-10-03 11:22:00",44,19,19),
(10005,"2017-10-03","长沙",29,1,"2017-10-03 18:11:02",3,1,1);
SELECT * FROM example_tbl_agg1;
```



## 动态分区

动态分区线程的执行频率，默认为 600(10 分钟)，即每 10 分钟进行一次调度。

**动态分区表**

表 example_tbl_dynamic 分区列 timestamp 类型为 DATETIME，创建一个动态分区规则。按周分区，只保留最近 50 周的分区，并且预先创建未来 3 周的分区。

```sql
CREATE TABLE IF NOT EXISTS example_tbl_dynamic
(
    `timestamp` DATETIME NOT NULL COMMENT "日志时间",
    `type` INT NOT NULL COMMENT "日志类型",
    `error_code` INT COMMENT "错误码",
    `error_msg` VARCHAR(1024) COMMENT "错误详细信息",
    `op_id` BIGINT COMMENT "负责人id",
    `op_time` DATETIME COMMENT "处理时间"
)
COMMENT "日志表"
PARTITION BY RANGE (timestamp) (
    PARTITION pdefault VALUES [('0001-01-01 00:00:00'), ('2024-07-01 00:00:00'))
)
DISTRIBUTED BY HASH(type) BUCKETS AUTO
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1",
    "dynamic_partition.replication_num" = "1",
    "dynamic_partition.enable" = "true",
    "dynamic_partition.time_unit" = "WEEK",
    "dynamic_partition.start" = "-50",
    "dynamic_partition.end" = "3",
    "dynamic_partition.prefix" = "p",
    "dynamic_partition.buckets" = "10"
);
show create table example_tbl_dynamic\G;
```

**查看分区**

```
show partitions from example_tbl_dynamic;
```

**插入示例数据**

```sql
INSERT INTO example_tbl_dynamic (`timestamp`, `type`, `error_code`, `error_msg`, `op_id`, `op_time`)
VALUES
    ('2024-04-11 10:15:00', 1, NULL, 'Divide by zero error', 1001, '2024-07-11 10:20:00'),
    ('2024-07-12 11:30:00', 2, 404, 'Not found', 1002, '2024-07-11 11:35:00'),
    ('2024-07-13 12:45:00', 1, 500, 'Internal server error', 1001, '2024-07-11 12:50:00');
```



## 自动分区

**自动分区表**

```sql
CREATE TABLE IF NOT EXISTS example_tbl_auto
(
    `timestamp` DATETIME NOT NULL COMMENT "日志时间",
    `type` INT NOT NULL COMMENT "日志类型",
    `error_code` INT COMMENT "错误码",
    `error_msg` VARCHAR(1024) COMMENT "错误详细信息",
    `op_id` BIGINT COMMENT "负责人id",
    `op_time` DATETIME COMMENT "处理时间"
)
COMMENT "日志表"
AUTO PARTITION BY RANGE (date_trunc(`timestamp`, 'WEEK')) ()
DISTRIBUTED BY HASH(type) BUCKETS AUTO
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1"
);
show create table  example_tbl_auto\G;
```

**查看分区**

```
show partitions from example_tbl_auto;
```

**插入数据**

```sql
INSERT INTO example_tbl_auto (`timestamp`, `type`, `error_code`, `error_msg`, `op_id`, `op_time`)
VALUES
    ('2024-03-11 10:15:00', 1, NULL, 'Divide by zero error', 1001, '2024-07-11 10:20:00'),
    ('2024-04-12 11:30:00', 2, 404, 'Not found', 1002, '2024-07-11 11:35:00'),
    ('2024-05-13 12:45:00', 1, 500, 'Internal server error', 1001, '2024-07-11 12:50:00');
```



## 自动&动态分区

自 2.1.7 起，Doris 支持自动分区和动态分区同时使用。此时，二者的功能都生效：

自动分区将会自动在数据导入过程中按需创建分区；
动态分区将会自动创建、回收、转储分区。
二者语法功能不存在冲突，同时设置对应的子句/属性即可。

**自动分区与动态分区联用**

创建表

```sql
drop table if exists kongyu.my_user;
create table if not exists kongyu.my_user
(
    id          bigint      not null auto_increment comment '主键',
    create_time datetime(3) not null default current_timestamp(3) comment '数据创建时间',
    name        varchar(20) not null comment '姓名',
    age         int comment '年龄',
    score       double comment '分数',
    birthday    date comment '生日',
    province    varchar(50) comment '所在省份',
    city        varchar(50) comment '所在城市',
    date_time   datetime(3) comment '自定义时间'
) UNIQUE KEY(`id`, `create_time`)
AUTO PARTITION BY RANGE (date_trunc(`create_time`, 'week')) ()
DISTRIBUTED BY HASH(`id`) BUCKETS AUTO
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1",
    "dynamic_partition.enable" = "true",
    "dynamic_partition.prefix" = "p",
    "dynamic_partition.start" = "-100",
    "dynamic_partition.end" = "0",
    "dynamic_partition.time_unit" = "week",
    "dynamic_partition.buckets" = "10"
);
```

**查看分区**

```
show partitions from kongyu.my_user\G;
```

**插入数据**

```sql
insert into kongyu.my_user (name, age, score, birthday, province, city, date_time) values
('张三', 25, 89.5, '1998-05-12', '北京市', '北京市', '2014-12-23 14:30:00.123'),
('李四', 30, 95.0, '1993-03-08', '上海市', '上海市', '2024-02-23 15:00:00.123'),
('王五', 22, 78.0, '2001-11-20', '广东省', '广州市', '2024-05-23 15:30:00.123'),
('赵六', 28, 88.0, '1995-07-15', '浙江省', '杭州市', '2024-06-23 16:00:00.123'),
('孙七', 35, 92.5, '1988-02-25', '四川省', '成都市', '2024-09-23 16:30:00.123');
```

**查看数据**

```
select * from kongyu.my_user;
```



## 自增列

创建一个 Dupliciate 模型表，其中一个 id列是自增列

```sql
CREATE TABLE example_tbl_auto_increment1 (
      `uid` BIGINT NOT NULL,
      `name` BIGINT NOT NULL,
      `id` BIGINT NOT NULL AUTO_INCREMENT,
      `value` BIGINT NOT NULL
) ENGINE=OLAP
DUPLICATE KEY(`uid`, `name`)
DISTRIBUTED BY HASH(`uid`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
show create table  example_tbl_auto_increment1\G;

-- 插入示例数据
INSERT INTO example_tbl_auto_increment1 (`uid`, `name`, `value`)
VALUES
    (1, 100, 500),
    (2, 200, 600),
    (3, 300, 700),
    (4, 400, 800),
    (5, 500, 900);
select * from example_tbl_auto_increment1;
```

创建一个 Unique 模型表，其中一个 key 列是自增列

```sql
CREATE TABLE example_tbl_auto_increment2 (
      `id` BIGINT NOT NULL AUTO_INCREMENT,
      `name` varchar(65533) NOT NULL,
      `value` int(11) NOT NULL
) ENGINE=OLAP
UNIQUE KEY(`id`)
DISTRIBUTED BY HASH(`id`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);

-- 插入示例数据
INSERT INTO example_tbl_auto_increment2 (`name`, `value`)
VALUES
    ('Alice', 100),
    ('Bob', 200),
    ('Charlie', 300),
    ('Diana', 400),
    ('Eve', 500);
select * from example_tbl_auto_increment2;

-- 根据主键更新数据
UPDATE example_tbl_auto_increment2
SET `name` = 'Updated Name', `value` = 999
WHERE `id` = 3;
```



## 项目实战

### 自增自动动态分区表

**创建用户表**

其中主键`id`自增、`create_time`数据入库时间，使用 **UNIQUE KEY(`id`, `create_time`)**作为唯一键；AUTO PARTITION根据create_time的月份自动分区，根据id自动哈希分桶；如果BE节点多可以适当增加副本数replication_allocation。

```sql
drop table if exists kongyu.my_user;
create table if not exists kongyu.my_user
(
    id          bigint      not null auto_increment comment '主键',
    create_time datetime(3) not null default current_timestamp(3) comment '数据创建时间',
    name        varchar(20) not null comment '姓名',
    age         int comment '年龄',
    score       double comment '分数',
    birthday    date comment '生日',
    province    varchar(50) comment '所在省份',
    city        varchar(50) comment '所在城市',
    date_time   datetime(3) comment '自定义时间'
) UNIQUE KEY(`id`, `create_time`)
AUTO PARTITION BY RANGE (date_trunc(`create_time`, 'week')) ()
DISTRIBUTED BY HASH(`id`) BUCKETS AUTO
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1",
    "dynamic_partition.enable" = "true",
    "dynamic_partition.prefix" = "p",
    "dynamic_partition.start" = "-100",
    "dynamic_partition.end" = "0",
    "dynamic_partition.time_unit" = "week",
    "dynamic_partition.buckets" = "10"
);
```

**查看分区**

```sql
show partitions from kongyu.my_user\G;
```

**插入数据**

```sql
insert into kongyu.my_user (name, age, score, birthday, province, city, date_time) values
('张三', 25, 89.5, '1998-05-12', '北京市', '北京市', '2024-12-23 14:30:00.123'),
('李四', 30, 95.0, '1993-03-08', '上海市', '上海市', '2024-12-23 15:00:00.123'),
('王五', 22, 78.0, '2001-11-20', '广东省', '广州市', '2024-12-23 15:30:00.123'),
('赵六', 28, 88.0, '1995-07-15', '浙江省', '杭州市', '2024-12-23 16:00:00.123'),
('孙七', 35, 92.5, '1988-02-25', '四川省', '成都市', '2024-12-23 16:30:00.123');
```

**查看数据**

```sql
select * from kongyu.my_user;
```



# 数据导出

## 导出到MinIO

使用[Export](https://doris.apache.org/zh-CN/docs/data-operate/export/export-manual)

```sql
EXPORT TABLE example_tbl_auto_increment2 TO "s3://test/export/file_" 
PROPERTIES (
    "format" = "csv_with_names",
    "column_separator" = ",",
    "line_delimiter" = "\r\n"
) WITH s3 (
    "s3.endpoint" = "http://dev.minio.lingo.local",
    "s3.region" = "us-east-1",
    "s3.secret_key"="Admin@123",
    "s3.access_key" = "admin",
    "use_path_style"="true"
);
show export\G
```

使用[Select Into Outfile](https://doris.apache.org/zh-CN/docs/data-operate/export/outfile)

```sql
SELECT * FROM example_tbl_auto_increment2
INTO OUTFILE "s3://test/export/file_"
FORMAT AS csv_with_names
PROPERTIES(
    "column_separator" = ",", 
    "line_delimiter" = "\r\n",
    "s3.endpoint" = "http://dev.minio.lingo.local",
    "s3.region" = "us-east-1",
    "s3.access_key"= "admin",
    "s3.secret_key" = "Admin@123",
    "use_path_style"="true",
    "max_file_size" = "2048MB"
);
```

## 导出到本地

使用[Export](https://doris.apache.org/zh-CN/docs/data-operate/export/export-manual)

```sql
EXPORT TABLE example_tbl_auto_increment2 TO "file:///tmp/file_" 
PROPERTIES (
    "format" = "csv_with_names",
    "column_separator" = ","
);
show export\G
```

使用[Select Into Outfile](https://doris.apache.org/zh-CN/docs/data-operate/export/outfile)

```sql
SELECT * FROM example_tbl_auto_increment2
INTO OUTFILE "file:///tmp/file_"
FORMAT AS csv_with_names
PROPERTIES(
    "column_separator" = ","
);
```

使用[MySQL Dump](https://doris.apache.org/zh-CN/docs/data-operate/export/export-with-mysql-dump)

```
mysqldump -h127.0.0.1 -P9030 -uroot --no-tablespaces --databases demo --tables example_tbl_auto_increment2 > my_table.sql
```



# 数据导入

**创建表**

创建明细表

```sql
CREATE TABLE IF NOT EXISTS example_tbl_import
(
    `timestamp` DATETIME NOT NULL COMMENT "日志时间",
    `type` INT NOT NULL COMMENT "日志类型",
    `error_code` INT COMMENT "错误码",
    `error_msg` VARCHAR(1024) COMMENT "错误详细信息",
    `op_id` BIGINT COMMENT "负责人id",
    `op_time` DATETIME COMMENT "处理时间",
    `create_time` datetimev2(3) DEFAULT CURRENT_TIMESTAMP COMMENT "创建时间"
)
DUPLICATE KEY(`timestamp`, `type`, `error_code`)
COMMENT "日志表"
DISTRIBUTED BY HASH(`type`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
show create table  example_tbl_import\G;
```

创建自增表

```sql
CREATE TABLE example_tbl_import2 (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR NOT NULL,
    `value` BIGINT NOT NULL,
    `create_time` DATETIME(3) DEFAULT CURRENT_TIMESTAMP COMMENT "创建时间"
) ENGINE=OLAP
UNIQUE KEY(`id`)
DISTRIBUTED BY HASH(`id`) BUCKETS 1
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
show create table example_tbl_import2\G;
```

**创建数据**

明细表数据

```
cat > example_tbl_import.csv <<EOF
timestamp,type,error_code,error_msg,op_id,op_time
2024-07-11 10:15:00,1,\N,Divide by zero error,1001,2024-07-11 10:20:00
2024-07-11 12:45:00,1,500,Internal server error,1001,2024-07-11 12:50:00
2024-07-11 10:15:00,1,\N,Divide by zero error,1001,2024-07-11 10:20:00
2024-07-11 12:45:00,1,500,Internal server error,1001,2024-07-11 12:50:00
2024-07-11 10:15:00,1,\N,Divide by zero error,1001,2024-07-11 10:20:00
2024-07-11 12:45:00,1,500,Internal server error,1001,2024-07-11 12:50:00
2024-07-11 11:30:00,2,404,Not found,1002,2024-07-11 11:35:00
2024-07-11 11:30:00,2,404,Not found,1002,2024-07-11 11:35:00
2024-07-11 11:30:00,2,404,Not found,1002,2024-07-11 11:35:00
EOF
```

自增表数据

```
cat > example_tbl_import2.csv <<EOF
id,name,value
1,Alice,100
2,Bob,200
4,Diana,400
5,Eve,500
6,Alice,100
7,Bob,200
8,Charlie,300
9,Diana,400
10,Eve,500
3,Updated Name,999
EOF
```



## Stream Load

Stream Load 支持通过 HTTP 协议将本地文件或数据流导入到 Doris 中。Stream Load 是一个同步导入方式，执行导入后返回导入结果，可以通过请求的返回判断导入是否成功。一般来说，可以使用 Stream Load 导入 10GB 以下的文件，如果文件过大，建议将文件进行切分后使用 Stream Load 进行导入。Stream Load 可以保证一批导入任务的原子性，要么全部导入成功，要么全部导入失败。

- [官网链接](https://doris.apache.org/zh-CN/docs/data-operate/import/import-way/stream-load-manual)

**导入明细表数据**

导入

```sql
curl --location-trusted -u admin:Admin@123 \
    -H "Expect:100-continue" \
    -H "timeout:3000" \
    -H "label:12345" \
    -H "format:csv_with_names" \
    -H "column_separator:," \
    -H "columns:timestamp,type,error_code,error_msg,op_id,op_time,create_time=CURRENT_TIMESTAMP(3)" \
    -T example_tbl_import.csv \
    -XPUT http://127.0.0.1:9040/api/demo/example_tbl_import/_stream_load

---自定义导入指定字段
curl --location-trusted -u admin:Admin@123 \
    -T example_tbl_import.csv \
    -H "Expect:100-continue" \
    -H "timeout:3000" \
    -H "sql:insert into demo.example_tbl_import(timestamp,type,error_code,error_msg,op_id,op_time) select timestamp,type,error_code,error_msg,op_id,op_time from http_stream('column_separator'=',', 'format' = 'csv_with_names')" \
    http://127.0.0.1:9040/api/_http_stream
```

查看数据

```sql
select * from demo.example_tbl_import;
```

**导入自增表数据**

导入

> 通过添加一个虚拟列`id_dummy`来占位，这样可以忽略CSV文件中的`id`列，并正确映射`name`和`age`列到表中。

```sql
curl --location-trusted -u admin:Admin@123 \
    -H "Expect:100-continue" \
    -H "timeout:3000" \
    -H "format:csv_with_names" \
    -H "column_separator:," \
    -H "columns:id_dummy,name,value,create_time=CURRENT_TIMESTAMP(3)" \
    -T example_tbl_import2.csv \
    -XPUT http://127.0.0.1:9040/api/demo/example_tbl_import2/_stream_load

---导入大数据, group_commit: sync_mode(同步模式), async_mode(异步模式)
curl --location-trusted -u admin:Admin@123 \
    -H "Expect:100-continue" \
    -H "timeout:3000" \
    -H "group_commit:async_mode" \
    -H "format:csv_with_names" \
    -H "column_separator:," \
    -H "columns:name,value,create_time=CURRENT_TIMESTAMP(3)" \
    -T example_tbl_import2_500w.csv \
    -XPUT http://127.0.0.1:9040/api/demo/example_tbl_import2/_stream_load

---自定义导入指定字段
curl --location-trusted -u admin:Admin@123 \
    -T file_c81dfd930e08455e-949cc316eec0e13e_0.csv \
    -H "Expect:100-continue" \
    -H "timeout:3000" \
    -H "sql:insert into demo.example_tbl_import2(name,value) select name,value from http_stream('column_separator'=',', 'format' = 'csv_with_names')" \
    http://127.0.0.1:9040/api/_http_stream
```

查看数据

```
select * from demo.example_tbl_import2;
```



## [Streamloader](https://doris.apache.org/zh-CN/docs/ecosystem/doris-streamloader/)

导入单个文件 example_tbl_import2.csv

```
doris-streamloader \
  --source_file="example_tbl_import2.csv" \
  --url="http://127.0.0.1:9040" \
  -u admin -p "Admin@123" --timeout=36000 --workers=8 \
  --header="format:csv_with_names?column_separator:,?columns:id_dummy,name,value" \
  --db="demo" \
  --table="example_tbl_import2"

---大数据
doris-streamloader \
  --source_file="example_tbl_import2_500w.csv" \
  --url="http://127.0.0.1:9040" \
  -u admin -p "Admin@123" --timeout=36000 --workers=8 \
  --header="format:csv_with_names?column_separator:,?columns:name,value" \
  --db="demo" \
  --table="example_tbl_import2"
```

## [Kafka](https://doris.apache.org/zh-CN/docs/data-operate/import/routine-load-manual)

```sql
CREATE ROUTINE LOAD demo.example_routine_load_json ON example_tbl_import2
PROPERTIES
(
    "desired_concurrent_number" = "5",
    "format" = "json",
    "strict_mode" = "false",
    "max_filter_ratio"= "1.0"
)
FROM KAFKA(
    "kafka_broker_list" = "192.168.1.10:9094",
    "kafka_topic" = "ateng_doris_json",
    "property.group.id" = "doris_routine",
    "property.client.id" = "doris_routine",
    "property.kafka_default_offsets" = "OFFSET_BEGINNING"
);
```

往Kafka中写入数据

```
{"name":"ateng","value":24}
```

查看作业

```
SHOW ROUTINE LOAD FOR demo.example_routine_load_json\G;
```

查看数据

```
SELECT * FROM demo.example_tbl_import2 ORDER BY id DESC LIMIT 10;
```

暂停作业

```
PAUSE ROUTINE LOAD FOR demo.example_routine_load_json;
```

恢复作业

```
RESUME ROUTINE LOAD FOR demo.example_routine_load_json;
```

删除作业

```
STOP ROUTINE LOAD FOR demo.example_routine_load_json;
```



## Routine Load

Doris 可以通过 Routine Load 导入方式持续消费 Kafka Topic 中的数据。在提交 Routine Load 作业后，Doris 会持续运行该导入作业，实时生成导入任务不断消费 Kakfa 集群中指定 Topic 中的消息。

Routine Load 是一个流式导入作业，支持 Exactly-Once 语义，保证数据不丢不重。

- [官网链接1](https://doris.apache.org/zh-CN/docs/data-operate/import/import-way/routine-load-manual)
- [官网链接2](https://doris.apache.org/zh-CN/docs/sql-manual/sql-statements/data-modification/load-and-export/CREATE-ROUTINE-LOAD)

**创建表**

```sql
drop table if exists kongyu.my_user;
create table if not exists kongyu.my_user
(
    id          bigint      not null auto_increment comment '主键',
    create_time datetime(3) not null default current_timestamp(3) comment '数据创建时间',
    name        varchar(20) not null comment '姓名',
    age         int comment '年龄',
    score       double comment '分数',
    birthday    date comment '生日',
    province    varchar(50) comment '所在省份',
    city        varchar(50) comment '所在城市',
    date_time   datetime(3) comment '自定义时间'
) UNIQUE KEY(`id`, `create_time`)
AUTO PARTITION BY RANGE (date_trunc(`create_time`, 'month')) ()
DISTRIBUTED BY HASH(`id`) BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
```

**Kafka推送数据**

创建topic

> 根据实际情况修改partitions和replication

```
kafka-topics.sh --create \
    --topic kongyu_my_user \
    --partitions 3 --replication-factor 1 \
    --bootstrap-server 192.168.1.10:9094
```

查看topic

```
kafka-topics.sh --describe \
    --topic kongyu_my_user \
    --bootstrap-server 192.168.1.10:9094
```

使用producer生产数据

```
kafka-console-producer.sh \
    --broker-list 192.168.1.10:9094 \
    --topic kongyu_my_user
```

将以下数据粘贴到控制台中

```
{"name": "张三", "age": 25, "score": 89.5, "birthday": "1998-05-12", "province": "北京市", "city": "北京市", "date_time": "2024-12-23 14:30:00"}
{"name": "李四", "age": 30, "score": 95.0, "birthday": "1993-03-08", "province": "上海市", "city": "上海市", "date_time": "2024-12-23 15:00:00"}
{"name": "王五", "age": 22, "score": 78.0, "birthday": "2001-11-20", "province": "广东省", "city": "广州市", "date_time": "2024-12-23 15:30:00"}
{"name": "赵六", "age": 28, "score": 88.0, "birthday": "1995-07-15", "province": "浙江省", "city": "杭州市", "date_time": "2024-12-23 16:00:00"}
{"name": "孙七", "age": 35, "score": 92.5, "birthday": "1988-02-25", "province": "四川省", "city": "成都市", "date_time": "2024-12-23 16:30:00"}
```

**创建任务**

相关参数说明：

- desired_concurrent_number：期望的并发度。

- format：指定导入数据格式，默认是 csv，支持 json 格式。

- strict_mode：关闭严格模式

- max_filter_ratio：采样窗口内，允许的最大过滤率。必须在大于等于0到小于等于1之间。默认值是 0。

- max_batch_interval：每个子任务的最大运行时间，单位是秒，必须大于0，默认值为 10(s)。max_batch_interval/max_batch_rows/max_batch_size 共同形成子任务执行阈值。任一参数达到阈值，导入子任务结束，并生成新的导入子任务。

- max_batch_rows：每个子任务最多读取的行数。必须大于等于 200000。默认是 20000000。max_batch_interval/max_batch_rows/max_batch_size 共同形成子任务执行阈值。任一参数达到阈值，导入子任务结束，并生成新的导入子任务。

- max_batch_size：每个子任务最多读取的字节数。单位是字节，范围是 100MB 到 1GB。默认是 1G。max_batch_interval/max_batch_rows/max_batch_size 共同形成子任务执行阈值。任一参数达到阈值，导入子任务结束，并生成新的导入子任务。

- max_error_number：采样窗口内，允许的最大错误行数。必须大于等于 0。默认是 0，即不允许有错误行。

    采样窗口为 max_batch_rows * 10。即如果在采样窗口内，错误行数大于 max_error_number，则会导致例行作业被暂停，需要人工介入检查数据质量问题。被 where 条件过滤掉的行不算错误行。


```sql
CREATE ROUTINE LOAD kongyu.my_user_routine_load ON my_user
PROPERTIES
(
    "desired_concurrent_number" = "5",
    "format" = "json",
    "strict_mode" = "false",
    "max_filter_ratio"= "0.2",
    "max_batch_interval" = "10",
    "max_batch_rows" = "20000000",
    "max_batch_size" = "1073741824",
    "max_error_number"="10000"
)
FROM KAFKA(
    "kafka_broker_list" = "192.168.1.10:9094",
    "kafka_topic" = "kongyu_my_user",
    "property.group.id" = "my_doris_routine_load",
    "property.client.id" = "my_doris_routine_load",
    "property.kafka_default_offsets" = "OFFSET_BEGINNING"
);
```

如果Kafka的字段和Doris表中的不一致，可以使用json_root选择数据的根节点，COLUMNS()和jsonpaths按照顺序匹配字段：

```sql
CREATE ROUTINE LOAD kongyu.my_user_routine_load ON my_user
COLUMNS(name,age,score,birthday,province,city,date_time)
PROPERTIES
(
    "desired_concurrent_number" = "5",
    "format" = "json",
    "strict_mode" = "false",
    "max_filter_ratio"= "0.2",
    "max_batch_rows"="20000000",
    "max_error_number"="10000",
    "jsonpaths" = "[\"$.name\",\"$.age\",\"$.score\",\"$.birthday\",\"$.province\",\"$.city\",\"$.dateTime\"]"
)
FROM KAFKA(
    "kafka_broker_list" = "192.168.1.10:9094",
    "kafka_topic" = "kongyu_my_user",
    "property.group.id" = "my_doris_routine_load",
    "property.client.id" = "my_doris_routine_load",
    "property.kafka_default_offsets" = "OFFSET_END"
);
```

**任务管理**

查看作业

```sql
SHOW ROUTINE LOAD\G;
SHOW ROUTINE LOAD FOR kongyu.my_user_routine_load\G;
```

暂停作业

```sql
PAUSE ROUTINE LOAD FOR kongyu.my_user_routine_load;
```

恢复作业

```sql
RESUME ROUTINE LOAD FOR kongyu.my_user_routine_load;
```

删除作业

```sql
STOP ROUTINE LOAD FOR kongyu.my_user_routine_load;
```

**查看数据**

```sql
select * from kongyu.my_user;
```



# 数据备份恢复

## [数据备份](https://doris.apache.org/zh-CN/docs/admin-manual/data-admin/backup)

**创建远程仓库**

```sql
CREATE REPOSITORY `s3_repo`
WITH S3
ON LOCATION "s3://data/backups"
PROPERTIES
(
    "AWS_ENDPOINT" = "http://192.168.1.12:9000",
    "AWS_ACCESS_KEY" = "admin",
    "AWS_SECRET_KEY"="Lingo@local_minio_9000",
    "AWS_REGION" = "us-east-1"
); 
SHOW REPOSITORIES;
```

全量备份demo数据库

```sql
BACKUP SNAPSHOT demo.snapshot_label1
TO s3_repo;
SHOW BACKUP\G;
```

全量备份 demo下的表 example_tbl_auto_increment2

```sql
BACKUP SNAPSHOT demo.snapshot_label2
TO s3_repo
ON (example_tbl_auto_increment2);
SHOW BACKUP\G;
```

全量备份 demo 下除了表 example_tbl_import2的其他所有表

```sql
BACKUP SNAPSHOT demo.snapshot_label3
TO s3_repo
EXCLUDE (example_tbl_import2);
SHOW BACKUP\G;
```

查看仓库中已存在的备份

```
SHOW SNAPSHOT ON s3_repo;
```

## [数据恢复](https://doris.apache.org/zh-CN/docs/admin-manual/data-admin/restore)

从 s3_repo中恢复备份  到数据库 demo2，时间版本为 "2018-05-04-16-45-08"。恢复为 1 个副本：

```sql
RESTORE SNAPSHOT demo2.snapshot_label3
FROM s3_repo
PROPERTIES
(
    "backup_timestamp"="2024-07-13-11-44-34",
    "replication_num" = "1"
);
SHOW RESTORE\G;
show tables;
```



# 任务Job

https://doris.apache.org/zh-CN/docs/sql-manual/sql-statements/Data-Definition-Statements/Create/CREATE-JOB/

创建定时任务

```sql
CREATE JOB my_job 
ON SCHEDULE EVERY 1 MINUTE 
DO insert into demo2.example_tbl_auto_increment2(name,value) SELECT name,value FROM demo.example_tbl_auto_in
crement2;
```

查看任务

```
select * from jobs("type"="insert")\G;
select * from tasks("type"="insert")\G;
```

暂停任务

```
PAUSE JOB where jobname='my_job';
```

恢复任务

```
RESUME JOB where jobName= 'my_job';
```

删除任务

```
DROP JOB where jobName='my_job';
```



# 生成数据集

https://doris.apache.org/zh-CN/docs/benchmark/ssb



```
sudo dnf -y install make gcc
mysql -uroot -P9030 -h127.0.0.1 -e "create database ssb"
```

```
$ cd apache-doris-2.1.4-src/tools/ssb-tools/
$ vi conf/doris-cluster.conf
export FE_HOST='127.0.0.1'
export FE_HTTP_PORT=9040
export FE_QUERY_PORT=9030
export USER='root'
export PASSWORD='Admin@123'
export DB='ssb'
$ sh bin/create-ssb-tables.sh -s 100
$ sh bin/build-ssb-dbgen.sh
$ sh bin/gen-ssb-data.sh -s 100
$ sh bin/load-ssb-data.sh
```



# 创建Catalog

https://doris.apache.org/zh-CN/docs/sql-manual/sql-statements/Data-Definition-Statements/Create/CREATE-CATALOG

## MySQL

[官方文档](https://doris.apache.org/zh-CN/docs/lakehouse/database/mysql)

**创建Catalog**

```
CREATE CATALOG mysql PROPERTIES (
    "type"="jdbc",
    "user"="root",
    "password"="Admin@123",
    "jdbc_url" = "jdbc:mysql://192.168.1.10:35725/kongyu",
    "driver_url" = "http://dev.minio.lingo.local/test/mysql-connector-j-8.0.33.jar",
    "driver_class" = "com.mysql.cj.jdbc.Driver",
    "only_specified_database" = "true",
    "metadata_refresh_interval_sec" = "30"
);
show catalogs;
```

**切换Catalog和Database**

```
SWITCH mysql;
use kongyu;
```

**创建表**

```

```

**插入数据**

```
INSERT INTO my_user (name, age, score, birthday, province, city, create_time) 
VALUES 
('Alice', 30, 85.5, '1994-05-12 00:00:00', 'Guangdong', 'Guangzhou', '2024-07-24 14:06:00'),
('Bob', 25, 78.5, '1998-07-20 00:00:00', 'Beijing', 'Beijing', '2024-07-24 14:06:00'),
('Charlie', 28, 88.5, '1995-09-10 00:00:00', NULL, NULL, '2024-07-24 14:06:00');
```

**查询数据**

```
select * from my_user;
```



## PostgreSQL

[官方文档](https://doris.apache.org/zh-CN/docs/lakehouse/database/postgresql)

**创建Catalog**

```
CREATE CATALOG postgresql PROPERTIES (
    "type"="jdbc",
    "user"="postgres",
    "password"="Lingo@local_postgresql_5432",
    "jdbc_url" = "jdbc:postgresql://192.168.1.10:32297/kongyu",
    "driver_url" = "http://dev.minio.lingo.local/test/postgresql-42.7.3.jar",
    "driver_class" = "org.postgresql.Driver"
);
show catalogs;
```

**切换Catalog和Schema**

```
SWITCH postgresql;
use public; -- Schema
```

**创建表**

```

```

**插入数据**

```
INSERT INTO my_user (id, name, age, score, birthday, province, city, create_time) 
VALUES 
(2, 'Alice', 30, 85.5, '1994-05-12 00:00:00', 'Guangdong', 'Guangzhou', '2024-07-24 14:06:00'),
(3, 'Bob', 25, 78.5, '1998-07-20 00:00:00', 'Beijing', 'Beijing', '2024-07-24 14:06:00'),
(4, 'Charlie', 28, 88.5, '1995-09-10 00:00:00', NULL, NULL, '2024-07-24 14:06:00');
```

**查询数据**

```
select * from my_user;
```



## ElasticSearch

[官方文档](https://doris.apache.org/zh-CN/docs/lakehouse/database/es?_highlight=elasticsearch)

**创建Catalog**

```
CREATE CATALOG es PROPERTIES (
    "type"="es",
    "hosts"="http://192.168.1.10:30647",
    "user" = "elastic",
    "password" = "Admin@123"
);
show catalogs;
SHOW DATABASES FROM es;
SHOW TABLES FROM es.default_db;
```

**切换Catalog和Database**

```
SWITCH es;
use default_db;
```

**创建表**

```
CREATE TABLE `doe` (
  `_id` varchar COMMENT "",
  `city`  varchar COMMENT ""
) ENGINE=ELASTICSEARCH
PROPERTIES (
"index" = "doe"
);
```

**插入数据**

```

```

**查询数据**

```

```



## Hive

[官方文档](https://doris.apache.org/zh-CN/docs/lakehouse/datalake-building/hive-build?_highlight=hive)

**创建Catalog**

```
CREATE CATALOG hive PROPERTIES (
    'type'='hms',
    'hive.metastore.uris' = 'thrift://192.168.1.115:9083',
    'hadoop.username' = 'admin',
    "fs.defaultFS" = "hdfs://192.168.1.115:8020"
);
show catalogs;
```

**切换Catalog和Database**

```
SWITCH hive;
use default;
```

**创建表**

```
CREATE TABLE doris_hive_table (
  id BIGINT,
  name STRING,
  age INT,
  score DOUBLE,
  birthday DATETIME,
  province STRING,
  city STRING,
  create_time DATETIME
) ENGINE=hive
PROPERTIES (
  'file_format'='parquet'
);
show create table doris_hive_table\G;
```

**插入数据**

```
INSERT INTO doris_hive_table 
VALUES 
(1, 'Alice', 30, 85.5, '1994-05-12 00:00:00', 'Guangdong', 'Guangzhou', '2024-07-24 14:06:00'),
(2, 'Bob', 25, 78.5, '1998-07-20 00:00:00', 'Beijing', 'Beijing', '2024-07-24 14:06:00'),
(3, 'Charlie', 28, 88.5, '1995-09-10 00:00:00', NULL, NULL, '2024-07-24 14:06:00');
```

**查询数据**

```
SELECT * FROM doris_hive_table;
SELECT count(*) FROM doris_hive_table;
```



## Iceberg

https://doris.apache.org/zh-CN/docs/dev/lakehouse/datalake-analytics/iceberg/

官网没有：Iceberg+MinIO+PostgreSQL的案例

```
-- MinIO & JDBC Catalog
CREATE CATALOG `iceberg` PROPERTIES (
    "type" = "iceberg",
    "iceberg.catalog.type" = "hadoop",
    "iceberg.catalog.uri" = "jdbc:postgresql://192.168.1.10:32297/iceberg?user=postgres&password=Lingo@local_postgresql_5432",
    "warehouse" = "s3://iceberg-bucket/warehouse",
    "s3.access_key" = "admin",
    "s3.secret_key" = "Admin@123",
    "s3.endpoint" = "http://192.168.1.10:8110",
    "s3.region" = "us-east-1"
);

SWITCH iceberg;
use default;

CREATE CATALOG `iceberg` PROPERTIES (
    "type" = "iceberg",
    "iceberg.catalog.type" = "hadoop"
);

    "driver_url" = "http://dev.minio.lingo.local/test/postgresql-42.7.3.jar",
```

