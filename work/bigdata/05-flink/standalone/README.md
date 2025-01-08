# Flink

Flink 是一个开源的分布式流处理框架，专注于大规模数据流的实时处理。它提供了高吞吐量、低延迟的处理能力，支持有状态和无状态的数据流操作。Flink 可以处理事件时间、窗口化、流与批处理混合等复杂场景，广泛应用于实时数据分析、实时监控、机器学习等领域。其强大的容错机制和高可扩展性，使其成为大数据领域中的重要技术之一。

- [官网链接](https://nightlies.apache.org/flink/flink-docs-release-1.19/docs/dev/datastream/overview/)



Standalone Cluster（独立集群）：在独立集群模式下，JobManager和TaskManager都运行在独立的Java进程中。这种模式仅用于开发环境，生产环境使用Flink on YARN或者Flink on K8S的方式

文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                                                         |
| ------------- | --------- | ------------------------------------------------------------ |
| 192.168.1.131 | bigdata01 | StandaloneSessionClusterEntrypoint、TaskManagerRunner、HistoryServer |



## 基础配置

**下载软件包**

```
wget https://archive.apache.org/dist/flink/flink-1.19.1/flink-1.19.1-bin-scala_2.12.tgz
```

**解压软件包**

```
tar -zxvf flink-1.19.1-bin-scala_2.12.tgz -C /usr/local/software/
ln -s /usr/local/software/flink-1.19.1 /usr/local/software/flink
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## FLINK_HOME
export FLINK_HOME=/usr/local/software/flink
export PATH=$PATH:$FLINK_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$ flink --version
Version: 1.19.1, Commit ID: 5edb5a9
```



## 服务配置

### 配置config.yaml

修改以下配置

- jobmanager.memory.process.size: jobmanager应用的内存大小，可以适当分配
- taskmanager.memory.process.size: taskmanager应用的内存大小，运行任务所有的服务，可以多给
- taskmanager.numberOfTaskSlots: 控制每个 TaskManager 上的任务槽数量，影响并行度和资源调度，可以设置为CPU的数量。
- 其他配置根据实际需求修改
- 参考官网配置[链接](https://nightlies.apache.org/flink/flink-docs-release-1.19/docs/deployment/config/)

```
cp $FLINK_HOME/conf/config.yaml{,_bak}
cat > $FLINK_HOME/conf/config.yaml <<"EOF"
# jobmanager
jobmanager:
  bind-host: 0.0.0.0
  rpc:
    address: bigdata01
    port: 6123
  memory:
    process:
      size: 1g
  execution:
    failover-strategy: region

# taskmanager
taskmanager:
  bind-host: bigdata01
  host: bigdata01
  memory:
    process:
      size: 4g
  numberOfTaskSlots: 8  # CPU核心数量

# web
rest:
  port: 8082
  address: bigdata01
  bind-address: 0.0.0.0
web:
  submit:
    enable: true
  cancel:
    enable: true
  upload:
    dir: /data/service/flink/upload
  exception-history-size: 100

# historyserver
historyserver:
  archive:
    fs:
      dir: hdfs://bigdata01:8020/tmp/flink/logs
      refresh-interval: 10000
    clean-expired-jobs: true
  web:
    address: bigdata01
    port: 8083

# 参数优化
parallelism:
  default: 1
classloader:
  resolve:
    order: parent-first
process:
  working-dir: /data/service/flink/working-dir

# 配置checkpoint和savepoint
execution:
  checkpointing:
    interval: 10s
    externalized-checkpoint-retention: DELETE_ON_CANCELLATION
    max-concurrent-checkpoints: 1
    mode: EXACTLY_ONCE
state:
  backend: rocksdb
  incremental: true
  checkpoints:
    dir: hdfs://bigdata01:8020/flink/checkpoints
  savepoints:
    dir: hdfs://bigdata01:8020/flink/savepoints
EOF
```

### 配置masters

```
cat > $FLINK_HOME/conf/masters <<EOF
bigdata01:8082
EOF
```

### 配置workers

```
cat > $FLINK_HOME/conf/workers <<EOF
bigdata01
EOF
```

### 创建日志目录

```
hadoop fs -mkdir -p /tmp/flink/logs
```



## 启动服务

**启动flink**

bigdata01: StandaloneSessionClusterEntrypoint、TaskManagerRunner

Flink Web: http://bigdata01:8082/

```
$FLINK_HOME/bin/start-cluster.sh
```

**启动history**

bigdata01: HistoryServer

Flink History Server Web: http://bigdata01:8083/

```
$FLINK_HOME/bin/historyserver.sh start
```

**停止服务**

```
$FLINK_HOME/bin/historyserver.sh stop
$FLINK_HOME/bin/stop-cluster.sh
```



## 设置自启

### 创建hadoop环境变量

```
mkdir -p /data/service/flink/config
cat > /data/service/flink/config/env.conf <<EOF
JAVA_HOME=/usr/local/software/jdk8
FLINK_HOME=/usr/local/software/flink
HADOOP_HOME=/usr/local/software/hadoop
HADOOP_CLASSPATH=$(hadoop classpath)
EOF
```



### Flink JobManager 服务

**创建配置文件**

```
sudo tee /etc/systemd/system/flink-jobmanager.service <<"EOF"
[Unit]
Description=Flink StandaloneSessionClusterEntrypoint
Documentation=https://flink.apache.org
After=network.target
[Service]
Type=simple
EnvironmentFile=/data/service/flink/config/env.conf
ExecStart=/usr/local/software/flink/bin/jobmanager.sh start-foreground
ExecStop=/usr/local/software/flink/bin/jobmanager.sh stop
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
sudo systemctl enable flink-jobmanager.service
sudo systemctl start flink-jobmanager.service
sudo systemctl status flink-jobmanager.service
```



### Flink TaskManager 服务

**创建配置文件**

```
sudo tee /etc/systemd/system/flink-taskmanager.service <<"EOF"
[Unit]
Description=Flink TaskManagerRunner
Documentation=https://flink.apache.org
After=network.target
[Service]
Type=simple
EnvironmentFile=/data/service/flink/config/env.conf
ExecStart=/usr/local/software/flink/bin/taskmanager.sh start-foreground
ExecStop=/usr/local/software/flink/bin/taskmanager.sh stop
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
sudo systemctl enable flink-taskmanager.service
sudo systemctl start flink-taskmanager.service
sudo systemctl status flink-taskmanager.service
```



### Flink Hisotry Server服务

**创建配置文件**

```
sudo tee /etc/systemd/system/flink-historyserver.service <<"EOF"
[Unit]
Description=Flink Hisotry Server
Documentation=https://flink.apache.org
After=network.target
[Service]
Type=simple
EnvironmentFile=/data/service/flink/config/env.conf
ExecStart=/usr/local/software/flink/bin/historyserver.sh start-foreground
ExecStop=/usr/local/software/flink/bin/historyserver.sh stop
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
sudo systemctl enable flink-historyserver.service
sudo systemctl start flink-historyserver.service
sudo systemctl status flink-historyserver.service
```



## 使用服务

**访问Web**

```
URL: http://bigdata01:8082
```

**提交作业到集群**

批处理任务

```
flink run \
    -m bigdata01:8082 \
    $FLINK_HOME/examples/batch/WordCount.jar
```

流处理任务

```
flink run -d \
    -m bigdata01:8082 \
    $FLINK_HOME/examples/streaming/TopSpeedWindowing.jar
```

**查看作业**

```
flink list -m bigdata01:8082
```

**取消作业**

```
flink cancel -m bigdata01:8082 33a1bd6edb65057694a91ddaf069e8b3
```

