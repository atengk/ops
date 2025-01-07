# Hadoop3

Hadoop 3 是 Apache Hadoop 的最新版本，改进了性能、可扩展性和稳定性。它引入了新的特性，如 YARN 的资源管理器改进、HDFS 的支持多个 NameNode 以提高容错能力、以及支持 Kubernetes 部署。Hadoop 3 提供了更高效的计算和存储能力，并且优化了容错机制，增强了对大规模数据处理任务的支持，适用于大数据分析、机器学习等应用。

- [官网链接](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                                                         |
| ------------- | --------- | ------------------------------------------------------------ |
| 192.168.1.131 | bigdata01 | NameNode ResourceManager<br />JobHistoryServer DataNode NodeManager |
| 192.168.1.132 | bigdata02 | SecondaryNameNode DataNode NodeManager                       |
| 192.168.1.133 | bigdata03 | DataNode NodeManager                                         |



## 基础配置

**下载软件包**

```
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

**解压软件包**

```
tar -zxvf hadoop-3.3.6.tar.gz -C /usr/local/software/
ln -s /usr/local/software/hadoop-3.3.6 /usr/local/software/hadoop
```

**配置环境变量**

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
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_CLASSPATH=`hadoop classpath`
EOF
source ~/.bash_profile
```

**查看版本**

```
hadoop version
```



## 集群配置

在bigdata01节点配置相应文件，最后分发到其他节点

### 配置hadoop-env.sh

根据实际情况修改相关配置

```
cp $HADOOP_HOME/etc/hadoop/hadoop-env.sh{,_bak}
cat > $HADOOP_HOME/etc/hadoop/hadoop-env.sh <<"EOF"
export JAVA_HOME=/usr/local/software/jdk8
export HADOOP_HOME=/usr/local/software/hadoop
export HADOOP_HEAPSIZE_MAX=4g
export HADOOP_HEAPSIZE_MIN=1g
EOF
```

### 配置yarn-env.sh

根据实际情况修改相关配置

```
cp $HADOOP_HOME/etc/hadoop/yarn-env.sh{,_bak}
cat > $HADOOP_HOME/etc/hadoop/yarn-env.sh <<"EOF"
export YARN_RESOURCEMANAGER_HEAPSIZE=4g
export YARN_NODEMANAGER_HEAPSIZE=4g
EOF
```

### 配置mapred-env.sh

根据实际情况修改相关配置

```
cp $HADOOP_HOME/etc/hadoop/mapred-env.sh{,_bak}
cat > $HADOOP_HOME/etc/hadoop/mapred-env.sh <<"EOF"
export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=4g
EOF
```

### 配置core-site.xml

需要修改以下配置：

- fs.defaultFS：指定Hadoop文件系统的URI
- hadoop.tmp.dir：指定Hadoop的临时目录
- 其他配置根据实际情况修改

```
cat > $HADOOP_HOME/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 指定Hadoop文件系统的URI -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://bigdata01:8020</value>
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

需要修改以下配置：

- dfs.data.dir：HDFS数据目录
- dfs.namenode.name.dir：NameNode元数据存储目录
- dfs.replication: HDFS默认数据块副本数量
- 其他配置根据实际情况修改

```
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 配置HDFS数据目录，多个目录用逗号分隔 -->
    <property>
        <name>dfs.data.dir</name>
        <value>file:/data/service/hadoop/dfs/data</value>
    </property>
    <!-- 配置NameNode元数据存储目录，多个目录用逗号分隔 -->
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/data/service/hadoop/dfs/name</value>
    </property>

    <!-- namenode 处理所有客户端请求的 RPC 地址 -->
    <property>
        <name>dfs.namenode.rpc-address</name>
        <value>bigdata01:8020</value>
    </property>
    <!-- namenode RPC 服务器将绑定到的实际地址 -->
    <property>
        <name>dfs.namenode.rpc-bind-host</name>
        <value>bigdata01</value>
    </property>
    <!-- dfs namenode web ui将监听的地址和基端口 -->
    <property>
        <name>dfs.namenode.http-address</name>
        <value>bigdata01:9870</value>
    </property>
    <!-- namenode HTTP服务器将绑定到的实际地址 -->
    <property>
        <name>dfs.namenode.http-bind-host</name>
        <value>bigdata01</value>
    </property>

    <!-- secondary namenode http服务器地址和端口 -->
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>bigdata02:9868</value>
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

根据实际情况修改相关配置。如果需要分配更多的CPU和内存资源，请修改相应参数：yarn.nodemanager.resource.memory-mb、yarn.nodemanager.resource.cpu-vcores

```
cat > $HADOOP_HOME/etc/hadoop/yarn-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- ResourceManager配置 -->
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>bigdata01</value>
    </property>

    <!-- NodeManager配置 -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <!-- 最小分配的内存（以MB为单位） -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
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
        <value>/tmp/logs</value>
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

根据实际情况修改相关配置

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

根据实际情况修改相关配置

```
cat > $HADOOP_HOME/etc/hadoop/workers <<EOF
bigdata01
bigdata02
bigdata03
EOF
```

### 分发文件

bigdata01节点将相关配置文件分发到bigdata02和bigdata03节点

> 如果需要修改监听特定地址，修改**hdfs-site.xml**和**yarn-site.xml**、**mapred-site.xml**对应节点服务的地址即可

```
scp $HADOOP_HOME/etc/hadoop/{hadoop-env.sh,yarn-env.sh,mapred-env.sh,core-site.xml,hdfs-site.xml,yarn-site.xml,mapred-site.xml,workers} bigdata02:$HADOOP_HOME/etc/hadoop/
```

```
scp $HADOOP_HOME/etc/hadoop/{hadoop-env.sh,yarn-env.sh,mapred-env.sh,core-site.xml,hdfs-site.xml,yarn-site.xml,mapred-site.xml,workers} bigdata03:$HADOOP_HOME/etc/hadoop/
```



## 格式化集群

**格式化namenode**

在bigdata01节点格式化namenode

```
hdfs namenode -format
ll /data/service/hadoop/dfs
```

**重新格式化**

如果需要重新格式化，先将数据目录删除，再重新格式化

```
rm -rf /data/service/hadoop/dfs
hdfs namenode -format
```



## 启动集群

**启动hdfs**

bigdata01: NameNode DataNode
bigdata02: SecondaryNameNode DataNode
bigdata03: DataNode
NameNode RPC: hdfs://bigdata01:8020
NameNode HTTP: http://bigdata01:9870/
SecondaryNameNode HTTP: http://bigdata02:9861/

```
start-dfs.sh
```

**启动yarn**

bigdata01: NodeManager ResourceManager
bigdata02: NodeManager
bigdata03: NodeManager
http-address: http://bigdata01:8088/

```
start-yarn.sh
```

**启动historyserver**

bigdata01: JobHistoryServer
http-address: http://bigdata01:19888/

```
mapred --daemon start historyserver
```

**关闭服务**

```
mapred --daemon stop historyserver
stop-yarn.sh
stop-dfs.sh
```

## 设置服务自启

**请在对应的服务器设置各个进程的自启**

### HDFS NameNode 服务

bigdata01设置NameNode 

HDFS（Hadoop分布式文件系统）中的NameNode是整个文件系统的关键组件之一，它负责管理文件系统的命名空间和元数据信息。

**编辑配置文件**

```
[admin@bigdata01 ~]$ sudo tee /etc/systemd/system/hadoop-hdfs-namenode.service <<"EOF"
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
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-hdfs-namenode.service
sudo systemctl start hadoop-hdfs-namenode.service
sudo systemctl status hadoop-hdfs-namenode.service
```

### HDFS SecondaryNameNode 服务

bigdata02设置SecondaryNameNode 

HDFS SecondaryNameNode 是 Apache Hadoop HDFS 的一个辅助组件，它的主要作用是协助 NameNode 处理文件系统的编辑日志（Edit Log）以及内存中的文件系统镜像（FsImage）。

**编辑配置文件**

```
[admin@bigdata02 ~]$ sudo tee /etc/systemd/system/hadoop-hdfs-secondarynamenode.service <<"EOF"
[Unit]
Description=Hadoop HDFS SecondaryNameNode
Documentation=https://hadoop.apache.org
After=network.target
[Service]
Type=forking
Environment="HADOOP_HOME=/usr/local/software/hadoop"
ExecStart=/usr/local/software/hadoop/bin/hdfs --daemon start secondarynamenode
ExecStop=/usr/local/software/hadoop/bin/hdfs --daemon stop secondarynamenode
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
sudo systemctl enable hadoop-hdfs-secondarynamenode.service
sudo systemctl start hadoop-hdfs-secondarynamenode.service
sudo systemctl status hadoop-hdfs-secondarynamenode.service
```

### HDFS DataNode 服务

bigdata01、bigdata02、bigdata03设置DataNode 

HDFS（Hadoop分布式文件系统）中的DataNode是负责存储和管理数据块的关键组件之一

**编辑配置文件**

```
sudo tee /etc/systemd/system/hadoop-hdfs-datanode.service <<"EOF"
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
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-hdfs-datanode.service
sudo systemctl start hadoop-hdfs-datanode.service
sudo systemctl status hadoop-hdfs-datanode.service
```

### YARN ResourceManager 服务

bigdata01设置ResourceManager  

YARN ResourceManager（资源管理器）是 Apache Hadoop YARN（Yet Another Resource Negotiator）中的一个关键组件，它是整个资源管理系统的核心。YARN ResourceManager 主要负责整个集群资源的分配和管理，以及协调各个应用程序对资源的请求和使用。

**编辑配置文件**

```
[admin@bigdata02 ~]$ sudo tee /etc/systemd/system/hadoop-yarn-resourcemanager.service <<"EOF"
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
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-yarn-resourcemanager.service
sudo systemctl start hadoop-yarn-resourcemanager.service
sudo systemctl status hadoop-yarn-resourcemanager.service
```

### YARN NodeManager 服务

bigdata01、bigdata02、bigdata03设置NodeManager

YARN NodeManager 是 Apache Hadoop YARN（Yet Another Resource Negotiator）中的一个重要组件，负责在集群中管理和监控各个节点的资源使用情况，并执行与资源分配相关的任务。

**编辑配置文件**

```
sudo tee /etc/systemd/system/hadoop-yarn-nodemanager.service <<"EOF"
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
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-yarn-nodemanager.service
sudo systemctl start hadoop-yarn-nodemanager.service
sudo systemctl status hadoop-yarn-nodemanager.service
```

### Hadoop JobHistoryServer 服务

bigdata01设置JobHistoryServer

Hadoop JobHistoryServer 是 Hadoop 生态系统中的一个关键组件，它负责跟踪和存储 MapReduce 作业（Job）的历史信息

```
[admin@bigdata02 ~]$ sudo tee /etc/systemd/system/hadoop-mapreduce-historyserver.service <<"EOF"
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
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hadoop-mapreduce-historyserver.service
sudo systemctl start hadoop-mapreduce-historyserver.service
sudo systemctl status hadoop-mapreduce-historyserver.service
```



## 使用集群

**查看hdfs**

```
hadoop fs -df -h
```

**创建web的目录**

```
hadoop fs -mkdir /web
hadoop fs -chown web /web
```

**运行mapreduce任务**

```
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 5 5
```

