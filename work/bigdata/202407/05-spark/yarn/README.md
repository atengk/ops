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



## Spark on YARN

> 有两种部署模式可用于在 YARN 上启动 Spark 应用程序。在cluster模式下，Spark 驱动程序在集群上由 YARN 管理的应用程序主进程内运行，客户端可以在启动应用程序后离开。在client模式下，驱动程序运行在客户端进程中，应用程序主机仅用于向 YARN 请求资源。
>
> https://spark.apache.org/docs/latest/running-on-yarn.html

配置spark-env.sh

```
cp $SPARK_HOME/conf/{spark-env.sh.template,spark-env.sh}
cat >> $SPARK_HOME/conf/spark-env.sh <<"EOF"
export HADOOP_HOME=/usr/local/software/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native
EOF
```

配置spark-defaults.conf

```
cat >> $SPARK_HOME/conf/spark-defaults.conf <<"EOF"
## Spark on YARN
spark.master yarn
spark.submit.deployMode client
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

创建日志目录

```
hadoop fs -mkdir -p /tmp/logs/spark
```

运行程序

```
## 客户端运行，适合开发调试，会打印日志
spark-submit --master yarn \
    --class org.apache.spark.examples.SparkPi \
    --deploy-mode client \
    --num-executors 3 \
    $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.0.jar 1000

## 服务端运行，日志在yarn集群上
spark-submit --master yarn \
    --class org.apache.spark.examples.SparkPi \
    --deploy-mode cluster \
    --num-executors 3 \
    $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.0.jar 1000
## 查看日志
yarn logs -applicationId application_1705892301425_0025
```

