# 安装Hadoop3

文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                                                         |
| ------------- | --------- | ------------------------------------------------------------ |
| 192.168.1.131 | bigdata01 | NameNode ResourceManager<br />JobHistoryServer DataNode NodeManager |
| 192.168.1.132 | bigdata02 | SecondaryNameNode DataNode NodeManager                       |
| 192.168.1.133 | bigdata03 | DataNode NodeManager                                         |



## 基础环境配置

解压软件包

```
tar -zxvf hadoop-3.3.6.tar.gz -C /usr/local/software/
ln -s /usr/local/software/hadoop-3.3.6 /usr/local/software/hadoop
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## HADOOP_HOME
export HDFS_NAMENODE_USER=admin
export HDFS_DATANODE_USER=admin
export HDFS_SECONDARYNAMENODE_USER=admin
export YARN_RESOURCEMANAGER_USER=admin
export YARN_NODEMANAGER_USER=admin
export HADOOP_HOME=/usr/local/software/hadoop
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_CLASSPATH=`hadoop classpath`
EOF
source ~/.bash_profile
```

查看版本

```
hadoop version
```



## 集群配置

在bigdata01节点配置相应文件，最后分发到其他节点

### 配置hadoop-env.sh

```
cp $HADOOP_HOME/etc/hadoop/hadoop-env.sh{,_bak}
cat > $HADOOP_HOME/etc/hadoop/hadoop-env.sh <<"EOF"
export JAVA_HOME=/usr/local/software/jdk1.8.0
export HADOOP_HEAPSIZE_MAX=10g
export HADOOP_HEAPSIZE_MIN=1g
EOF
```

### 配置yarn-env.sh

```
cp $HADOOP_HOME/etc/hadoop/yarn-env.sh{,_bak}
cat > $HADOOP_HOME/etc/hadoop/yarn-env.sh <<"EOF"
export YARN_RESOURCEMANAGER_HEAPSIZE=10g
export YARN_NODEMANAGER_HEAPSIZE=10g
EOF
```

### 配置mapred-env.sh

```
cp $HADOOP_HOME/etc/hadoop/mapred-env.sh{,_bak}
cat > $HADOOP_HOME/etc/hadoop/mapred-env.sh <<"EOF"
export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=4g
EOF
```

### 配置core-site.xml

```
cat > $HADOOP_HOME/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 指定Hadoop文件系统的URI -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://atengcluster</value>
    </property>
    
    <!-- 指定zookeeper集群地址 -->
    <property>
        <name>ha.zookeeper.quorum</name>
        <value>bigdata01:2181,bigdata03:2181,bigdata03:2181</value>
    </property>

    <!-- 指定Hadoop的临时目录，用于存储临时数据和日志 -->
    <property>
        <name>hadoop.tmp.dir</name>
        <value>file:/data/service/hadoop/dfs/tmp</value>
    </property>

    <!-- 配置回收站清理间隔，单位：分钟 -->
    <property>
        <name>fs.trash.interval</name>
        <value>1440</value>
    </property>

    <!-- 配置回收站检查点（checkpoint）创建间隔，单位：分钟 -->
    <property>
        <name>fs.trash.checkpoint.interval</name>
        <value>1440</value>
    </property>

    <!-- 配置匿名用户的默认所属者 -->
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>web</value>
    </property>

    <!--配置所有节点的admin用户都可作为代理用户-->
    <property>
        <name>hadoop.proxyuser.admin.hosts</name>
        <value>*</value>
    </property>

    <!--配置admin用户能够代理的用户组为任意组-->
    <property>
        <name>hadoop.proxyuser.admin.groups</name>
        <value>*</value>
    </property>

    <!--配置admin用户能够代理的用户为任意用户-->
    <property>
        <name>hadoop.proxyuser.admin.users</name>
        <value>*</value>
    </property>
</configuration>
EOF
```

### 配置hdfs-site.xml

```
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!--指定hdfs的nameservice为atengcluster，需要和core-site.xml中的保持一致 -->
    <property>
        <name>dfs.nameservices</name>
        <value>atengcluster</value>
    </property>

    <!-- atengcluster的NameNode -->
    <property>
        <name>dfs.ha.namenodes.atengcluster</name>
        <value>bigdata01,bigdata02,bigdata03</value>
    </property>

    <!-- NameNode的RPC通信地址 -->
    <property>
        <name>dfs.namenode.rpc-address.atengcluster.bigdata01</name>
        <value>bigdata01:8020</value>
    </property>

    <!-- NameNode的http通信地址 -->
    <property>
        <name>dfs.namenode.http-address.atengcluster.bigdata01</name>
        <value>bigdata01:9870</value>
    </property>

    <!-- NameNode的RPC通信地址 -->
    <property>
        <name>dfs.namenode.rpc-address.atengcluster.bigdata02</name>
        <value>bigdata02:8020</value>
    </property>

    <!-- NameNode的http通信地址 -->
    <property>
        <name>dfs.namenode.http-address.atengcluster.bigdata02</name>
        <value>bigdata02:9870</value>
    </property>

    <!-- NameNode的RPC通信地址 -->
    <property>
        <name>dfs.namenode.rpc-address.atengcluster.bigdata03</name>
        <value>bigdata03:8020</value>
    </property>

    <!-- NameNode的http通信地址 -->
    <property>
        <name>dfs.namenode.http-address.atengcluster.bigdata03</name>
        <value>bigdata03:9870</value>
    </property>

    <!-- 指定NameNode的元数据在JournalNode上的存放位置 -->
    <property>
        <name>dfs.namenode.shared.edits.dir</name>
        <value>qjournal://bigdata01:8485;bigdata02:8485;bigdata03:8485/atengcluster</value>
    </property>

    <!-- 指定JournalNode在本地磁盘存放edits日志的位置 -->
    <property>
        <name>dfs.journalnode.edits.dir</name>
        <value>/data/service/hadoop/dfs/journaldata</value>
    </property>

    <!-- 开启NameNode失败自动切换 -->
    <property>
        <name>dfs.ha.automatic-failover.enabled.atengcluster</name>
        <value>true</value>
    </property>

    <!-- 配置失败自动切换实现方式 -->
    <property>
        <name>dfs.client.failover.proxy.provider.atengcluster</name>
        <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>

    <!-- 配置隔离机制方法，多个机制用换行分割，即每个机制暂用一行-->
    <property>
        <name>dfs.ha.fencing.methods</name>
        <value>
            sshfence
            shell(/bin/true)
        </value>
    </property>

    <!-- 使用sshfence隔离机制时需要ssh免登陆 -->
    <property>
        <name>dfs.ha.fencing.ssh.private-key-files</name>
        <value>~/.ssh/id_rsa</value>
    </property>

    <!-- 配置sshfence隔离机制超时时间 -->
    <property>
        <name>dfs.ha.fencing.ssh.connect-timeout</name>
        <value>30000</value>
    </property>

    <!-- 配置HDFS数据目录，多个目录用逗号分隔 -->
    <property>
        <name>dfs.data.dir</name>
        <value>/data/service/hadoop/dfs/data</value>
    </property>

    <!-- 配置NameNode元数据存储目录，多个目录用逗号分隔 -->
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/data/service/hadoop/dfs/name</value>
    </property>

    <!-- namenode 处理所有客户端请求的 RPC 地址 -->
    <property>
        <name>dfs.namenode.rpc-address</name>
        <!-- 指定 NameNode 的 RPC 监听地址 -->
        <value>0.0.0.0:8020</value>
    </property>
    <!-- namenode RPC 服务器将绑定到的实际地址 -->
    <property>
        <name>dfs.namenode.rpc-bind-host</name>
        <!-- 指定 NameNode 的 RPC 监听地址 -->
        <value>0.0.0.0</value>
    </property>
    <!-- dfs namenode web ui将监听的地址和基端口 -->
    <property>
        <name>dfs.namenode.http-address</name>
        <value>0.0.0.0:9870</value>
    </property>
    <!-- namenode HTTP服务器将绑定到的实际地址 -->
    <property>
        <name>dfs.namenode.http-bind-host</name>
        <value>0.0.0.0</value>
    </property>
    
        <!-- datanode服务器地址和端口，用于数据传输-->
    <property>
        <name>dfs.datanode.address</name>
        <value>0.0.0.0:9866</value>
    </property>
    <!-- datanode的http服务器地址和端口 -->
    <property>
        <name>dfs.datanode.http.address</name>
        <value>0.0.0.0:9864</value>
    </property>
    <!-- datanode ipc服务器地址和端口 -->
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>0.0.0.0:9867</value>
    </property>
    
    <!-- 设置 JournalNode 监听的 RPC 地址和端口 -->
    <property>
        <name>dfs.journalnode.rpc-address</name>
        <value>0.0.0.0:8485</value>
    </property>

    <!-- 设置 JournalNode 监听的 RPC 绑定主机 -->
    <property>
        <name>dfs.journalnode.rpc-bind-host</name>
        <value>0.0.0.0</value>
    </property>

    <!-- 设置 JournalNode 监听的 HTTP 地址和端口 -->
    <property>
        <name>dfs.journalnode.http-address</name>
        <value>0.0.0.0:8480</value>
    </property>

    <!-- 设置 JournalNode 监听的 HTTP 绑定主机 -->
    <property>
        <name>dfs.journalnode.http-bind-host</name>
        <value>0.0.0.0</value>
    </property>

    <!-- 配置HDFS默认数据块复本数量 -->
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>

    <!-- 配置HDFS默认数据块大小（单位：字节） -->
    <property>
        <name>dfs.blocksize</name>
        <value>134217728</value> <!-- 128MB -->
    </property>

    <!-- 启用HDFS权限检查 -->
    <property>
        <name>dfs.permissions.enabled</name>
        <value>true</value>
    </property>

    <!-- 配置默认的目录所有者和所属组为 "ateng" -->
    <property>
        <name>dfs.permissions.superusergroup</name>
        <value>ateng</value>
    </property>

    <!-- 配置具有修改目录所有者权限的用户和用户组 -->
    <property>
        <name>dfs.cluster.administrators</name>
        <value>root root,admin ateng,kongyu ateng</value>
    </property>

    <!-- 禁用匿名访问 -->
    <property>
        <name>hadoop.http.authentication.simple.anonymous.allowed</name>
        <value>true</value>
    </property>
</configuration>
EOF
```

### 配置yarn-site.xml

如果分配更多的CPU和内存资源，请修改相应参数：yarn.nodemanager.resource.memory-mb、yarn.nodemanager.resource.cpu-vcores

```
cat > $HADOOP_HOME/etc/hadoop/yarn-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 开启RM高可用 -->
    <property>
        <name>yarn.resourcemanager.ha.enabled</name>
        <value>true</value>
    </property>

    <!-- 指定RM的cluster id -->
    <property>
        <name>yarn.resourcemanager.cluster-id</name>
        <value>atengcluster</value>
    </property>

    <!-- 指定YARN的ResourceManager的名字 -->
    <property>
        <name>yarn.resourcemanager.ha.rm-ids</name>
        <value>bigdata01,bigdata02,bigdata03</value>
    </property>

    <!-- 指定YARN的ResourceManager的地址 -->
    <property>
        <name>yarn.resourcemanager.hostname.bigdata01</name>
        <value>bigdata01</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address.bigdata01</name>
        <value>bigdata01:8088</value>
    </property>

    <!-- 指定YARN的ResourceManager的地址 -->
    <property>
        <name>yarn.resourcemanager.hostname.bigdata02</name>
        <value>bigdata02</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address.bigdata02</name>
        <value>bigdata02:8088</value>
    </property>

    <!-- 指定YARN的ResourceManager的地址 -->
    <property>
        <name>yarn.resourcemanager.hostname.bigdata03</name>
        <value>bigdata03</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address.bigdata03</name>
        <value>bigdata03:8088</value>
    </property>

    <!-- 启用自动恢复 -->
    <property>
        <name>yarn.resourcemanager.recovery.enabled</name>
        <value>true</value>
    </property>

    <!-- 指定zookeeper集群地址 -->
    <property>
        <name>yarn.resourcemanager.zk-address</name>
        <value>bigdata01:2181,bigdata02:2181,bigdata03:2181</value>
    </property>

    <!-- reduce获取数据的方式 -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <!-- 最小分配的内存（以MB为单位） -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>128</value>
    </property>

    <!-- 最大分配的内存（以MB为单位） -->
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>4096</value>
    </property>

    <!-- NodeManager可用的总内存（以MB为单位） -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
    </property>

    <!-- 最小分配的vCores -->
    <property>
        <name>yarn.scheduler.minimum-allocation-vcores</name>
        <value>1</value>
    </property>

    <!-- 最大分配的vCores -->
    <property>
        <name>yarn.scheduler.maximum-allocation-vcores</name>
        <value>8</value>
    </property>

    <!-- 总CPU核数 -->
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>16</value>
    </property>

    <!-- 关闭虚拟内存检查 -->
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
    </property>

    <!-- 启用日志聚合 -->
    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
    </property>

    <!-- 远程应用程序日志目录，通常存储在HDFS中 -->
    <property>
        <name>yarn.nodemanager.remote-app-log-dir</name>
        <value>hdfs://atengcluster/tmp/logs</value>
    </property>

    <!-- 日志服务器URL，用于访问聚合的应用程序日志 -->
    <property>
        <name>yarn.log.server.url</name>
        <value>http://bigdata01:19888/jobhistory/logs</value>
    </property>

    <!-- 聚合的日志保留时间（以秒为单位） -->
    <property>
        <name>yarn.log-aggregation.retain-seconds</name>
        <value>604800</value>
    </property>

    <!-- 指定要聚合的日志文件类型，可以添加多个 -->
    <property>
        <name>yarn.nodemanager.log-aggregation.file-formats</name>
        <value>.out,.txt,.log</value>
    </property>

    <!-- 设置 ResourceManager 监听的主机地址，0.0.0.0 表示接受所有主机 -->
    <property>
        <name>yarn.resourcemanager.bind-host</name>
        <value>0.0.0.0</value>
    </property>

    <!-- 设置 NodeManager 监听的主机地址，0.0.0.0 表示接受所有主机 -->
    <property>
        <name>yarn.nodemanager.bind-host</name>
        <value>0.0.0.0</value>
    </property>
</configuration>
EOF
```

### 配置mapred-site.xml

如果分配更多的CPU和内存资源，请修改相应参数

```
cat > $HADOOP_HOME/etc/hadoop/mapred-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 配置MapReduce框架的任务调度器，使用YARN的容量调度器 -->
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>

    <!-- 指定MapReduce任务的内存设置（以MB为单位） -->
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>1024</value>
    </property>

    <!-- 指定MapReduce任务的最大CPU核心数 -->
    <property>
        <name>mapreduce.map.cpu.vcores</name>
        <value>1</value>
    </property>
    <property>
        <name>mapreduce.reduce.cpu.vcores</name>
        <value>1</value>
    </property>

    <!-- 指定MapReduce任务的最大尝试次数 -->
    <property>
        <name>mapreduce.map.maxattempts</name>
        <value>4</value>
    </property>
    <property>
        <name>mapreduce.reduce.maxattempts</name>
        <value>4</value>
    </property>

    <!-- 指定MapReduce任务的日志级别 -->
    <property>
        <name>mapreduce.task.log.level</name>
        <value>INFO</value>
    </property>

    <!-- 指定MapReduce任务的任务跟踪器日志级别 -->
    <property>
        <name>mapreduce.jobhistory.task.log.level</name>
        <value>INFO</value>
    </property>
    
    <!-- 配置 YARN Application Master 环境变量 -->
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
    </property>
    
    <!-- 配置 Map 任务的环境变量 -->
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
    </property>
    
    <!-- 配置 Reduce 任务的环境变量 -->
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
    </property>

    <!-- 配置 MapReduce Job History Server 的地址和端口 -->
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>0.0.0.0:10020</value>
    </property>
    
    <!-- 配置 MapReduce Job History Server Web UI 的地址和端口 -->
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>0.0.0.0:19888</value>
    </property>
</configuration>
EOF
```

### 配置workers文件

```
cat > $HADOOP_HOME/etc/hadoop/workers <<EOF
bigdata01
bigdata02
bigdata03
EOF
```

### 分发文件

bigdata01节点将相关配置文件分发到bigdata02和bigdata03节点

> 如果需要修改监听地址，修改**hdfs-site.xml**和**yarn-site.xml**、**mapred-site.xml**对应节点服务的地址即可

```
scp $HADOOP_HOME/etc/hadoop/{hadoop-env.sh,yarn-env.sh,mapred-env.sh,core-site.xml,hdfs-site.xml,yarn-site.xml,mapred-site.xml,workers} bigdata02:$HADOOP_HOME/etc/hadoop/
```

```
scp $HADOOP_HOME/etc/hadoop/{hadoop-env.sh,yarn-env.sh,mapred-env.sh,core-site.xml,hdfs-site.xml,yarn-site.xml,mapred-site.xml,workers} bigdata03:$HADOOP_HOME/etc/hadoop/
```



## 格式化集群

### 启动配置的journalnode服务

> dfs.namenode.shared.edits.dir参数上的服务器都要启动，这里是bigdata01、bigdata02、bigdata03
>
> JournalNode 是 HDFS HA（High Availability）中的关键组件，它主要用于存储 HDFS 的编辑日志（Edit Logs）以及协调 NameNode 之间的数据同步。

```
hdfs --daemon start journalnode
```

### 格式化namenode

> 保证zookeeper服务已启动，在bigdata01节点格式化namenode

```
hdfs namenode -format
ll /data/service/hadoop/dfs
hdfs zkfc -formatZK
zkCli.sh -server bigdata03:2181,bigdata03:2181,bigdata03:2181 ls /
```

### 重新格式化

> 如果需要重新格式化，先将数据目录删除，再重新格式化

```
rm -rf /data/service/hadoop/dfs
zkCli.sh deleteall /hadoop-ha
zkCli.sh deleteall /yarn-leader-election
hdfs namenode -format
hdfs zkfc -formatZK
```



## 启动集群

### 启动namenode，同步元数据

> 在bigdata01节点启动namenode服务，其他namenode节点同步元数据

```
[admin@bigdata01 ~]$ hdfs --daemon start namenode
[admin@bigdata02 ~]$ hdfs namenode -bootstrapStandby
[admin@bigdata03 ~]$ hdfs namenode -bootstrapStandby
```

### 启动hdfs

> bigdata01: NameNode DataNode JournalNode
> bigdata02: NameNode DataNode JournalNode
> bigdata03: NameNode DataNode JournalNode
> NameNode Cluster RPC: hdfs://atengcluster
> NameNode RPC: hdfs://bigdata01:8020
> NameNode HTTP: http://bigdata01:9870/

```
[admin@bigdata01 ~]$ start-dfs.sh
```

### 启动yarn

> bigdata01: NodeManager ResourceManager
> bigdata02: NodeManager ResourceManager
> bigdata03: NodeManager ResourceManager
> http-address: http://bigdata01:8088/

```
[admin@bigdata01 ~]$ start-yarn.sh
```

### 启动zkfc

> ZKFC 是 Hadoop HDFS 高可用（HA）架构中的一部分，它主要负责监控 NameNode 的健康状况，并在发生故障时执行故障切换。
>
> bigdata01: DFSZKFailoverController
> bigdata02: DFSZKFailoverController
> bigdata03: DFSZKFailoverController

```
[admin@bigdata01 ~]$ hdfs --daemon start zkfc
[admin@bigdata02 ~]$ hdfs --daemon start zkfc
[admin@bigdata03 ~]$ hdfs --daemon start zkfc
```

### 启动historyserver

> bigdata01: JobHistoryServer
> http-address: http://bigdata01:19888/

```
[admin@bigdata01 ~]$ mapred --daemon start historyserver
```

### 关闭服务

```
[admin@bigdata01 ~]$ mapred --daemon stop historyserver
[admin@bigdata01 ~]$ stop-yarn.sh
[admin@bigdata01 ~]$ stop-dfs.sh
[admin@bigdata01 ~]$ hdfs --daemon stop zkfc
[admin@bigdata02 ~]$ hdfs --daemon stop zkfc
[admin@bigdata03 ~]$ hdfs --daemon stop zkfc
```



## 设置服务自启

> **请在对应的服务器设置各个进程的自启**
>
> 后台进程使用**Type=forking**

### HDFS JournalNode 服务

> dfs.namenode.shared.edits.dir参数上的服务器都要设置，这里是bigdata01、bigdata02、bigdata03
>
> HDFS JournalNode 是 Apache Hadoop HDFS 的一个关键组件，用于提供高可用性（High Availability，HA）和容错能力。JournalNode 主要用于存储 HDFS 的编辑日志（Edit Log），这些编辑日志记录了对 HDFS 中文件和目录的所有修改操作。

```
$ sudo vi /etc/systemd/system/hadoop-hdfs-journalnode.service
[Unit]
Description=Hadoop HDFS JournalNode
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/hdfs --daemon start journalnode
ExecStop=/usr/local/software/hadoop/bin/hdfs --daemon stop journalnode
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-hdfs-journalnode.service
sudo systemctl start hadoop-hdfs-journalnode.service
sudo systemctl status hadoop-hdfs-journalnode.service
```

### HDFS NameNode 服务

> bigdata01、bigdata02、bigdata03设置NameNode 
>
> HDFS（Hadoop分布式文件系统）中的NameNode是整个文件系统的关键组件之一，它负责管理文件系统的命名空间和元数据信息。

```
$ sudo vi /etc/systemd/system/hadoop-hdfs-namenode.service
[Unit]
Description=Hadoop HDFS NameNode
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/hdfs --daemon start namenode
ExecStop=/usr/local/software/hadoop/bin/hdfs --daemon stop namenode
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-hdfs-namenode.service
sudo systemctl start hadoop-hdfs-namenode.service
sudo systemctl status hadoop-hdfs-namenode.service
```

### HDFS DataNode 服务

> bigdata01、bigdata02、bigdata03设置DataNode 
>
> HDFS（Hadoop分布式文件系统）中的DataNode是负责存储和管理数据块的关键组件之一

```
$ sudo vi /etc/systemd/system/hadoop-hdfs-datanode.service
[Unit]
Description=Hadoop HDFS DataNode
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/hdfs --daemon start datanode
ExecStop=/usr/local/software/hadoop/bin/hdfs --daemon stop datanode
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-hdfs-datanode.service
sudo systemctl start hadoop-hdfs-datanode.service
sudo systemctl status hadoop-hdfs-datanode.service
```

### HDFS ZKFC 服务

> 所有namenode节点都需要启动，这里是bigdata01、bigdata02、bigdata03
>
> HDFS ZKFC（ZooKeeper Failover Controller）是 Apache Hadoop HDFS 中的一个关键组件，它负责监视和管理 HDFS 的高可用性（High Availability，HA）解决方案中的故障转移过程。ZKFC 主要与 HDFS 的 Standby NameNode 一起工作，以实现快速故障转移和自动切换。

```
$ sudo vi /etc/systemd/system/hadoop-hdfs-zkfc.service
[Unit]
Description=Hadoop HDFS ZKFC
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/hdfs --daemon start zkfc
ExecStop=/usr/local/software/hadoop/bin/hdfs --daemon stop zkfc
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-hdfs-zkfc.service
sudo systemctl start hadoop-hdfs-zkfc.service
sudo systemctl status hadoop-hdfs-zkfc.service
```

### YARN ResourceManager 服务

> bigdata01、bigdata03、bigdata03设置ResourceManager  
>
> YARN ResourceManager（资源管理器）是 Apache Hadoop YARN（Yet Another Resource Negotiator）中的一个关键组件，它是整个资源管理系统的核心。YARN ResourceManager 主要负责整个集群资源的分配和管理，以及协调各个应用程序对资源的请求和使用。

```
$ sudo vi /etc/systemd/system/hadoop-yarn-resourcemanager.service
[Unit]
Description=Hadoop YARN ResourceManager
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/yarn --daemon start resourcemanager
ExecStop=/usr/local/software/hadoop/bin/yarn --daemon stop resourcemanager
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-yarn-resourcemanager.service
sudo systemctl start hadoop-yarn-resourcemanager.service
sudo systemctl status hadoop-yarn-resourcemanager.service
```

### YARN NodeManager 服务

> bigdata01、bigdata02、bigdata03设置NodeManager
>
> YARN NodeManager 是 Apache Hadoop YARN（Yet Another Resource Negotiator）中的一个重要组件，负责在集群中管理和监控各个节点的资源使用情况，并执行与资源分配相关的任务。

```
$ sudo vi /etc/systemd/system/hadoop-yarn-nodemanager.service
[Unit]
Description=Hadoop YARN NodeManager
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/yarn --daemon start nodemanager
ExecStop=/usr/local/software/hadoop/bin/yarn --daemon stop nodemanager
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-yarn-nodemanager.service
sudo systemctl start hadoop-yarn-nodemanager.service
sudo systemctl status hadoop-yarn-nodemanager.service
```

### Hadoop JobHistoryServer 服务

> bigdata01设置JobHistoryServer
>
> Hadoop JobHistoryServer 是 Hadoop 生态系统中的一个关键组件，它负责跟踪和存储 MapReduce 作业（Job）的历史信息

```
$ sudo vi /etc/systemd/system/hadoop-mapreduce-historyserver.service
[Unit]
Description=Hadoop MapReduce HistoryServer
Documentation=https://hadoop.apache.org
After=network.target hadoop-hdfs-namenode.service 
Requires=hadoop-hdfs-namenode.service
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/mapred --daemon start historyserver
ExecStop=/usr/local/software/hadoop/bin/mapred --daemon stop historyserver
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-mapreduce-historyserver.service
sudo systemctl start hadoop-mapreduce-historyserver.service
sudo systemctl status hadoop-mapreduce-historyserver.service
```



## 使用集群

 查看Namenode、ResourceManager状态

```
hdfs haadmin -getAllServiceState
yarn rmadmin -getAllServiceState
```

切换主节点

> 手动切换： 如果检测到主节点故障，可以手动切换到备用节点。将bigdata01的主节点切换到bigdata02

```
hdfs haadmin -failover bigdata01 bigdata02
```

查看hdfs

```
hadoop fs -df -h
```

创建web的目录

```
hadoop fs -mkdir /web
hadoop fs -chown web /web
```

运行mapreduce任务

```
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 5 5
```

