# 安装Flink

> Apache Flink是一个框架和分布式处理引擎，用于无界和有界数据流的有状态计算。Flink被设计成可以在所有常见的集群环境中运行，以内存中的速度和任何规模执行计算。
>
> https://flink.apache.org/
>
> Standalone Cluster（独立集群）：在独立集群模式下，JobManager和TaskManager都运行在独立的Java进程中。
>
> 这种模式仅用于开发环境，生产环境使用Flink on YARN或者Flink on K8S的方式

文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                                                         |
| ------------- | --------- | ------------------------------------------------------------ |
| 192.168.1.131 | bigdata01 | StandaloneSessionClusterEntrypoint、TaskManagerRunner、HistoryServer |

## 基础环境配置

解压软件包

```
tar -zxvf flink-1.18.1-bin-scala_2.12.tgz -C /usr/local/software/
ln -s /usr/local/software/flink-1.18.1 /usr/local/software/flink
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## FLINK_HOME
export FLINK_HOME=/usr/local/software/flink
export PATH=$PATH:$FLINK_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
flink --version
```



## 服务配置

### 配置flink-conf.yaml

```
cp $FLINK_HOME/conf/flink-conf.yaml{,_bak}
cat > $FLINK_HOME/conf/flink-conf.yaml <<"EOF"
## jobmanager
jobmanager.rpc.address: bigdata01
jobmanager.rpc.port: 6123
jobmanager.bind-host: 0.0.0.0
jobmanager.memory.process.size: 1g
## taskmanager
taskmanager.bind-host: bigdata01
taskmanager.host: bigdata01
taskmanager.memory.process.size: 2g
taskmanager.numberOfTaskSlots: 8 # CPU核心数量
## web
rest.port: 8082
rest.address: bigdata01
rest.bind-address: bigdata01
web.submit.enable: true
## historyserver
jobmanager.archive.fs.dir: hdfs://bigdata01:8020/tmp/flink/logs
historyserver.web.address: bigdata01
historyserver.web.port: 8083
historyserver.archive.fs.dir: hdfs://bigdata01:8020/tmp/flink/logs
historyserver.archive.fs.refresh-interval: 10000
historyserver.web.tmpdir: /tmp/flinkhistoryserver
historyserver.archive.clean-expired-jobs: true
## 参数优化
parallelism.default: 1
jobmanager.execution.failover-strategy: region
classloader.resolve-order: parent-first
process.working-dir: /data/service/flink/working-dir
## 配置checkpoint和savepoint
execution.checkpointing.interval: 10s
state.backend: rocksdb
state.checkpoints.dir: hdfs://bigdata01:8020/flink/checkpoints
execution.checkpointing.externalized-checkpoint-retention: DELETE_ON_CANCELLATION
state.savepoints.dir: hdfs://bigdata01:8020/flink/savepoints
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

启动flink

> bigdata01: StandaloneSessionClusterEntrypoint、TaskManagerRunner
>
> Flink Web: http://bigdata01:8082/

```
$FLINK_HOME/bin/start-cluster.sh
```

启动history

> bigdata01: HistoryServer
>
> Flink History Server Web: http://bigdata01:8083/

```
$FLINK_HOME/bin/historyserver.sh start
```

停止服务

```
$FLINK_HOME/bin/historyserver.sh stop
$FLINK_HOME/bin/stop-cluster.sh
```



## 设置自启

### 创建hadoop环境变量

```
mkdir -p /data/service/flink/config
cat > /data/service/flink/config/env.conf <<EOF
JAVA_HOME=/usr/local/software/jdk1.8.0
FLINK_HOME=/usr/local/software/flink
HADOOP_HOME=/usr/local/software/hadoop
HADOOP_CLASSPATH=$(hadoop classpath)
EOF
```



> 后台进程使用**Type=simple**

### Flink JobManager 服务

```
$ sudo vi /etc/systemd/system/flink-jobmanager.service
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
```

```
sudo systemctl daemon-reload
sudo systemctl enable flink-jobmanager.service
sudo systemctl start flink-jobmanager.service
sudo systemctl status flink-jobmanager.service
```

### Flink TaskManager 服务

```
$ sudo vi /etc/systemd/system/flink-taskmanager.service
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
```

```
sudo systemctl daemon-reload
sudo systemctl enable flink-taskmanager.service
sudo systemctl start flink-taskmanager.service
sudo systemctl status flink-taskmanager.service
```

### Flink Hisotry Server服务

```
$ sudo vi /etc/systemd/system/flink-historyserver.service
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
```

```
sudo systemctl daemon-reload
sudo systemctl enable flink-historyserver.service
sudo systemctl start flink-historyserver.service
sudo systemctl status flink-historyserver.service
```



## 使用服务

提交作业到集群

```
## 批处理任务
flink run \
    -m bigdata01:8082 \
    $FLINK_HOME/examples/batch/WordCount.jar
## 流处理任务
flink run -d $FLINK_HOME/examples/streaming/TopSpeedWindowing.jar
```

查看作业

```
flink list
```

取消作业

```
flink cancel 33a1bd6edb65057694a91ddaf069e8b3
```

