# Hive3

Hive 是基于 Hadoop 的数据仓库软件，用于存储、管理和查询大型分布式数据集。它支持 SQL 查询（HiveQL），方便数据分析，适合批量处理和 ETL 工作。Hive 3 增强了性能，增加了事务支持（ACID），并通过 LLAP 提升了交互式查询速度，是大数据生态的重要组件。

- [官网链接](https://hive.apache.org/)



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                  |
| ------------- | --------- | --------------------- |
| 192.168.1.131 | bigdata01 | Metastore HiveServer2 |
| 192.168.1.132 | bigdata02 | Metastore HiveServer2 |
| 192.168.1.133 | bigdata03 | Metastore HiveServer2 |



## 前置条件

- 参考：[安装MySQL](/work/service/mysql/v8.4.3/)

## 基础配置

**下载软件包**

```
wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
```

**解压软件包**

```
tar -zxvf apache-hive-3.1.3-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-hive-3.1.3-bin /usr/local/software/hive
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## HIVE_HOME
export HIVE_HOME=/usr/local/software/hive
export PATH=$PATH:$HIVE_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$ hive --version
Hive 3.1.3
Git git://MacBook-Pro.fios-router.home/Users/ngangam/commit/hive -r 4df4d75bf1e16fe0af75aad0b4179c34c07fc975
Compiled by ngangam on Sun Apr 3 16:58:16 EDT 2022
From source with checksum 5da234766db5dfbe3e92926c9bbab2af
```



## 集群配置

### 配置hive-env.sh

```
cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh
cat >> $HIVE_HOME/conf/hive-env.sh <<"EOF"
export HADOOP_HEAPSIZE=4096
export HADOOP_HOME=/usr/local/software/hadoop
export HIVE_CONF_DIR=/usr/local/software/hive/conf
export HIVE_AUX_JARS_PATH=""
EOF
```

### 配置hive-site.xml

```
cat > $HIVE_HOME/conf/hive-site.xml <<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 设置Hive的元数据存储为MySQL -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://192.168.1.10:35725/ateng_hive3</value>
        <description>连接到MySQL数据库</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.cj.jdbc.Driver</value>
        <description>MySQL数据库驱动。</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
        <description>MySQL数据库用户名。</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>Admin@123</value>
        <description>MySQL数据库密码。</description>
    </property>

    <!-- 设置Hive的元数据存储目录 -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/hive/warehouse</value>
        <description>Hive数据仓库存储目录，存储在HDFS中</description>
    </property>

    <!-- Hive Metastore的Thrift服务端口号 -->
    <property>
        <name>hive.server2.thrift.port</name>
        <value>9083</value>
    </property>

    <!-- Hive Metastore的Thrift连接URI -->
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://bigdata01:9083</value>
    </property>

    <!-- HiveServer2的Thrift服务端口号 -->
    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>

    <!-- HiveServer2的Web服务端口号 -->
    <property>
        <name>hive.server2.webui.port</name>
        <value>10002</value>
    </property>

    <!-- 禁用 Hive Server2 中的 doAs（用户冒充）功能 -->
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>

    <!-- 禁用 Hive 统计信息自动收集 -->
    <property>
        <name>hive.stats.autogather</name>
        <value>false</value>
    </property>

    <!-- 启用 Hive 的并发支持 -->
    <property>
        <name>hive.support.concurrency</name>
        <value>true</value>
    </property>

    <!-- 设置 Hive 执行动态分区的模式 -->
    <property>
        <name>hive.exec.dynamic.partition.mode</name>
        <value>nonstrict</value>
    </property>

    <!-- 启用Hive Server2的动态服务发现，以实现高可用性。-->
    <property>
        <name>hive.server2.support.dynamic.service.discovery</name>
        <value>true</value>
    </property>
    <!-- 指定ZooKeeper集群的地址和端口-->
    <property>
        <name>hive.zookeeper.quorum</name>
        <value>bigdata01:2181,bigdata02:2181,bigdata03:2181</value>
    </property>
    <!-- 指定Hive Server2在ZooKeeper中的命名空间-->
    <property>
        <name>hive.server2.zookeeper.namespace</name>
        <value>hiveserver2</value>
    </property>
</configuration>
EOF
```

### 配置MySQL驱动

```
cp tools/mysql-connector-j-8.0.33.jar $HIVE_HOME/lib
```

### 分发配置文件

**配置文件**

```
scp $HIVE_HOME/conf/{hive-site.xml,hive-env.sh} bigdata02:$HIVE_HOME/conf/
scp $HIVE_HOME/conf/{hive-site.xml,hive-env.sh} bigdata03:$HIVE_HOME/conf/
```

**MySQL驱动**

```
scp $HIVE_HOME/tools/mysql-connector-j-8.0.33.jar bigdata02:$HIVE_HOME/lib/
scp $HIVE_HOME/tools/mysql-connector-j-8.0.33.jar bigdata03:$HIVE_HOME/lib/
```



## 启动集群

**初始化Hive元数据存储**

```
schematool -initSchema -dbType mysql
```

**启动Hive Metastore**

在bigdata01、bigdata02、bigdata03节点启动Metastore
bigdata01: HiveMetaStore
bigdata02: HiveMetaStore
bigdata03: HiveMetaStore
HiveMetaStore API: bigdata01:9083

```
hive --service metastore
```

**启动Hive Server2**

在bigdata01、bigdata02、bigdata03节点启动HiveServer2
bigdata01: HiveServer2 
bigdata02: HiveServer2 
bigdata03: HiveServer2 
HiveServer2 API: bigdata02:10000
HiveServer2 Web: http://bigdata02:10002/

```
hive --service hiveserver2
```

**连接测试**

```
$ beeline -u jdbc:hive2://bigdata01:10000 -n admin
0: jdbc:hive2://bigdata01:10000> show databases;
```



## 设置服务自启

在预设的节点进行相应的配置

### Hive Metastore 服务

hive.metastore.uris参数上的服务器都要设置，这里是bigdata01、bigdata02、bigdata03

**编辑配置文件**

```
sudo tee /etc/systemd/system/hive-metastore.service <<"EOF"
[Unit]
Description=Hive Metastore
Documentation=https://hive.apache.org
After=network.target
[Service]
Type=simple
Environment="HIVE_HOME=/usr/local/software/hive"
ExecStart=/usr/local/software/hive/bin/hive --service metastore
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hive-metastore.service
sudo systemctl start hive-metastore.service
sudo systemctl status hive-metastore.service
```

### Hive Server2 服务

在预设的节点启动，这里是bigdata01、bigdata02、bigdata03

**编辑配置文件**

这里使用了ExecStartPre，防止metastore服务还未启动完成Server2就开始启动了，就会导致Server2无法正常启动。也可以使用这个命令来检测： `nc -zv bigdata01 9083`

```
sudo tee /etc/systemd/system/hive-server2.service <<"EOF"
[Unit]
Description=Hive Server2
Documentation=https://hive.apache.org
After=network.target
Requires=hive-metastore.service
[Service]
Type=simple
Environment="HIVE_HOME=/usr/local/software/hive"
ExecStartPre=/usr/bin/sleep 10
ExecStart=/usr/local/software/hive/bin/hive --service hiveserver2
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable hive-server2.service
sudo systemctl start hive-server2.service
sudo systemctl status hive-server2.service
```



## 使用集群

**连接hive**

使用Zookeeper实现了HiveServer2的HA功能（ZooKeeper Service Discovery），Client端可以通过指定一个nameSpace来连接HiveServer2，而不是指定某一个host和port

```
beeline -u "jdbc:hive2://bigdata01:2181,bigdata02:2181,bigdata03:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2" -n admin
```

**创建数据库**

```
CREATE TABLE my_table (
    id INT,
    name STRING
);
```

**插入数据**

```
INSERT INTO my_table VALUES
    (1, 'John'),
    (2, 'Jane'),
    (3, 'Bob'),
    (4, 'Alice');
```

**查询数据**

```
SELECT * FROM my_table;
SELECT count(*) FROM my_table;
```

