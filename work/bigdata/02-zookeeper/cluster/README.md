# Zookeeper

Apache ZooKeeper 是一个开源的分布式协调服务，主要用于分布式应用程序中管理和协调不同节点之间的通信。它为分布式系统提供了高效的同步、配置管理、命名服务、集群管理等功能。ZooKeeper 通过提供一个类似文件系统的层次结构来存储数据，这些数据称为 *znode*，支持节点的创建、删除、监听和更新操作，保证了系统的一致性和可靠性。

ZooKeeper 采用了 *高可用* 和 *一致性* 的设计，可以通过多个服务器组成集群进行容错。它广泛应用于分布式系统中的服务发现、配置管理、分布式锁、队列管理等场景。

- [官网链接](https://zookeeper.apache.org/)



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述          |
| ------------- | --------- | ------------- |
| 192.168.1.131 | bigdata01 | Zookeeper节点 |
| 192.168.1.132 | bigdata02 | Zookeeper节点 |
| 192.168.1.133 | bigdata03 | Zookeeper节点 |



## 基础配置

**下载软件包**

```
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz
```

**解压软件包**

```
tar -zxvf apache-zookeeper-3.9.3-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-zookeeper-3.9.3-bin /usr/local/software/zookeeper
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## ZOOKEEPER_HOME
export ZOOKEEPER_HOME=/usr/local/software/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin
EOF
source ~/.bash_profile
```



## 集群配置

**配置zookeeper ID**

所有节点创建目录

```
mkdir -p /data/service/zookeeper/{data,logs}
```

相关节点配置zkID，每个节点唯一

```
[admin@bigdata01 ~]$ echo 1 > /data/service/zookeeper/data/myid
[admin@bigdata02 ~]$ echo 2 > /data/service/zookeeper/data/myid
[admin@bigdata03 ~]$ echo 3 > /data/service/zookeeper/data/myid
```

**配置zoo.cfg**

参考[官方文档](https://zookeeper.apache.org/doc/r3.9.3/zookeeperAdmin.html)

```
cat > $ZOOKEEPER_HOME/conf/zoo.cfg <<EOF
clientPort=2181
clientPortAddress=0.0.0.0
server.1=bigdata01:2888:3888
server.2=bigdata02:2888:3888
server.3=bigdata03:2888:3888
admin.enableServer=false
admin.serverAddress=0.0.0.0
admin.serverPort=8181
admin.commandURL=/commands
maxClientCnxns=1024
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
snapCount=100000
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/service/zookeeper/data
dataLogDir=/data/service/zookeeper/logs
EOF
```

**配置JVM参数**

```
cat > $ZOOKEEPER_HOME/conf/java.env <<"EOF"
export JAVA_HOME=/usr/local/software/jdk8
export ZK_SERVER_HEAP=2048
export JVMFLAGS="-Dzookeeper.electionPortBindRetry=0"
EOF
```

**分发配置文件**

```
scp $ZOOKEEPER_HOME/conf/{zoo.cfg,java.env} bigdata02:$ZOOKEEPER_HOME/conf
scp $ZOOKEEPER_HOME/conf/{zoo.cfg,java.env} bigdata03:$ZOOKEEPER_HOME/conf
```



## 启动集群

**启动zookeeper**

AdminServer: http://bigdata01:8181/commands

Client Address：bigdata01:2181

每个节点存在一个QuorumPeerMain进程

```
zkServer.sh start
```

**查看zookeeper**

```
[admin@bigdata01 ~]$ zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/software/zookeeper/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower

[admin@bigdata02 ~]$ zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/software/zookeeper/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: leader

[admin@bigdata03 ~]$ zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/software/zookeeper/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower
```

**关闭zookeeper**

```
zkServer.sh stop
```

**设置服务自启**

编辑配置文件

```
sudo tee /etc/systemd/system/zookeeper.service <<"EOF"
[Unit]
Description=Apache ZooKeeper
Documentation=https://zookeeper.apache.org
After=network.target
[Service]
ExecStart=/usr/local/software/zookeeper/bin/zkServer.sh start-foreground
ExecStop=/usr/local/software/zookeeper/bin/zkServer.sh stop
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable zookeeper.service
sudo systemctl start zookeeper.service
sudo systemctl status zookeeper.service
```



## 使用集群

**客户端连接集群**

```
zkCli.sh -server bigdata01:2181,bigdata02:2181,bigdata03:2181
```

**创建znode**

```
[zk: bigdata01:2181,bigdata02:2181,bigdata03:2181(CONNECTED) 0] create /ateng "my name is ateng"
Created /ateng
[zk: bigdata01:2181,bigdata02:2181,bigdata03:2181(CONNECTED) 1] ls /
[ateng, zookeeper]
[zk: bigdata01:2181,bigdata02:2181,bigdata03:2181(CONNECTED) 2] quit
```

