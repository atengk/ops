# 安装Doris2

> Apache Doris 是一个用于实时分析的现代数据仓库。它可以对大规模实时数据进行闪电般的快速分析。
>
> https://doris.apache.org/
>
> https://doris.apache.org/zh-CN/docs/get-starting/quick-start/
>
> https://doris.apache.org/zh-CN/docs/install/cluster-deployment/standard-deployment

文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述             |
| ------------- | --------- | ---------------- |
| 192.168.1.131 | bigdata01 | DorisFE、DorisBE |



## 基础环境配置

解压软件包

```
tar -zxvf apache-doris-2.1.7-bin-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-doris-2.1.7-bin-x64 /usr/local/software/doris
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## DORIS_HOME
export DORIS_BE_HOME=/usr/local/software/doris/be
export DORIS_FE_HOME=/usr/local/software/doris/fe
export PATH=$PATH:$DORIS_BE_HOME/bin:$DORIS_FE_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
$DORIS_BE_HOME/lib/doris_be --version
```



## 配置Frontend 

> 用户请求访问、查询解析和规划、元数据管理、节点管理等。
>
> https://doris.apache.org/zh-CN/docs/admin-manual/config/fe-config
>
> https://doris.apache.org/zh-CN/docs/3.0/admin-manual/cluster-management/fqdn

配置java路径、添加元数据目录、服务端口和开启fqdn，可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_FE_HOME/conf/fe.conf
JAVA_HOME=/usr/local/software/jdk1.8.0
meta_dir=/usr/local/software/doris/fe/doris-meta/
http_port = 9040
rpc_port = 9020
query_port = 9030
edit_log_port = 9010
enable_fqdn_mode = true
```

创建目录

```
mkdir -p /usr/local/software/doris/fe/doris-meta/
```

启动FE

```
start_fe.sh --daemon
```

检查服务

```
curl http://127.0.0.1:9040/api/bootstrap
```

访问FE

```
URL: http://bigdata01:9040/
Username: root
Password: 密码为空
```



## MySQL客户端连接FE

解压MySQL客户端软件包

> 使用命令`rpm -qa glibc`查看操作系统的glibc版本，MySQL的包选择和操作系统相近的一个。
>
> https://dev.mysql.com/downloads/mysql/

```
tar -xvf mysql-8.4.2-linux-glibc2.28-x86_64.tar.xz -C /usr/local/software/
ln -s /usr/local/software/mysql-8.4.2-linux-glibc2.28-x86_64 /usr/local/software/mysql
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## MYSQL_HOME
export MYSQL_HOME=/usr/local/software/mysql
export PATH=$PATH:$MYSQL_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
$ mysql --version
mysql  Ver 8.4.2 for Linux on x86_64 (MySQL Community Server - GPL)
```

连接FE

```
mysql -uroot -P9030 -h127.0.0.1
```

查看FE运行状态

```
show frontends\G;
```



## 配置Backend

> 数据存储和查询计划执行
>
> https://doris.apache.org/zh-CN/docs/admin-manual/config/be-config

配置java路径、BE数据存储目录、服务端口，可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_BE_HOME/conf/be.conf
JAVA_HOME=/usr/local/software/jdk1.8.0
storage_root_path=/data/service/doris/storage01;/data/service/doris/storage02
be_port = 9060
webserver_port = 9070
heartbeat_service_port = 9050
brpc_port = 9080
```

创建目录

```
mkdir -p /data/service/doris/storage{01,02}
```

启动BE

```
start_be.sh --daemon
```



## 添加Backend节点

连接FE

```
mysql -uroot -P9030 -h127.0.0.1
```

向集群添加 BE 节点

> 通过MySQL客户端连接FE，执行以下SQL将BE添加到集群
>
> be_host_ip：这里是你 BE 的 IP 地址，和你在 be.conf 里的 priority_networks 匹配
> heartbeat_service_port：这里是你 BE 的心跳上报端口，和你在 be.conf 里的 heartbeat_service_port 匹配，默认是 9050。

```
ALTER SYSTEM ADD BACKEND "bigdata01:9050";
```

查看BE运行状态

> 在MySQL命令行中执行如下命令，可以查看BE的运行状态。
>
> Alive : true 表示节点正常运行

```
SHOW BACKENDS\G;
```



## 配置Broker

> Broker 是 Doris 集群中一种可选进程，主要用于支持 Doris 读写远端存储上的文件和目录。

拷贝broker文件

```
cp -r /usr/local/software/doris/extensions/apache_hdfs_broker /usr/local/software/doris/broker/
```

broker配置文件

```
cd /usr/local/software/doris/broker/
cat conf/apache_hdfs_broker.conf
```

拷贝hdfs文件

```
cp $HADOOP_HOME/etc/hadoop/{core-site.xml,hdfs-site.xml} conf/
```

启动broker

```
bin/start_broker.sh --daemon
```



## 添加Broker节点

连接FE

```
mysql -uroot -P9030 -h127.0.0.1
```

向集群添加 broker 节点

```
ALTER SYSTEM ADD BROKER ateng_doris_broker "bigdata01:8000";
```

查看BE运行状态

> 在MySQL命令行中执行如下命令，可以查看broker的运行状态。
>
> Alive : true 表示节点正常运行

```
SHOW BROKER\G;
```



## 停止服务

停止broker

```
/usr/local/software/doris/broker/bin/stop_broker.sh
```

停止BE

```
stop_be.sh
```

停止FE

```
stop_fe.sh
```



## 设置自启

> 后台进程使用**Type=forking**

### Doris Frontend 服务

```
$ sudo vi /etc/systemd/system/doris-frontend.service
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
```

```
sudo systemctl daemon-reload
sudo systemctl enable doris-frontend.service
sudo systemctl start doris-frontend.service
sudo systemctl status doris-frontend.service
```

### Doris Backend 服务

```
$ sudo vi /etc/systemd/system/doris-backend.service
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
```

```
sudo systemctl daemon-reload
sudo systemctl enable doris-backend.service
sudo systemctl start doris-backend.service
sudo systemctl status doris-backend.service
```

### Doris Broker 服务

```
$ sudo vi /etc/systemd/system/doris-broker.service
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
```

```
sudo systemctl daemon-reload
sudo systemctl enable doris-broker.service
sudo systemctl start doris-broker.service
sudo systemctl status doris-broker.service
```



## 使用服务

连接FE

```
mysql -uroot -P9030 -h127.0.0.1
```

创建数据库

```
create database demo;
```

创建表

```
use demo;

CREATE TABLE IF NOT EXISTS demo.example_tbl
(
    `user_id` LARGEINT NOT NULL COMMENT "user id",
    `date` DATE NOT NULL COMMENT "",
    `city` VARCHAR(20) COMMENT "",
    `age` SMALLINT COMMENT "",
    `sex` TINYINT COMMENT "",
    `last_visit_date` DATETIME REPLACE DEFAULT "1970-01-01 00:00:00" COMMENT "",
    `cost` BIGINT SUM DEFAULT "0" COMMENT "",
    `max_dwell_time` INT MAX DEFAULT "0" COMMENT "",
    `min_dwell_time` INT MIN DEFAULT "99999" COMMENT ""
)
AGGREGATE KEY(`user_id`, `date`, `city`, `age`, `sex`)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 1
PROPERTIES (
    "replication_allocation" = "tag.location.default: 1"
);
```

实例数据

```
cat > /data/service/doris/test.csv <<"EOF"
10000,2017-10-01,beijing,20,0,2017-10-01 06:00:00,20,10,10
10006,2017-10-01,beijing,20,0,2017-10-01 07:00:00,15,2,2
10001,2017-10-01,beijing,30,1,2017-10-01 17:05:45,2,22,22
10002,2017-10-02,shanghai,20,1,2017-10-02 12:59:12,200,5,5
10003,2017-10-02,guangzhou,32,0,2017-10-02 11:20:00,30,11,11
10004,2017-10-01,shenzhen,35,0,2017-10-01 10:00:15,100,3,3
10004,2017-10-03,shenzhen,35,0,2017-10-03 10:20:22,11,6,6
EOF
```

导入数据

> 这里我们通过Stream load将上面文件中保存的数据导入到我们刚刚创建的表中。
>
> -u root : 这里是用户名密码，我们使用默认用户root，密码是空
> 127.0.0.1:9040 : 分别是 fe 的 ip 和 http_port

```
curl --location-trusted -u root: -T /data/service/doris/test.csv -H "column_separator:," -H "Expect:100-continue" http://127.0.0.1:9040/api/demo/example_tbl/_stream_load
```

查询数据

```
$ mysql -uroot -P9030 -h127.0.0.1
use demo;
select * from example_tbl;
select * from example_tbl where city='shenzhen';
select city, sum(cost) as total_cost from example_tbl group by city;
```



## 设置用户密码

设置root用户密码

```
SET PASSWORD FOR 'root'@'%' = PASSWORD('Admin@123');
```

设置admin用户密码

```
SET PASSWORD FOR 'admin'@'%' = PASSWORD('Admin@123');
```

创建普通用户

```
create database kongyu;
create user kongyu identified by 'kongyu';
grant all on kongyu.* to kongyu;
```

查看所有用户权限

```
SHOW ALL GRANTS;
```

