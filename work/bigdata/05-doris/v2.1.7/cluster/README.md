# Doris2

Apache Doris 是一个用于实时分析的现代数据仓库。它可以对大规模实时数据进行闪电般的快速分析。

Apache Doris 的**整体架构**：

- **Frontend（FE）**：主要负责用户请求的接入、查询解析规划、元数据的管理、节点管理相关工作。
- **Backend（BE）**：主要负责数据存储、查询计划的执行。

这两类进程都是可以横向扩展的，单集群可以支持到数百台机器，数十 PB 的存储容量。并且这两类进程通过一致性协议来保证服务的高可用和数据的高可靠。这种高度集成的架构设计极大地降低了一款分布式系统的运维成本。

- [官网链接](https://doris.apache.org/zh-CN/docs/install/cluster-deployment/standard-deployment)



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述             |
| ------------- | --------- | ---------------- |
| 192.168.1.131 | bigdata01 | DorisFE、DorisBE |
| 192.168.1.132 | bigdata02 | DorisBE          |
| 192.168.1.133 | bigdata03 | DorisBE          |



## 基础环境配置

### 前置要求

- 参考[基础配置文档](/work/bigdata/00-basic/)

### 安装JDK8

参考: [JDK8安装文档](/work/bigdata/01-jdk/jdk8/)

**检查JDK版本**

需要JDK8版本，如果有多个JDK版本，不用配置全局环境变量也可以，后面会在FE、BE的配置文件指定JAVA_HOEM。

```
$ java -version
openjdk version "1.8.0_432"
OpenJDK Runtime Environment (Temurin)(build 1.8.0_432-b06)
OpenJDK 64-Bit Server VM (Temurin)(build 25.432-b06, mixed mode)
```

### 安装Doris2

**下载软件包**

进入[官网](https://doris.apache.org/zh-CN/download)下载

```
wget https://apache-doris-releases.oss-accelerate.aliyuncs.com/apache-doris-2.1.7-bin-x64.tar.gz
```

**解压软件包**

```
tar -zxvf apache-doris-2.1.7-bin-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-doris-2.1.7-bin-x64 /usr/local/software/doris
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## DORIS_HOME
export DORIS_BE_HOME=/usr/local/software/doris/be
export DORIS_FE_HOME=/usr/local/software/doris/fe
export PATH=$PATH:$DORIS_BE_HOME/bin:$DORIS_FE_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$DORIS_BE_HOME/lib/doris_be --version
```



## 配置Frontend 

用户请求访问、查询解析和规划、元数据管理、节点管理等。

参考链接：

- [Doris FE 配置参数](https://doris.apache.org/zh-CN/docs/admin-manual/config/fe-config)
- [FQDN 完全限定域名](https://doris.apache.org/zh-CN/docs/admin-manual/cluster-management/fqdn)

在预设的节点上配置服务，这里是bigdata01节点

**修改配置**

配置java路径、添加元数据目录、服务端口和开启fqdn，可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_FE_HOME/conf/fe.conf
JAVA_HOME=/usr/local/software/jdk1.8.0
JAVA_OPTS="-Xss8192m -Xmx8192m -Dfile.encoding=UTF-8 -Djavax.security.auth.useSubjectCredsOnly=false -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+PrintGCDateStamps -XX:+PrintGCDetails -Xloggc:$LOG_DIR/fe.gc.log.$CUR_DATE -Dlog4j2.formatMsgNoLookups=true"
meta_dir=/usr/local/software/doris/fe/doris-meta/
http_port = 9040
rpc_port = 9020
query_port = 9030
edit_log_port = 9010
enable_fqdn_mode = true
```

**创建目录**

```
mkdir -p /usr/local/software/doris/fe/doris-meta/
```

**启动FE**

```
start_fe.sh --daemon
```

**检查服务**

```
curl http://127.0.0.1:9040/api/bootstrap
```



## MySQL连接FE

更多MySQL安装信息参考文档：[链接](/work/service/mysql/v8.4.3/)

如果服务器已经有了mysql命令可以不用再安装了。

**解压MySQL软件包**

```
tar -xvf mysql-8.4.3-linux-glibc2.28-x86_64.tar.xz -C /usr/local/software
ln -s /usr/local/software/mysql-8.4.3-linux-glibc2.28-x86_64 /usr/local/software/mysql
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## MYSQL_HOME
export MYSQL_HOME=/usr/local/software/mysql
export PATH=$PATH:$MYSQL_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$ mysql --version
mysql  Ver 8.4.3 for Linux on x86_64 (MySQL Community Server - GPL)
```

**连接FE**

```
mysql -uroot -P9030 -h127.0.0.1
```

**查看FE运行状态**

```
mysql> show frontends\G;
*************************** 1. row ***************************
              Name: fe_650f5c0e_93e6_41ce_9df8_4a04a0e6ee9c
              Host: bigdata01
       EditLogPort: 9010
          HttpPort: 9040
         QueryPort: 9030
           RpcPort: 9020
ArrowFlightSqlPort: -1
              Role: FOLLOWER
          IsMaster: true
         ClusterId: 1160913624
              Join: true
             Alive: true
 ReplayedJournalId: 1579
     LastStartTime: 2024-12-19 12:56:46
     LastHeartbeat: 2024-12-19 14:54:39
          IsHelper: true
            ErrMsg:
           Version: doris-2.1.7-rc03-443e87e203
  CurrentConnected: Yes
1 row in set (0.07 sec)
```



## 配置Backend

数据存储和查询计划执行

参考链接：

- [BE 配置项](https://doris.apache.org/zh-CN/docs/admin-manual/config/be-config)

在预设的节点上配置服务，这里是bigdata01、bigdata02、bigdata03节点

**修改配置**

配置java路径、BE数据存储目录、服务端口，可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_BE_HOME/conf/be.conf
JAVA_HOME=/usr/local/software/jdk1.8.0
JAVA_OPTS="-Xss8192m -Xmx8192m -Dfile.encoding=UTF-8 -DlogPath=$LOG_DIR/jni.log -Xloggc:$DORIS_HOME/log/be.gc.log.$CUR_DATE -Djavax.security.auth.useSubjectCredsOnly=false -Dsun.security.krb5.debug=true -Dsun.java.command=DorisBE -XX:-CriticalJNINatives"
storage_root_path=/data/service/doris/storage
be_port = 9060
webserver_port = 9070
heartbeat_service_port = 9050
brpc_port = 9080
```

**分发配置文件**

```
scp $DORIS_BE_HOME/conf/be.conf bigdata02:$DORIS_BE_HOME/conf/be.conf
scp $DORIS_BE_HOME/conf/be.conf bigdata03:$DORIS_BE_HOME/conf/be.conf
```

**创建目录**

相关节点都需要创建

```
mkdir -p /data/service/doris/storage
```

**启动BE**

```
start_be.sh --daemon
```



## 添加Backend节点

**连接FE**

```
mysql -uroot -P9030 -h127.0.0.1
```

**向集群添加 BE 节点**

通过MySQL客户端连接FE，执行以下SQL将BE添加到集群

be_host_ip：这里是你 BE 的 IP 地址，和你在 be.conf 里的 priority_networks 匹配
heartbeat_service_port：这里是你 BE 的心跳上报端口，和你在 be.conf 里的 heartbeat_service_port 匹配，默认是 9050。

```
ALTER SYSTEM ADD BACKEND "bigdata01:9050","bigdata02:9050","bigdata03:9050";
```

**查看BE运行状态**

在MySQL命令行中执行如下命令，可以查看BE的运行状态。

Alive : true 表示节点正常运行

```
SHOW BACKENDS\G;
```



## 配置Broker（可选）

Broker 是 Doris 集群中一种可选进程，主要用于支持 Doris 读写远端存储上的文件和目录。

**拷贝broker文件**

```
cp -r /usr/local/software/doris/extensions/apache_hdfs_broker /usr/local/software/doris/broker/
```

**broker配置文件**

```
cd /usr/local/software/doris/broker/
cat conf/apache_hdfs_broker.conf
```

**拷贝hdfs文件**

```
cp $HADOOP_HOME/etc/hadoop/{core-site.xml,hdfs-site.xml} conf/
```

**启动broker**

```
bin/start_broker.sh --daemon
```



## 添加Broker节点（可选）

**连接FE**

```
mysql -uroot -P9030 -h127.0.0.1
```

**向集群添加 broker 节点**

```
ALTER SYSTEM ADD BROKER ateng_doris_broker "bigdata01:8000","bigdata02:8000","bigdata03:8000";
```

**查看BE运行状态**

在MySQL命令行中执行如下命令，可以查看broker的运行状态。

Alive : true 表示节点正常运行

```
SHOW BROKER\G;
```



## 设置开机自启

### 停止服务

**停止broker**

```
/usr/local/software/doris/broker/bin/stop_broker.sh
```

**停止BE**

```
stop_be.sh
```

**停止FE**

```
stop_fe.sh
```

### 设置自启

**Frontend服务**

> 在预设的节点上配置，这里是bigdata01节点

创建配置文件

```
sudo tee /etc/systemd/system/doris-frontend.service <<"EOF"
[Unit]
Description=Doris Frontend
Documentation=https://doros.apache.org
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/software/doris/fe/bin/start_fe.sh --daemon
ExecStop=/usr/local/software/doris/fe/bin/stop_fe.sh
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
sudo systemctl enable --now doris-frontend.service
sudo systemctl status doris-frontend.service
```

**Backend服务**

> 在预设的节点上配置，这里是bigdata01、bigdata02、bigdata03节点

创建配置文件

```
sudo tee /etc/systemd/system/doris-backend.service <<"EOF"
[Unit]
Description=Doris Backend 
Documentation=https://doros.apache.org
After=network.target
[Service]
Type=forking
LimitNOFILE=60000
ExecStart=/usr/local/software/doris/be/bin/start_be.sh --daemon
ExecStop=/usr/local/software/doris/be/bin/stop_be.sh
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
sudo systemctl enable --now doris-backend.service
sudo systemctl status doris-backend.service
```

**Broker服务**

创建配置文件

```
sudo tee /etc/systemd/system/doris-broker.service <<"EOF"
[Unit]
Description=Doris Broker 
Documentation=https://doros.apache.org
After=network.target
[Service]
Type=forking
Environment="JAVA_HOME=/usr/local/software/jdk1.8.0"
ExecStart=/usr/local/software/doris/broker/bin/start_broker.sh --daemon
ExecStop=/usr/local/software/doris/broker/bin/stop_broker.sh
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
sudo systemctl enable --now doris-broker.service
sudo systemctl status doris-broker.service
```



## 设置用户密码

Root 用户和 Admin 用户都属于 Apache Doris 安装完默认存在的 2 个账户。其中 Root 用户拥有整个集群的超级权限，可以对集群完成各种管理操作，比如添加节点，去除节点。Admin 用户没有管理权限，是集群中的 Superuser，拥有除集群管理相关以外的所有权限。建议只有在需要对集群进行运维管理超级权限时才使用 Root 权限。

**连接FE**

```
mysql -uroot -P9030 -h127.0.0.1
```

**设置root用户密码**

```
SET PASSWORD FOR 'root'@'%' = PASSWORD('Admin@123');
```

**设置admin用户密码**

```
SET PASSWORD FOR 'admin'@'%' = PASSWORD('Admin@123');
```

**创建普通用户**

```
create database kongyu;
create user kongyu identified by 'kongyu';
grant all on kongyu.* to kongyu;
```

**查看所有用户权限**

```
SHOW ALL GRANTS;
```



## 创建数据

**连接FE**

```
mysql -uroot -P9030 -h127.0.0.1
```

**创建表**

```
CREATE TABLE IF NOT EXISTS kongyu.user_info (
    id INT NOT NULL,
    name STRING,
    age INT,
    city STRING
)
DISTRIBUTED BY HASH(id) BUCKETS 4
PROPERTIES (
    "replication_num" = "1"
);
```

**插入数据**

```
INSERT INTO kongyu.user_info (id, name, age, city) VALUES
    (2, 'Bob', 30, 'Shanghai'),
    (3, 'Charlie', 28, 'Guangzhou'),
    (4, 'David', 35, 'Shenzhen');
```

**查询数据**

```
SELECT * FROM kongyu.user_info;
```



## 使用服务

**使用HTTP**

```
URL: http://192.168.1.131:9040
Username: admin
Password: Admin@123
```

**使用mysql协议**

```
Address: 192.168.1.131:9030
Username: admin
Password: Admin@123
```

例如使用mysql客户端：`mysql -uadmin -pAdmin@123 -h192.168.1.113 -P9030`

