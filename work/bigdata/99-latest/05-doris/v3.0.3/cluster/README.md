# 安装Doris3

Apache Doris 是一个用于实时分析的现代数据仓库。它可以对大规模实时数据进行闪电般的快速分析。

- [官网链接](https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/overview)

Doris 存算分离架构：

- FE：负责接收用户请求，负责存储库表的元数据，目前是有状态的，未来会和 BE 类似，演化为无状态。

- BE：无状态化的 Doris BE 节点，负责具体的计算任务。BE 上会缓存一部分 Tablet 元数据和数据以提高查询性能。

- MS：存算分离模式新增模块，程序名为 doris_cloud，可通过启动不同参数来指定为以下两种角色之一

- - Meta Service：元数据管理，提供元数据操作的服务，例如创建 Tablet，新增 Rowset，Tablet 查询以及 Rowset 元数据查询等功能。
        - Recycler：数据回收。通过定期对记录已标记删除的数据的元数据进行扫描，实现对数据的定期异步正向回收（文件实际存储在 S3 或 HDFS 上），而无须列举数据对象进行元数据对比。



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                                    |
| ------------- | --------- | --------------------------------------- |
| 192.168.1.131 | bigdata01 | FoundationDB、DorisFE、DorisBE、DorisMS |
| 192.168.1.132 | bigdata02 | DorisBE                                 |
| 192.168.1.133 | bigdata03 | DorisBE                                 |



## 基础环境配置

### 前置要求

- 参考[基础配置文档](/work/bigdata/00-basic/)

### 安装FoundationDB

参考: [安装FoundationDB文档](/work/service/foundationdb/v7.1.38/)

**检查FoundationDB服务**

最终服务正常启动，查看配置文件

注意配置域名映射，版本使用官网指定的版本，高版本会导致MS服务无法启动

```
$ fdbserver --version
FoundationDB 7.1 (v7.1.38)
source version f606ece0d13e9382452ac8466cca503b9256181d
protocol fdb00b071010000
$ fdbcli --exec status
Using cluster file `/etc/foundationdb/fdb.cluster'.

Configuration:
  Redundancy mode        - single
  Storage engine         - ssd-2
  Coordinators           - 1
  Usable Regions         - 1
......
$ cat /etc/foundationdb/fdb.cluster
mycluster:abcd1234abcd5678@bigdata01:4500
```

### 安装JDK17

参考: [JDK17安装文档](/work/service/openjdk/openjdk17/)

**检查JDK版本**

需要JDK17版本，如果有多个JDK版本，不用配置全局环境变量也可以，后面会在FE、BE的配置文件指定JAVA_HOEM。

```
$ java -version
openjdk version "17.0.13" 2024-10-15
OpenJDK Runtime Environment Temurin-17.0.13+11 (build 17.0.13+11)
OpenJDK 64-Bit Server VM Temurin-17.0.13+11 (build 17.0.13+11, mixed mode, sharing)
```

**JDK库文件配置**

Doris3需要**libjvm.so**库文件

```
echo "/usr/local/software/jdk17/lib/server" | sudo tee /etc/ld.so.conf.d/jdk17.conf
sudo ldconfig
```

### 安装Doris3

**下载软件包**

进入[官网](https://doris.apache.org/zh-CN/download)下载

```
wget https://apache-doris-releases.oss-accelerate.aliyuncs.com/apache-doris-3.0.3-bin-x64.tar.gz
```

**解压软件包**

```
tar -zxvf apache-doris-3.0.3-bin-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-doris-3.0.3-bin-x64 /usr/local/software/doris
```

**配置环境变量**

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

**查看版本**

```
$ $DORIS_BE_HOME/lib/doris_be --version
doris-3.0.3-rc03(AVX2) RELEASE (build git://vm-190@43f06a5e262c07253835264a80d7bd99d05ca75f)
Built on Mon, 25 Nov 2024 18:18:02 4Z by vm-190
```



## 配置Meta Service

参考：[官网链接](https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/compilation-and-deployment#3-meta-service-%E9%83%A8%E7%BD%B2)

**安装依赖**

```
sudo yum -y install patchelf
```

**拷贝ms目录，用于recycler服务部署**

```
cp -r $DORIS_MS_HOME $DORIS_RE_HOME
```

**编辑配置文件**

配置以下参数，其余配置不用动

```
$ vi +18 $DORIS_MS_HOME/conf/doris_cloud.conf
JAVA_HOME=/usr/local/software/jdk17
brpc_listen_port = 5000
fdb_cluster = mycluster:abcd1234abcd5678@bigdata01:4500
http_token = greedisgood9999
```

**启动服务**

- 仅元数据操作功能的 Meta Service 进程应作为 FE 和 BE 的 `meta_service_endpoint` 配置目标。

- 数据回收功能进程不应作为 `meta_service_endpoint` 配置目标。

```
$DORIS_MS_HOME/bin/start.sh --meta-service --daemon
```



## 配置Recycler

参考：[官网链接](https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/compilation-and-deployment#4-%E6%95%B0%E6%8D%AE%E5%9B%9E%E6%94%B6%E5%8A%9F%E8%83%BD%E7%8B%AC%E7%AB%8B%E9%83%A8%E7%BD%B2%E5%8F%AF%E9%80%89)

**编辑配置文件**

配置以下参数，其余配置不用动

```
$ vi +18 $DORIS_RE_HOME/conf/doris_cloud.conf
JAVA_HOME=/usr/local/software/jdk17
brpc_listen_port = 5001
fdb_cluster = mycluster:abcd1234abcd5678@bigdata01:4500
http_token = greedisgood9999
```

**启动服务**

```
$DORIS_RE_HOME/bin/start.sh --recycler --daemon
```



## 配置Frontend 

用户请求访问、查询解析和规划、元数据管理、节点管理等。

参考链接：

- [Doris FE 配置参数](https://doris.apache.org/zh-CN/docs/3.0/admin-manual/config/fe-config)
- [FQDN 完全限定域名](https://doris.apache.org/zh-CN/docs/3.0/admin-manual/cluster-management/fqdn)
- [FE 和 BE 的启动流程](https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/compilation-and-deployment#5-fe-%E5%92%8C-be-%E7%9A%84%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B)

**修改配置**

配置java路径、添加元数据目录、服务端口、开启fqdn、启动存算分离模式和集群ID、Meta Service地址，可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_FE_HOME/conf/fe.conf
JAVA_HOME=/usr/local/software/jdk17
JAVA_OPTS_FOR_JDK_17="-Xms8192m -Xmx8192m -Dfile.encoding=UTF-8 -Djavax.security.auth.useSubjectCredsOnly=false -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LOG_DIR -Xlog:gc*:$LOG_DIR/fe.gc.log.$CUR_DATE:time,uptime:filecount=10,filesize=50M --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens java.base/jdk.internal.ref=ALL-UNNAMED"
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

**创建目录**

```
mkdir -p /usr/local/software/doris/fe/doris-meta/
```

**启动FE**

```
$DORIS_FE_HOME/bin/start_fe.sh --daemon
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
              Name: fe_f5504e9c_b883_40ff_a9bf_b2d8dfbd7507
              Host: bigdata01
       EditLogPort: 9010
          HttpPort: 9040
         QueryPort: 9030
           RpcPort: 9020
ArrowFlightSqlPort: -1
              Role: FOLLOWER
          IsMaster: true
         ClusterId: 1
              Join: true
             Alive: true
 ReplayedJournalId: 376
     LastStartTime: 2024-12-18 17:26:24
     LastHeartbeat: 2024-12-18 17:56:46
          IsHelper: true
            ErrMsg:
           Version: doris-3.0.3-rc03-43f06a5e26
  CurrentConnected: Yes
1 row in set (0.04 sec)
```



## 配置Backend

数据存储和查询计划执行

参考链接：

- [BE 配置项](https://doris.apache.org/zh-CN/docs/admin-manual/config/be-config)

在预设的节点上配置Backend服务，这里是bigdata01、bigdata02、bigdata03节点

**修改配置**

配置java路径、BE数据存储目录、服务端口、开启存算分离模式并设置缓存路径和大小（100GB），可以根据环境适当修改JAVA_OPTS的JVM堆内存

```
$ vi $DORIS_BE_HOME/conf/be.conf
JAVA_OPTS_FOR_JDK_17="-Xms2048m -Xmx8192m -Dfile.encoding=UTF-8 -DlogPath=$LOG_DIR/jni.log -Xlog:gc*:$LOG_DIR/be.gc.log.$CUR_DATE:time,uptime:filecount=10,filesize=50M -Djavax.security.auth.useSubjectCredsOnly=false -Dsun.security.krb5.debug=true -Dsun.java.command=DorisBE -XX:-CriticalJNINatives -XX:+IgnoreUnrecognizedVMOptions --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED --add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED --add-opens=java.management/sun.management=ALL-UNNAMED"
JAVA_HOME=/usr/local/software/jdk17
be_port = 9060
webserver_port = 9070
heartbeat_service_port = 9050
brpc_port = 9080
deploy_mode = cloud
file_cache_path = [{"path":"/data/service/doris/file_cache01","total_size":104857600000,"query_limit":10485760000}, {"path":"/data/service/doris/file_cache02","total_size":104857600000,"query_limit":10485760000}]
```

**分发配置文件**

```
scp $DORIS_BE_HOME/conf/be.conf bigdata02:$DORIS_BE_HOME/conf/be.conf
scp $DORIS_BE_HOME/conf/be.conf bigdata03:$DORIS_BE_HOME/conf/be.conf
```

**创建目录**

相关节点都需要创建

```
mkdir -p /data/service/doris/file_cache{01,02}
```

**启动BE**

```
$DORIS_BE_HOME/bin/start_be.sh --daemon
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

## 创建 Storage Vault

Storage Vault 是 Doris 存算分离架构中的重要组件。它们代表了存储数据的共享存储层。您可以使用 HDFS 或兼容 S3 的对象存储创建一个或多个 Storage Vault 。可以将一个 Storage Vault 设置为默认 Storage Vault ，系统表和未指定 Storage Vault 的表都将存储在这个默认 Storage Vault 中。默认 Storage Vault 不能被删除。以下是为您的 Doris 集群创建 Storage Vault 的方法：

- [官网链接](https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/managing-storage-vault)

**创建 S3 Storage Vault**

MinIO安装文档参考：[地址](/work/service/minio/v20241107/)

```sql
CREATE STORAGE VAULT IF NOT EXISTS minio_vault
    PROPERTIES (
    "type"="S3",
    "s3.endpoint"="http://192.168.1.13:9000",
    "s3.access_key" = "admin",
    "s3.secret_key" = "Lingo@local_minio_9000",
    "s3.region" = "us-east-1",
    "s3.root.path" = "ateng-doris/",
    "s3.bucket" = "doris",
    "use_path_style" = "true",
    "provider" = "S3"
    );
```

**设置默认 Storage Vault**

```
SET minio_vault AS DEFAULT STORAGE VAULT;
```

**查看 Storage Vault**

```
SHOW STORAGE VAULTS\G;
```



## 设置开机自启

### 停止服务

所有节点都需要先停止服务，然后再配置开机自启

**停止BE**

```
$DORIS_BE_HOME/bin/stop_be.sh
```

**停止FE**

```
$DORIS_FE_HOME/bin/stop_fe.sh
```

**停止元数据服务**

```
$DORIS_RE_HOME/bin/stop.sh
$DORIS_MS_HOME/bin/stop.sh
```

### 设置自启

**Meta Service服务**

> 在预设的节点上配置，这里是bigdata01节点

创建配置文件

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
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable --now doris-meta.service
sudo systemctl status doris-meta.service
```

**Recycler服务**

> 在预设的节点上配置，这里是bigdata01节点

创建配置文件

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
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable --now doris-recycler.service
sudo systemctl status doris-recycler.service
```

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

**查看计算组**

```
mysql> SHOW COMPUTE GROUPS;
+-----------------------+-----------+-------+------------+
| Name                  | IsCurrent | Users | BackendNum |
+-----------------------+-----------+-------+------------+
| default_compute_group | TRUE      |       | 3          |
+-----------------------+-----------+-------+------------+
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
