# HBase2

HBase2是一个分布式、面向列的NoSQL数据库，构建于Hadoop HDFS之上，提供高效的大规模结构化数据存储与检索。相比1.x版本，HBase2提升了性能、可靠性和可扩展性，支持异步操作（Async API）、分布式集群的动态扩展以及改进的数据压缩。它广泛用于实时分析和大数据处理场景。

- [官网链接](https://hbase.apache.org/)



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                  |
| ------------- | --------- | --------------------- |
| 192.168.1.131 | bigdata01 | HMaster HRegionServer |
| 192.168.1.132 | bigdata02 | HRegionServer         |
| 192.168.1.133 | bigdata03 | HRegionServer         |





## 基础配置

**下载软件包**

```
wget https://dlcdn.apache.org/hbase/2.6.1/hbase-2.6.1-bin.tar.gz
```

**解压软件包**

```
tar -zxvf hbase-2.6.1-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/hbase-2.6.1 /usr/local/software/hbase
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## HBASE_HOME
export HBASE_HOME=/usr/local/software/hbase
export PATH=$PATH:$HBASE_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
hbase version
```



## 集群配置

在bigdata01节点配置相应文件，最后分发到其他节点

### 配置hbase-env.sh

```
cp $HBASE_HOME/conf/hbase-env.sh{,_bak}
cat > $HBASE_HOME/conf/hbase-env.sh <<"EOF"
export JAVA_HOME=/usr/local/software/jdk8
export HBASE_HEAPSIZE=4G
export HBASE_MASTER_OPTS="-Xms1g -Xmx4g"
export HBASE_REGIONSERVER_OPTS="-Xms1g -Xmx8g"
export HBASE_MANAGES_ZK=false
# 是否禁用 Hadoop 类路径查找
export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP="true"
EOF
```

### 配置hbase-site.xml

注意修改以下配置：

- hbase.rootdir： HBase数据目录
- hbase.zookeeper.quorum：Zookeeper服务地址

```
cat > $HBASE_HOME/conf/hbase-site.xml <<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 指定缓存文件存储的路径 -->
    <property>
        <name>hbase.tmp.dir</name>
        <value>/data/service/hbase/tmp</value>
    </property>
    <!--HBase数据目录位置-->
    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://bigdata01:8020/hbase</value>
    </property>
    <!-- 设置HMaster的rpc端口 -->
    <property>
        <name>hbase.master.port</name>
        <value>16000</value>
    </property>
    <!-- 设置HMaster的http端口 -->
    <property>
        <name>hbase.master.info.port</name>
        <value>16010</value>
    </property>
    <!--启用分布式集群-->
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
    <!-- 指定ZooKeeper集群端口 -->
    <property>
        <name>hbase.zookeeper.property.clientPort</name>
        <value>2181</value>
    </property>
    <!--不使用默认内置的，配置独立的ZK集群地址-->
    <property>
        <name>hbase.zookeeper.quorum</name>
        <value>bigdata01,bigdata02,bigdata03</value>
    </property>
    <!-- 配置每个Region Server上处理请求的处理器线程数 -->
    <property>
        <name>hbase.regionserver.handler.count</name>
        <value>30</value>
    </property>
</configuration>
EOF
```

### 配置regionservers

```
cat > $HBASE_HOME/conf/regionservers <<EOF
bigdata01
bigdata02
bigdata03
EOF
```

### 分发配置文件

bigdata01节点将相关配置文件分发到bigdata02和bigdata03节点

```
scp $HBASE_HOME/conf/{hbase-env.sh,hbase-site.xml,regionservers} bigdata02:$HBASE_HOME/conf/
scp $HBASE_HOME/conf/{hbase-env.sh,hbase-site.xml,regionservers} bigdata03:$HBASE_HOME/conf/
```

### 配置hdfs文件

所有节点都需要执行

```
ln -s ${HADOOP_HOME}/etc/hadoop/core-site.xml $HBASE_HOME/conf/core-site.xml
ln -s ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml $HBASE_HOME/conf/hdfs-site.xml
```



## 启动集群

**启动hbase**

bigdata01: HMaster HRegionServer
bigdata02: HRegionServer
bigdata03: HRegionServer
hbase http: http://bigdata01:16010

```
start-hbase.sh
```

**关闭hbase**

```
stop-hbase.sh
```



## 设置服务自启

**请在对应的服务器设置各个进程的自启**

### HBase Master 服务

bigdata01设置Master

**编辑配置文件**

```
sudo tee /etc/systemd/system/hbase-master.service <<"EOF"
[Unit]
Description=HBase Master
Documentation=https://hbase.apache.org
After=network.target
[Service]
Type=forking
Environment="HBASE_HOME=/usr/local/software/hbase"
ExecStart=/usr/local/software/hbase/bin/hbase-daemon.sh start master
ExecStop=/usr/local/software/hbase/bin/hbase-daemon.sh stop master
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
sudo systemctl enable hbase-master.service
sudo systemctl start hbase-master.service
sudo systemctl status hbase-master.service
```



### HBase Regionserver 服务

bigdata01、bigdata02、bigdata03设置Regionserver

**编辑配置文件**

```
sudo tee /etc/systemd/system/hbase-regionserver.service <<"EOF"
[Unit]
Description=HBase Regionserver
Documentation=https://hbase.apache.org
After=network.target
[Service]
Type=forking
Environment="HBASE_HOME=/usr/local/software/hbase"
ExecStart=/usr/local/software/hbase/bin/hbase-daemon.sh start regionserver
ExecStop=/usr/local/software/hbase/bin/hbase-daemon.sh stop regionserver
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
sudo systemctl enable hbase-regionserver.service
sudo systemctl start hbase-regionserver.service
sudo systemctl status hbase-regionserver.service
```



## 使用集群

**进入客户端**

```
hbase shell
```

**创建表**

```
hbase:001:0> create 'ateng','info'
hbase:002:0> list
hbase:003:0> put 'ateng', 'row1', 'info:name', '阿腾'
hbase:004:0> scan 'ateng', {FORMATTER=>'toString'}
hbase:005:0> exit
```

**导入导出**

导出到HDFS

```
$ hbase org.apache.hadoop.hbase.mapreduce.Export default:ateng /data/hbase/ateng
$ hadoop fs -ls /data/hbase/ateng
Found 2 items
-rw-r--r--   1 admin ateng          0 2024-12-24 11:30 /data/hbase/ateng/_SUCCESS
-rw-r--r--   1 admin ateng        174 2024-12-24 11:30 /data/hbase/ateng/part-m-00000
```

导出到本地

```
$ hbase org.apache.hadoop.hbase.mapreduce.Export default:ateng file:///tmp/hbase/ateng
$ ll /tmp/hbase/ateng
total 4
-rw-r--r-- 1 admin ateng 174 Dec 24 11:31 part-m-00000
-rw-r--r-- 1 admin ateng   0 Dec 24 11:31 _SUCCESS
```

导入

```
$ hbase shell
hbase:001:0> create 'ateng2','info'
$ hbase org.apache.hadoop.hbase.mapreduce.Import default:ateng2 file:///tmp/hbase/ateng
$ hbase shell
hbase:002:0> scan 'ateng2', {FORMATTER=>'toString'}
ROW                                        COLUMN+CELL
 row1                                      column=info:name, timestamp=2024-12-24T11:30:20.076, value=阿腾                                                            
1 row(s)
Took 0.0193 seconds
```

