# Flink

Flink 是一个开源的分布式流处理框架，专注于大规模数据流的实时处理。它提供了高吞吐量、低延迟的处理能力，支持有状态和无状态的数据流操作。Flink 可以处理事件时间、窗口化、流与批处理混合等复杂场景，广泛应用于实时数据分析、实时监控、机器学习等领域。其强大的容错机制和高可扩展性，使其成为大数据领域中的重要技术之一。

- [官网链接](https://nightlies.apache.org/flink/flink-docs-release-1.20/docs/dev/datastream/overview/)



## 基础配置

**下载软件包**

```
wget https://archive.apache.org/dist/flink/flink-1.20.0/flink-1.20.0-bin-scala_2.12.tgz
```

**解压软件包**

```
tar -zxvf flink-1.20.0-bin-scala_2.12.tgz -C /usr/local/software/
ln -s /usr/local/software/flink-1.20.0 /usr/local/software/flink
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
Version: 1.20.0, Commit ID: b1fe7b4
```

**编辑配置文件**

```
cp $FLINK_HOME/conf/config.yaml{,_bak}
cat > $FLINK_HOME/conf/config.yaml <<"EOF"
# jobmanager
jobmanager:
  memory:
    process:
      size: 1g
  execution:
    failover-strategy: region

# taskmanager
taskmanager:
  memory:
    process:
      size: 4g
  numberOfTaskSlots: 3

# web
rest:
  port: 0

# 参数优化
parallelism:
  default: 3
classloader:
  resolve:
    order: parent-first

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



## Flink On YARN

Flink on YARN 是将 Apache Flink 部署在 Hadoop YARN（Yet Another Resource Negotiator）集群上的一种方式。YARN 作为资源管理器，负责分配集群资源，Flask 在 YARN 上运行时，可以实现高效的资源管理与调度。通过这种集成，Flink 可以在大规模分布式环境中高效处理流式与批量数据，利用 YARN 的弹性和可扩展性，支持动态扩容与容错。

### Application 模式

- [官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.20/zh/docs/deployment/resource-providers/yarn/)

- [配置参数](https://nightlies.apache.org/flink/flink-docs-release-1.20/zh/docs/deployment/config/#kubernetes)

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

使用flink-conf.yaml的配置

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

如果flink-conf.yaml配置了state.savepoints.dir，就不需要再手动指定保存点了

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

