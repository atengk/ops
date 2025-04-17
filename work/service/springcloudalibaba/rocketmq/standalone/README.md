# RocketMQ5

**RocketMQ** 是 **Apache** 顶级开源的**分布式消息队列**，最初由 **阿里巴巴** 开发，具备**高吞吐、低延迟、高可用**等特性，广泛用于**异步解耦、分布式事务、流式计算**等场景。RocketMQ **5.x** 版本引入 **Controller、Proxy、云原生支持**，增强了**多协议兼容性（HTTP/gRPC/MQTT）、自动主从切换、存储优化**。其核心组件包括 **NameServer（注册中心）、Broker（存储转发）、Controller（高可用管理）、Proxy（协议适配）**，适合**云环境和高并发业务** 🚀。

- [官网链接](https://rocketmq.apache.org/zh/)



文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                |
| ------------- | --------- | ------------------- |
| 192.168.1.109 | bigdata01 | NameServer + Broker |



## 基础配置

**下载软件包**

```
wget https://dist.apache.org/repos/dist/release/rocketmq/5.3.1/rocketmq-all-5.3.1-bin-release.zip
```

**解压软件包**

```
unzip -d /usr/local/software/ rocketmq-all-5.3.1-bin-release.zip
ln -s /usr/local/software/rocketmq-all-5.3.1-bin-release /usr/local/software/rocketmq
```

**创建环境变量**

```
cat > /usr/local/software/rocketmq/conf/rocketmq.env <<"EOF"
JAVA_HOME=/usr/local/software/jdk8
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:$JAVA_HOME/bin
EOF
```



## 服务配置

### 创建 NameServer 配置

```
cat > /usr/local/software/rocketmq/conf/namesrv.conf <<"EOF"
listenPort=9876
defaultThreadPoolNums=4
EOF
```

**参数说明**

- `listenPort`：NameServer 监听端口
- `defaultThreadPoolNums`：线程池大小

### 创建  Broker 配置

**创建配置文件**

```
cat > /usr/local/software/rocketmq/conf/broker.conf <<"EOF"
# 基础配置
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
autoCreateTopicEnable = true
autoCreateSubscriptionGroup = true

# NameServer 相关
namesrvAddr = localhost:9876
listenPort = 10911

# 存储 & 清理
storePathRootDir = /data/service/rocketmq
deleteWhen = 04
fileReservedTime = 48
diskMaxUsedSpaceRatio = 75

# 消息队列 & 性能
defaultTopicQueueNums = 8
maxMessageSize = 4194304
EOF
```

**参数说明**

- **基础配置**
    - `brokerClusterName`：Broker 所属集群名称
    - `brokerName`：Broker 名称（同集群内需唯一）
    - `brokerId`：0 为 **Master**，非 0 为 **Slave**
    - `brokerRole`：**ASYNC_MASTER / SYNC_MASTER / SLAVE**
    - `flushDiskType`：磁盘刷盘策略 **ASYNC_FLUSH / SYNC_FLUSH**
    - `autoCreateTopicEnable`：是否允许自动创建 **Topic**
    - `autoCreateSubscriptionGroup`: 是否允许自动创建订阅组
- **NameServer 相关**
    - `namesrvAddr`：NameServer 地址
    - `listenPort`：Broker 监听端口
- **存储 & 清理**
    - `storePathRootDir`：RocketMQ 存储目录
    - `deleteWhen`：日志删除时间（默认凌晨 **04:00**）
    - `fileReservedTime`：文件保留时长（单位 **小时**）
    - `diskMaxUsedSpaceRatio`：磁盘使用超过 **75%** 开始清理文件
- **消息队列 & 性能**
    - `defaultTopicQueueNums`：默认 **Topic** 队列数
    - `maxMessageSize`：最大消息大小（默认 **4MB**）

**创建数据目录**

```
mkdir -p /data/service/rocketmq
```



## 设置服务自启

### NameServer 服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/rocketmq-namesrv.service <<"EOF"
[Unit]
Description=RocketMQ NameServer
Documentation=https://rocketmq.apache.org/zh
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/rocketmq
Environment="JAVA_OPT_EXT=-Xms1g -Xmx1g"
EnvironmentFile=-/usr/local/software/rocketmq/conf/rocketmq.env
ExecStart=/usr/local/software/rocketmq/bin/mqnamesrv -c /usr/local/software/rocketmq/conf/namesrv.conf
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
sudo systemctl enable rocketmq-namesrv.service
sudo systemctl start rocketmq-namesrv.service
```

**查看状态**

```
sudo systemctl status rocketmq-namesrv.service
sudo journalctl -f -u rocketmq-namesrv.service
```

### Broker 服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/rocketmq-broker.service <<"EOF"
[Unit]
Description=RocketMQ Broker
Documentation=https://rocketmq.apache.org/zh
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/rocketmq
Environment="JAVA_OPT_EXT=-Xms2g -Xmx2g"
EnvironmentFile=-/usr/local/software/rocketmq/conf/rocketmq.env
ExecStart=/usr/local/software/rocketmq/bin/mqbroker -c /usr/local/software/rocketmq/conf/broker.conf
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
sudo systemctl enable rocketmq-broker.service
sudo systemctl start rocketmq-broker.service
```

**查看状态**

```
sudo systemctl status rocketmq-broker.service
sudo journalctl -f -u rocketmq-broker.service
```



## 使用服务

**进入目录**

```
cd /usr/local/software/rocketmq
```

**创建topic**

```
bin/mqadmin updateTopic -n localhost:9876 -c DefaultCluster -t TestTopic
```

**查看topic**

```
bin/mqadmin topicList
```

**写入消息**

```
$ export NAMESRV_ADDR=localhost:9876
$ bin/tools.sh org.apache.rocketmq.example.quickstart.Producer
```

**读取消息**

```
$ bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer
```



## 安装 Dashboard

### 打包Jar

需要在Linux上编译

**下载源码**

```
wget https://codeload.github.com/apache/rocketmq-dashboard/zip/refs/tags/rocketmq-dashboard-2.0.0
```

**打包Jar**

```
mvn clean package -Dmaven.test.skip=true
```

**拷贝Jar**

```
cp rocketmq-dashboard.jar /usr/local/software/rocketmq/rocketmq-dashboard.jar
```



### 启动服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/rocketmq-dashboard.service <<"EOF"
[Unit]
Description=RocketMQ Dashboard
Documentation=https://rocketmq.apache.org/zh
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/rocketmq
Environment="JAVA_OPTS=-Xms1g -Xmx1g -Drocketmq.namesrv.addr=127.0.0.1:9876 -Dserver.port=10908"
ExecStart=/usr/local/software/jdk8/bin/java -server $JAVA_OPTS -jar /usr/local/software/rocketmq/rocketmq-dashboard.jar
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
sudo systemctl enable rocketmq-dashboard.service
sudo systemctl start rocketmq-dashboard.service
```

**查看状态**

```
sudo systemctl status rocketmq-dashboard.service
sudo journalctl -f -u rocketmq-dashboard.service
```



### 访问服务

```
URL: http://192.168.1.13:10908/
```

