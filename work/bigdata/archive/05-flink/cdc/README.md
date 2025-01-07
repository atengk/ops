# Flink CDC

将**lib**下的依赖拷贝到**FLINK_HOME/lib**



参考文档：

https://nightlies.apache.org/flink/flink-cdc-docs-release-3.1/zh/docs/get-started/quickstart/mysql-to-doris/

https://doris.apache.org/zh-CN/docs/ecosystem/flink-doris-connector#%E4%BD%BF%E7%94%A8-flinkcdc-%E6%8E%A5%E5%85%A5%E5%A4%9A%E8%A1%A8%E6%88%96%E6%95%B4%E5%BA%93-%E6%94%AF%E6%8C%81-mysqloraclepostgresqlsqlserver



## 使用flink-cdc.sh

**解压软件包**

```
tar -zxf flink-cdc-3.1.1-bin.tar.gz
cd flink-cdc-3.1.1
```

**创建配置文件**

### MySQL => Doris

```
$ cat mysql-to-doris.yaml
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
 fenodes: 192.168.1.115:9030
 username: root
 password: "Admin@123"

pipeline:
 name: Sync MySQL Database to Doris
 parallelism: 4
```

### MySQL => Kafka

```
$ cat mysql-to-kafka.yaml
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

pipeline:
 name: Sync MySQL Database to Kafka
 parallelism: 4
```

运行cdc

```
bin/flink-cdc.sh mysql-to-kafka.yaml
```



## 创建MySQL CDC

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
  'fenodes' = '192.168.1.115:9040',
  'table.identifier' = 'kongyu_flink.my_user',
  'username' = 'root',
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



## 创建PostgreSQL CDC

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



## 创建MongoDB CDC

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

创建Postgresql CDC

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

