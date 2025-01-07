# 安装Spark3



## 基础环境配置

解压软件包

```
tar -zxvf spark-3.5.0-bin-hadoop3.tgz -C /usr/local/software/
ln -s /usr/local/software/spark-3.5.0-bin-hadoop3 /usr/local/software/spark
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## SPARK_HOME
export SPARK_HOME=/usr/local/software/spark
export PATH=$PATH:$SPARK_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
spark-shell --version
```



## Spark on Hive

配置spark-defaults.conf

```
cat >> $SPARK_HOME/conf/spark-defaults.conf <<"EOF"
## Spark on Hive
spark.sql.hive.metastore.uris thrift://bigdata01:9083,thrift://bigdata02:9083,thrift://bigdata03:9083
spark.sql.catalogImplementation hive
EOF
```

进入spark-sql

```
spark-sql
```

创建数据库

```
CREATE TABLE my_table (
    id INT,
    name STRING
);
```

插入数据

```
INSERT INTO my_table VALUES
    (1, 'John'),
    (2, 'Jane'),
    (3, 'Bob'),
    (4, 'Alice');
```

查询数据

```
SELECT * FROM my_table;
```

进入hive查看数据

```
hive
SELECT * FROM my_table;
```


