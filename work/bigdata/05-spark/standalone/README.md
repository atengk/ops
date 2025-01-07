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



## Spark Standalone（单机）

Spark提供了一个独立的集群管理器，允许用户在不依赖于其他资源管理器的情况下部署Spark应用程序。用户可以通过启动和配置独立的Master和Worker节点来实现集群。

这种模式仅用于开发环境，生产环境使用Spark on YARN的方式

- [官网链接](https://spark.apache.org/docs/latest/spark-standalone.html)



文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                        |
| ------------- | --------- | --------------------------- |
| 192.168.1.131 | bigdata01 | Master Worker HistoryServer |



### 集群配置

**配置spark-env.sh**

```
cat >> $SPARK_HOME/conf/spark-env.sh <<"EOF"
export JAVA_HOME=/usr/local/software/jdk8
export HADOOP_HOME=/usr/local/software/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native
export SPARK_MASTER_HOST=bigdata01
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080
export SPARK_WORKER_PORT=7078
export SPARK_WORKER_WEBUI_PORT=8081
export SPARK_DAEMON_MEMORY=1g
EOF
```

**配置worker**

```
cat > $SPARK_HOME/conf/workers <<EOF
bigdata01
EOF
```

**配置spark-defaults.conf**

```
cat >> $SPARK_HOME/conf/spark-defaults.conf <<EOF
## Spark Config
spark.eventLog.enabled true
spark.eventLog.dir hdfs://bigdata01:8020/tmp/logs/spark
spark.eventLog.rolling.enabled true
spark.eventLog.rolling.maxFileSize 128m
spark.history.ui.port 18080
spark.history.retainedApplications 50
spark.history.fs.logDirectory hdfs://bigdata01:8020/tmp/logs/spark
spark.driver.cores 1
spark.driver.memory 1g
spark.driver.memoryOverhead 1g
spark.executor.instances 2
spark.executor.cores 1
spark.executor.memory 2g
spark.executor.memoryOverhead 1g
spark.task.maxFailures 8
spark.sql.shuffle.partitions 8
spark.default.paralleism 8
EOF
```

**创建日志目录**

```
hadoop fs -mkdir /tmp/logs/spark
```

### 启动集群

**启动服务**

bigdata01: Master Worker

Master Web: http://bigdata01:8080

```
$SPARK_HOME/sbin/start-all.sh
```

**启动historyserver服务**

bigdata01: HistoryServer

HistoryServer Web: http://bigdata01:18080

```
$SPARK_HOME/sbin/start-history-server.sh
```

**关闭服务**

```
$SPARK_HOME/sbin/stop-history-server.sh
$SPARK_HOME/sbin/stop-all.sh
```

### 设置服务自启

#### Spark Master

**编辑配置文件**

```
sudo tee /etc/systemd/system/spark-master.service <<"EOF"
[Unit]
Description=Spark Master
Documentation=https://spark.apache.org
After=network.target
[Service]
Type=forking
Environment="SPARK_HOME=/usr/local/software/spark"
ExecStart=/usr/local/software/spark/sbin/spark-daemon.sh start org.apache.spark.deploy.master.Master 1
ExecStop=/usr/local/software/spark/sbin/spark-daemon.sh stop org.apache.spark.deploy.master.Master 1
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable spark-master.service
sudo systemctl start spark-master.service
sudo systemctl status spark-master.service
```

#### Spark Worker

**编辑配置文件**

```
sudo tee /etc/systemd/system/spark-worker.service <<"EOF"
[Unit]
Description=Spark Worker
Documentation=https://spark.apache.org
After=network.target
[Service]
Type=forking
Environment="SPARK_HOME=/usr/local/software/spark"
ExecStart=/usr/local/software/spark/sbin/spark-daemon.sh start org.apache.spark.deploy.worker.Worker 1 spark://bigdata01:7077
ExecStop=/usr/local/software/spark/sbin/spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable spark-worker.service
sudo systemctl start spark-worker.service
sudo systemctl status spark-worker.service
```

#### Spark HistoryServer

**编辑配置文件**

```
sudo tee /etc/systemd/system/spark-history-server.service <<"EOF"
[Unit]
Description=Spark HistoryServer
Documentation=https://spark.apache.org
After=network.target
[Service]
Type=forking
Environment="SPARK_HOME=/usr/local/software/spark"
ExecStart=/usr/local/software/spark/sbin/spark-daemon.sh start org.apache.spark.deploy.history.HistoryServer 1
ExecStop=/usr/local/software/spark/sbin/spark-daemon.sh stop org.apache.spark.deploy.history.HistoryServer 1
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable spark-history-server.service
sudo systemctl start spark-history-server.service
sudo systemctl status spark-history-server.service
```



### 使用服务

#### spark-submit

**提交任务到Spark Standalone**

```
spark-submit \
    --master spark://bigdata01:7077 \
    --deploy-mode cluster \
    --total-executor-cores 2 \
    --class org.apache.spark.examples.SparkPi \
    $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.4.jar 1000
```

#### spark-sql

**使用SparkSQL连接Spark Standalone**

没有配置Spark on Hive持久存储，使用内存模式进入默认会在当前目录下生成 `spark-warehouse` 目录

```
spark-sql \
    --conf spark.sql.catalogImplementation=in-memory \
    --conf spark.sql.legacy.createHiveTableByDefault=false \
    --master spark://bigdata01:7077 \
    --total-executor-cores 2
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

**清理目录**

```
rm -rf spark-warehouse/
```

