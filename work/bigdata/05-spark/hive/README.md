# Spark3

Apache Spark 是一个开源的大数据处理框架，旨在快速处理大规模数据集。它提供了分布式计算能力，支持批处理和流处理。Spark 提供了丰富的API，支持多种编程语言（如Java、Scala、Python、R），并且能在不同的集群管理器（如Hadoop YARN、Kubernetes）上运行。Spark 通过内存计算和高度优化的执行引擎，显著提高了数据处理速度，广泛应用于数据分析、机器学习和图计算等领域。

- [官网链接](https://spark.apache.org/)



## 基础配置

**下载软件包**

```
wget https://dlcdn.apache.org/spark/spark-3.5.4/spark-3.5.4-bin-hadoop3.tgz
```

**解压软件包**

```
tar -zxvf spark-3.5.4-bin-hadoop3.tgz -C /usr/local/software/
ln -s /usr/local/software/spark-3.5.4-bin-hadoop3 /usr/local/software/spark
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## SPARK_HOME
export SPARK_HOME=/usr/local/software/spark
export PATH=$PATH:$SPARK_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
spark-shell --version
```



## Spark on Hive

Spark on Hive 是指将 Apache Spark 与 Apache Hive 集成使用，利用 Hive 的元数据管理和查询能力，同时借助 Spark 的高效计算引擎进行数据处理。这样，用户可以通过 Spark 执行 Hive 查询、SQL 操作，或使用 Spark 的 DataFrame API 来处理 Hive 中的数据。通过这种集成，Spark 能够访问 Hive 存储的数据（如 HDFS 和 HBase），并实现更高效的分析和处理。

**配置spark-defaults.conf**

根据实际的hive metastore的节点数量修改对应的spark.sql.hive.metastore.uris

```
cat >> $SPARK_HOME/conf/spark-defaults.conf <<"EOF"
## Spark on Hive
spark.sql.hive.metastore.uris thrift://bigdata01:9083,thrift://bigdata02:9083,thrift://bigdata03:9083
spark.sql.catalogImplementation hive
EOF
```

**进入spark-sql**

```
spark-sql
```

**创建数据库**

```
CREATE TABLE my_table_spark (
    id INT,
    name STRING
);
```

**插入数据**

```
INSERT INTO my_table_spark VALUES
    (1, 'John'),
    (2, 'Jane'),
    (3, 'Bob'),
    (4, 'Alice');
```

**查询数据**

```
SELECT * FROM my_table_spark;
SELECT count(*) FROM my_table_spark;
```

**进入hive查看数据**

```
beeline -u jdbc:hive2://bigdata01:10000 -n admin
SELECT * FROM my_table_spark;
```

