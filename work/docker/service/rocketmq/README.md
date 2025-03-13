# RocketMQ5

**RocketMQ** 是 **Apache** 顶级开源的**分布式消息队列**，最初由 **阿里巴巴** 开发，具备**高吞吐、低延迟、高可用**等特性，广泛用于**异步解耦、分布式事务、流式计算**等场景。RocketMQ **5.x** 版本引入 **Controller、Proxy、云原生支持**，增强了**多协议兼容性（HTTP/gRPC/MQTT）、自动主从切换、存储优化**。其核心组件包括 **NameServer（注册中心）、Broker（存储转发）、Controller（高可用管理）、Proxy（协议适配）**，适合**云环境和高并发业务** 🚀。

- [官网链接](https://rocketmq.apache.org/zh/)



## 服务配置

### 创建数据目录

```
sudo mkdir -p /data/container/rocketmq/{data,config}
sudo chown -R 3000:3000 /data/container/rocketmq
```

### 创建 NameServer 配置

```
sudo tee /data/container/rocketmq/config/namesrv.conf <<"EOF"
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
sudo tee /data/container/rocketmq/config/broker.conf <<"EOF"
# 基础配置
listenPort = 10911
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
autoCreateTopicEnable = true
autoCreateSubscriptionGroup = true

# 存储 & 清理
storePathRootDir = /opt/rocketmq
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



## 运行服务

### NameServer 服务

**运行服务**

```
docker run -d --name ateng-rocketmq-namesrv \
  -p 20027:9876 --restart=always \
  -v /data/container/rocketmq/config/namesrv.conf:/opt/config/namesrv.conf \
  -e JAVA_OPT_EXT="-Xms2g -Xmx2g" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/rocketmq:5.3.1 \
  sh mqnamesrv -c /opt/config/namesrv.conf
```

**查看日志**

```
docker logs -f ateng-rocketmq-namesrv
```

### Broker 服务

**运行服务**

```
docker run -d --name ateng-rocketmq-broker \
  -p 20028:10911 --restart=always \
  -v /data/container/rocketmq/config/broker.conf:/opt/config/broker.conf \
  -v /data/container/rocketmq/data:/opt/rocketmq \
  -e JAVA_OPT_EXT="-Xms2g -Xmx2g" \
  -e NAMESRV_ADDR=192.168.1.12:20027 \
  -e TZ=Asia/Shanghai \
  regregistry.lingo.local/service/rocketmq:5.3.1 \
  sh mqbroker -c /opt/config/broker.conf
```

**查看日志**

```
docker logs -f ateng-rocketmq-broker
```

### Dashboard 服务

**运行服务**

```
docker run -d --name ateng-rocketmq-dashboard \
  -p 20029:8080 --restart=always \
  -e JAVA_OPTS="-Xms1g -Xmx1g -Drocketmq.namesrv.addr=192.168.1.12:20027" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/rocketmq-dashboard:latest
```

**查看日志**

```
docker logs -f ateng-rocketmq-dashboard
```



## 使用服务

```
AMQP URL: 192.168.1.114:20009
Web URL: http://192.168.1.12:20029/
Username: admin
Password: Admin@123
```



## 删除服务

**删除服务**

停止服务

```
docker stop ateng-rocketmq-namesrv
docker stop ateng-rocketmq-broker
docker stop ateng-rocketmq-dashboard
```

删除服务

```
docker rm ateng-rocketmq-namesrv
docker rm ateng-rocketmq-broker
docker rm ateng-rocketmq-dashboard
```

删除目录

```
sudo rm -rf /data/container/rocketmq
```

