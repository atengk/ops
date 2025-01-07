# 安装Flink 1.18.1



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

编辑配置文件

```
cp $FLINK_HOME/conf/flink-conf.yaml{,_bak}
cat > $FLINK_HOME/conf/flink-conf.yaml <<"EOF"
jobmanager.memory.process.size: 1g
taskmanager.memory.process.size: 2g
taskmanager.numberOfTaskSlots: 3
rest.port: 0
parallelism.default: 3
jobmanager.execution.failover-strategy: region
classloader.resolve-order: parent-first
execution.checkpointing.interval: 10s
state.backend: rocksdb
state.checkpoints.dir: hdfs://bigdata01:8020/flink/checkpoints
execution.checkpointing.externalized-checkpoint-retention: DELETE_ON_CANCELLATION
state.savepoints.dir: hdfs://bigdata01:8020/flink/savepoints
EOF
```

查看版本

```
flink --version
```



## Flink On YARN

### Application 模式

> [官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/deployment/resource-providers/yarn/)
>
> [配置参数](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/deployment/config/#kubernetes)

**带有参数的运行**

```
flink run-application -t yarn-application \
    -Dparallelism.default=3 \
    -Dtaskmanager.numberOfTaskSlots=3 \
    -Djobmanager.memory.process.size=2GB \
    -Dtaskmanager.memory.process.size=4GB \
    -Dyarn.application.name="MyFlinkWordCount" \
    $FLINK_HOME/examples/batch/WordCount.jar
```

**不带参数的运行**

> 使用flink-conf.yaml的配置

```
## 批处理任务
flink run-application -t yarn-application \
    $FLINK_HOME/examples/batch/WordCount.jar
## 流处理任务
flink run-application -t yarn-application \
    $FLINK_HOME/examples/streaming/TopSpeedWindowing.jar
```

**列出集群上正在运行的作业**

```
flink list -t yarn-application -Dyarn.application.id=application_1691633100407_0004
```

**取消正在运行的作业**

```
flink cancel -t yarn-application -Dyarn.application.id=application_1691633100407_0004 53ad035ea07250fc03f470d512d958a9
```

**停止正在运行的作业并设置保存**

> 如果flink-conf.yaml配置了state.savepoints.dir，就不需要再手动指定保存点了

```
flink stop -p hdfs://hadoop01:9000/flink/savepoints -t yarn-application -Dyarn.application.id=application_1691647811427_0010 a37708b5d8d419628a5d6008cbff695d

flink stop -t yarn-application -Dyarn.application.id=application_1691647811427_0010 a37708b5d8d419628a5d6008cbff695d
```

根据保存点启动

```
flink run-application -t yarn-application \
    -s hdfs://hadoop01:9000/flink/savepoints/savepoint-a37708-2c5ad160bcce \
    -Dparallelism.default=3 \
    -Dtaskmanager.numberOfTaskSlots=3 \
    -Djobmanager.memory.process.size=2GB \
    -Dtaskmanager.memory.process.size=4GB \
    -Dyarn.application.name="MyFlinkApplicationTest" \
    -c local.kongyu.kafka.source01 flink-maven-1.0-SNAPSHOT.jar
```



### YARN查看进程信息

**查看应用列表：**

```
yarn application -list
```

**查看应用状态：** 

```
yarn application -status <application_id>
```

**取消应用**

```
yarn application -kill <application_id>
```

**查看日志**

```
yarn logs -applicationId <application ID>
```

**查看应用资源信息**

```
yarn top
```

