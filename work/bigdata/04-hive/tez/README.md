# Hive on Tez

Hive on Tez 是 Apache Hive 的一种运行模式，利用 Apache Tez 作为执行引擎，以替代传统的 MapReduce。它通过更高效的 DAG（有向无环图）执行方式，优化任务调度和资源利用，大幅提升了查询性能和任务执行速度。适用于复杂查询和大数据分析场景。



## 配置Tez计算引擎

### 上传Tez

**下载 Tez 二进制包**

```bash
wget https://archive.apache.org/dist/tez/0.9.1/apache-tez-0.9.1-bin.tar.gz
```

**解压 Tez 二进制包**

```bash
tar -zxf apache-tez-0.9.1-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-tez-0.9.1-bin /usr/local/software/tez
```

**将 Tez JAR 文件复制到 Hive 的库目录**

```bash
cp /usr/local/software/tez/tez-*.jar $HIVE_HOME/lib
```

**将 Tez 包上传到 HDFS**

```bash
hadoop fs -put /usr/local/software/tez/share/tez.tar.gz /hive
```



### 配置 Tez

**创建配置文件**

```bash
cat > $HIVE_HOME/conf/tez-site.xml <<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- HDFS 上 Tez 包的路径 -->
    <property>
        <name>tez.lib.uris</name>
        <value>/hive/tez.tar.gz</value>
    </property>
    <!-- 使用集群的 Hadoop 库 -->
    <property>
        <name>tez.use.cluster.hadoop-libs</name>
        <value>true</value>
    </property>
</configuration>
EOF
```

### 使用 Tez

**编辑配置文件**

新增执行引擎使用Tez部分

```bash
$ vi $HIVE_HOME/conf/hive-site.xml
<configuration>
   ...
    <!-- 执行引擎使用Tez -->
    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
</configuration>
```

**重启服务**

重启 Hive 服务以应用新配置

```bash
sudo systemctl restart hive-*
```

### 验证配置

**连接到Hive**

使用 Beeline 连接到 Hive

```bash
beeline -u jdbc:hive2://bigdata01:10000 -n admin
```

**插入数据**

```sql
INSERT INTO my_table VALUES
    (5, 'ateng'),
    (6, 'kongyu');
```

**执行计算**

执行一个示例查询以确保 Tez 被用作执行引擎

```sql
SELECT count(*) FROM my_table;
```

