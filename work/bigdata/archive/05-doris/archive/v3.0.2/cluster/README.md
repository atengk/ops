# 安装Doris3

> Apache Doris 是一个用于实时分析的现代数据仓库。它可以对大规模实时数据进行闪电般的快速分析。
>
> Doris 存算分离架构：
>
> - FE：负责接收用户请求，负责存储库表的元数据，目前是有状态的，未来会和 BE 类似，演化为无状态。
>
> - BE：无状态化的 Doris BE 节点，负责具体的计算任务。BE 上会缓存一部分 Tablet 元数据和数据以提高查询性能。
>
> - MS：存算分离模式新增模块，程序名为 doris_cloud，可通过启动不同参数来指定为以下两种角色之一
>
> - - Meta Service：元数据管理，提供元数据操作的服务，例如创建 Tablet，新增 Rowset，Tablet 查询以及 Rowset 元数据查询等功能。
>     - Recycler：数据回收。通过定期对记录已标记删除的数据的元数据进行扫描，实现对数据的定期异步正向回收（文件实际存储在 S3 或 HDFS 上），而无须列举数据对象进行元数据对比。
>
> https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/overview

文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                                    |
| ------------- | --------- | --------------------------------------- |
| 192.168.1.131 | bigdata01 | FoundationDB、DorisFE、DorisBE、DorisMS |
| 192.168.1.132 | bigdata02 | DorisBE                                 |
| 192.168.1.133 | bigdata03 | DorisBE                                 |



## 基础环境配置

### 安装FoundationDB

参考[文档](https://atengk.github.io/work/#/work/service/foundationdb/v7.1.38/)

最终服务正常启动，查看配置文件

> 注意配置域名映射，版本使用官网指定的版本，高版本会导致MS服务无法启动

```
$ /usr/local/software/foundationdb/bin/fdbserver --version
FoundationDB 7.1 (v7.1.38)
source version f606ece0d13e9382452ac8466cca503b9256181d
protocol fdb00b071010000
$ cat /etc/foundationdb/fdb.cluster
mycluster:abcd1234abcd5678@bigdata01:4500
```

### JDK配置

JDK版本要求`>=JDK17`

```
$ java -version
openjdk version "17.0.12" 2024-07-16
OpenJDK Runtime Environment Temurin-17.0.12+7 (build 17.0.12+7)
OpenJDK 64-Bit Server VM Temurin-17.0.12+7 (build 17.0.12+7, mixed mode, sharing)
```

JDK库文件配置

> Doris需要**libjvm.so**库文件

```
echo "/usr/local/software/jdk17/lib/server" | sudo tee /etc/ld.so.conf.d/jdk17.conf
sudo ldconfig
```

### 安装Doris

解压软件包

```
tar -zxvf apache-doris-3.0.2-bin-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-doris-3.0.2-bin-x64 /usr/local/software/doris
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## DORIS_HOME
export DORIS_BE_HOME=/usr/local/software/doris/be
export DORIS_FE_HOME=/usr/local/software/doris/fe
export DORIS_MS_HOME=/usr/local/software/doris/ms
export DORIS_RE_HOME=/usr/local/software/doris/recycler
EOF
source ~/.bash_profile
```

查看版本

```
$DORIS_BE_HOME/lib/doris_be --version
```

## 配置元数据管理

https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/compilation-and-deployment#3-meta-service-%E9%83%A8%E7%BD%B2

安装依赖

```
sudo yum -y install patchelf
```

拷贝ms目录，用于recycler服务部署

```
cp -r $DORIS_MS_HOME $DORIS_RE_HOME
```

编辑配置文件

> 配置以下参数，其余配置不用动

```
$ vi +22 $DORIS_MS_HOME/conf/doris_cloud.conf
JAVA_HOME=/usr/local/software/jdk17
brpc_listen_port = 5000
fdb_cluster = mycluster:abcd1234abcd5678@bigdata01:4500
```

启动服务

> - 仅元数据操作功能的 Meta Service 进程应作为 FE 和 BE 的 `meta_service_endpoint` 配置目标。
> - 数据回收功能进程不应作为 `meta_service_endpoint` 配置目标。

```
$DORIS_MS_HOME/bin/start.sh --meta-service --daemon
```

## 配置回收功能

https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/compilation-and-deployment#4-%E6%95%B0%E6%8D%AE%E5%9B%9E%E6%94%B6%E5%8A%9F%E8%83%BD%E7%8B%AC%E7%AB%8B%E9%83%A8%E7%BD%B2%E5%8F%AF%E9%80%89

编辑配置文件

> 配置以下参数，其余配置不用动

```
$ vi +19 $DORIS_RE_HOME/conf/doris_cloud.conf
JAVA_HOME=/usr/local/software/jdk17
brpc_listen_port = 5001
fdb_cluster = mycluster:abcd1234abcd5678@bigdata01:4500
```

启动服务

```
$DORIS_RE_HOME/bin/start.sh --recycler --daemon
```

## 配置Frontend 

> 用户请求访问、查询解析和规划、元数据管理、节点管理等。
>
> https://doris.apache.org/zh-CN/docs/3.0/admin-manual/config/fe-config
>
> https://doris.apache.org/zh-CN/docs/3.0/admin-manual/cluster-management/fqdn
>
> https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/compilation-and-deployment#5-fe-%E5%92%8C-be-%E7%9A%84%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B
>
> 在bigdata01节点配置FE

配置java路径、添加元数据目录、服务端口、开启fqdn、启动存算分离模式和集群ID、Meta Service地址，可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_FE_HOME/conf/fe.conf
JAVA_HOME=/usr/local/software/jdk17
meta_dir=/usr/local/software/doris/fe/doris-meta/
http_port = 9040
rpc_port = 9020
query_port = 9030
edit_log_port = 9010
enable_fqdn_mode = true
deploy_mode = cloud
cluster_id = 1
meta_service_endpoint = bigdata01:5000
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

> 可以选择节点安装，也可以多个节点都安装上MySQL客户端
>
> 使用命令`rpm -qa glibc`查看操作系统的glibc版本，MySQL的包选择和操作系统相近的一个。
>
> https://dev.mysql.com/downloads/mysql/

解压MySQL客户端软件包

```
tar -xvf mysql-8.4.2-linux-glibc2.28-x86_64.tar.xz -C /usr/local/software/
ln -s /usr/local/software/mysql-8.4.2-linux-glibc2.28-x86_64 /usr/local/software/mysql-8.4.2
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## MYSQL_HOME
export MYSQL_HOME=/usr/local/software/mysql-8.4.2
export PATH=$PATH:$MYSQL_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
mysql --version
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
>
> 在bigdata01、bigdata02、bigdata03节点配置BE

配置java路径、BE数据存储目录、服务端口、开启存算分离模式并设置缓存路径和大小（100GB），可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_BE_HOME/conf/be.conf
JAVA_HOME=/usr/local/software/jdk17
be_port = 9060
webserver_port = 9070
heartbeat_service_port = 9050
brpc_port = 9080
deploy_mode = cloud
file_cache_path = [{"path":"/data/service/doris/file_cache01","total_size":104857600000,"query_limit":10485760000}, {"path":"/data/service/doris/file_cache02","total_size":104857600000,"query_limit":10485760000}]
```

分发配置文件

```
scp $DORIS_BE_HOME/conf/be.conf bigdata02:$DORIS_BE_HOME/conf/be.conf
scp $DORIS_BE_HOME/conf/be.conf bigdata03:$DORIS_BE_HOME/conf/be.conf
```

创建目录

> 相关节点都需要创建

```
mkdir -p /data/service/doris/file_cache{01,02}
```

启动BE

```
start_be.sh --daemon
```

访问BE

```
http://bigdata01:9070
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
ALTER SYSTEM ADD BACKEND "bigdata01:9050","bigdata02:9050","bigdata03:9050";
```

查看BE运行状态

> 在MySQL命令行中执行如下命令，可以查看BE的运行状态。
>
> Alive : true 表示节点正常运行

```
SHOW BACKENDS\G;
```

## 创建 Storage Vault

Storage Vault 是 Doris 存算分离架构中的重要组件。它们代表了存储数据的共享存储层。您可以使用 HDFS 或兼容 S3 的对象存储创建一个或多个 Storage Vault 。可以将一个 Storage Vault 设置为默认 Storage Vault ，系统表和未指定 Storage Vault 的表都将存储在这个默认 Storage Vault 中。默认 Storage Vault 不能被删除。以下是为您的 Doris 集群创建 Storage Vault 的方法：

https://doris.apache.org/zh-CN/docs/3.0/sql-manual/sql-statements/Data-Definition-Statements/Create/CREATE-STORAGE-VAULT/

创建 S3 Storage Vault

> MinIO安装文档参考：[地址](https://atengk.github.io/work/#/work/service/minio/v20241013/)

```sql
CREATE STORAGE VAULT IF NOT EXISTS minio_vault
    PROPERTIES (
    "type"="S3",
    "s3.endpoint"="http://192.168.1.13:9000",
    "s3.access_key" = "admin",
    "s3.secret_key" = "Lingo@local_minio_9000",
    "s3.region" = "us-east-1",
    "s3.root.path" = "data",
    "s3.bucket" = "doris",
    "provider" = "S3"
    );
```

设置默认 Storage Vault

```
SET minio_vault AS DEFAULT STORAGE VAULT;
```

查看 Storage Vault

```
SHOW STORAGE VAULTS\G;
```



## 停止服务

停止BE

```
$DORIS_BE_HOME/bin/stop_be.sh
```

停止FE

```
$DORIS_FE_HOME/bin/stop_fe.sh
```

停止元数据服务

```
$DORIS_RE_HOME/bin/stop.sh
$DORIS_MS_HOME/bin/stop.sh
```



## 设置自启

### 元数据服务

在bigdata01节点配置

```
sudo tee /etc/systemd/system/doris-meta.service <<"EOF"
[Unit]
Description=Doris Meta Service
Documentation=https://doros.apache.org
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/software/doris/ms/bin/start.sh --meta-service --daemon
ExecStop=/usr/local/software/doris/ms/bin/stop.sh
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable doris-meta.service
sudo systemctl start doris-meta.service
sudo systemctl status doris-meta.service
```

### 回收服务

在bigdata01节点配置

```
sudo tee /etc/systemd/system/doris-recycler.service <<"EOF"
[Unit]
Description=Doris Recycler Service
Documentation=https://doros.apache.org
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/software/doris/recycler/bin/start.sh --recycler --daemon
ExecStop=/usr/local/software/doris/recycler/bin/stop.sh
Restart=always
RestartSec=10
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable doris-recycler.service
sudo systemctl start doris-recycler.service
sudo systemctl status doris-recycler.service
```

### Doris Frontend 服务

在bigdata01节点配置FE

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
sudo systemctl daemon-reload
sudo systemctl enable doris-frontend.service
sudo systemctl start doris-frontend.service
sudo systemctl status doris-frontend.service
```

### Doris Backend 服务

在bigdata01、bigdata02、bigdata03节点配置BE

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
sudo systemctl daemon-reload
sudo systemctl enable doris-backend.service
sudo systemctl start doris-backend.service
sudo systemctl status doris-backend.service
```



## 使用服务

连接FE

```
mysql -uroot -P9030 -h127.0.0.1
```

查看计算组

```
mysql> SHOW COMPUTE GROUPS;
+-----------------------+-----------+-------+------------+
| Name                  | IsCurrent | Users | BackendNum |
+-----------------------+-----------+-------+------------+
| default_compute_group | TRUE      |       | 3          |
+-----------------------+-----------+-------+------------+
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

