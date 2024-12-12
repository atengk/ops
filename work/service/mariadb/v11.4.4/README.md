# 编译安装MariaDB Galera

MariaDB 是 MySQL 的一个分支，具有高性能、开源、兼容性强等特点。它提供关系型数据库管理功能，支持多种存储引擎和复杂查询操作，适用于各种应用场景。

MariaDB Galera 是 MariaDB 的高可用性解决方案，基于 Galera Cluster 技术，支持多主同步复制。它允许所有节点都能进行读写操作，提供数据一致性和自动故障恢复，适合对高可用性和扩展性要求较高的数据库环境。

本文档在**OpenEuler 24.03**操作系统已验证通过。例如CentOS7系统不适用，其系统版本软件包太低，导致很多依赖软件包版本不符合要求，就导致编译安装非常繁琐，所以CentOS7选择其他方式安装，例如官网提供的YUM。

**参考文档：**

- [MariaDB 构建环境设置](https://mariadb.com/kb/en/Build_Environment_Setup_for_Linux/)
- [Galera 集群安装文档](https://galeracluster.com/library/documentation/install-mariadb-src.html)

| IP            | 主机名    | 描述     |
| ------------- | --------- | -------- |
| 192.168.1.112 | service01 | 初始节点 |
| 192.168.1.113 | service02 |          |
| 192.168.1.114 | service03 |          |

## 前置条件

- 参考：[基础配置](/work/service/00-basic/)

## 1. 安装MariaDB

首先，下载MariaDB的源码包并安装必要的依赖：

```bash
wget https://archive.mariadb.org/mariadb-11.4.4/source/mariadb-11.4.4.tar.gz
sudo dnf -y install gcc-c++ libaio-devel ncurses-devel zlib-devel openssl-devel cmake make fmt-devel pcre2-devel boost-devel check-devel socat
```

解压并编译安装MariaDB：

```bash
tar -xzvf mariadb-11.4.4.tar.gz
cd mariadb-11.4.4
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/software/mariadb-11.4.4
make -j$(nproc)
make install
```

**说明：**

- `cmake` 命令中的 `-DCMAKE_INSTALL_PREFIX` 参数指定了MariaDB的安装路径，你可以根据需要调整路径。
- `make -j$(nproc)` 命令中的 `$(nproc)` 会自动检测可用的CPU核心数，以加速编译过程。

## 2. 安装Galera

下载Galera库的源码包并解压：

```bash
wget https://archive.mariadb.org/mariadb-11.4.4/galera-26.4.20/src/galera-26.4.20.tar.gz
tar -zxvf galera-26.4.20.tar.gz
```

接下来，编译并安装Galera：

```bash
cd galera-26.4.20
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/software/mariadb-11.4.4
make -j$(nproc)
make install
```



## 3. 基础配置

### 3.1 设置软链接

为了便于管理，可以创建MariaDB的软链接：

```bash
ln -s /usr/local/software/mariadb-11.4.4 /usr/local/software/mariadb
```

### 3.2 配置环境变量

将MariaDB的路径添加到环境变量中，使得系统可以识别`mariadb`命令：

```bash
cat >> ~/.bash_profile <<"EOF"
## MARIADB_HOME
export MARIADB_HOME=/usr/local/software/mariadb
export PATH=$PATH:$MARIADB_HOME/bin
EOF
source ~/.bash_profile
```

### 3.3 查看安装版本

执行以下命令确认MariaDB安装成功：

```bash
$ mariadb -V
mariadb from 11.4.4-MariaDB, client 15.2 for Linux (x86_64) using readline 5.1
```



## 4. 启动服务

### 4.1 服务配置文件

创建MariaDB的配置文件`my.cnf`，并进行基础配置。

```bash
cat > $MARIADB_HOME/my.cnf <<"EOF"
[mariadbd]
skip-name-resolve
explicit_defaults_for_timestamp
basedir=/usr/local/software/mariadb
port=3306
socket=/usr/local/software/mariadb/mariadb.sock
datadir=/data/service/mariadb/data
tmpdir=/data/service/mariadb/tmp
max_allowed_packet=100M
bind-address=0.0.0.0
pid-file=/usr/local/software/mariadb/mariadbd.pid
log-error=/data/service/mariadb/logs/mariadbd.log
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
slow_query_log=0
slow_query_log_file=/data/service/mariadb/logs/slow_query.log
long_query_time=10.0
default_time_zone="+8:00"
lower_case_table_names=0
max_connections=1024
max_connect_errors=1024
server-id=1
log-bin=mariadb-bin
max_binlog_size=1024M
binlog_expire_logs_seconds=86400
binlog_format=row
sync_binlog=0
[client]
port=3306
socket=/usr/local/software/mariadb/mariadb.sock
default-character-set=utf8mb4
EOF
```

### 4.2 初始化服务

**创建目录**

```
mkdir -p /data/service/mariadb/{data,tmp,logs}
```

初始化服务

> 只需要初始节点，也就是第一个节点做初始化的步骤，其他节点不需要初始化，只需要配置Galera集群后启动即可。

```
$MARIADB_HOME/scripts/mariadb-install-db --defaults-file=$MARIADB_HOME/my.cnf
```

### 4.3 启动服务

**配置systemd**

```
sudo tee /usr/lib/systemd/system/mariadbd.service <<"EOF"
[Unit]
Description=MariaDB Server
After=network-online.target
[Service]
ExecStart=/usr/local/software/mariadb/bin/mariadbd-safe --defaults-file=/usr/local/software/mariadb/my.cnf
ExecStop=/usr/local/software/mariadb/bin/mariadb-admin --defaults-file=/usr/local/software/mariadb/my.cnf shutdown
Type=simple
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
sudo systemctl start mariadbd
sudo systemctl enable mariadbd
```



## 5. 设置服务

确认MariaDB服务正常运行后，可以通过以下命令访问MariaDB命令行界面：

```
mariadb
```

**设置管理员用户**

```
grant all on *.* to 'admin'@'localhost' identified by 'Admin@123';
grant all on *.* to 'root'@'localhost' identified by 'Admin@123';
grant all on *.* to 'root'@'%' identified by 'Admin@123';
```

**创建备份用户**

```
grant all on *.* to 'mariabackup'@'localhost' identified by 'Admin@123';
```

**配置管理员参数**

```
cat >> $MARIADB_HOME/my.cnf <<EOF
[mariadb-admin]
user=root
password=Admin@123
EOF
```



## 6. Galera配置

### 6.1 第一个节点配置

在第一个节点上，进行Galera集群的初始配置。以下是`my.cnf`文件的完整配置内容：

```bash
cat >> $MARIADB_HOME/my.cnf <<EOF
[galera]
wsrep_on=on
wsrep_provider=/usr/local/software/mariadb/lib/libgalera_smm.so
wsrep_cluster_address=gcomm://
wsrep_cluster_name=my_galera_cluster
wsrep_node_name=service01
wsrep_node_address=192.168.1.112
wsrep_sst_method=mariabackup
wsrep_sst_auth=mariabackup:Admin@123
wsrep_slave_threads=4
wsrep_mode=REPLICATE_MYISAM
innodb_flush_log_at_trx_commit=2
EOF
```

完成配置后，重新启动MariaDB服务以应用新配置：

```bash
sudo systemctl restart mariadbd
```

### 6.2 其他节点配置

在集群中的其他节点上，进行类似的配置，并指定其他节点的IP地址以连接到集群。以下是完整的`my.cnf`配置内容：

其余节点配置

```bash
cat >> $MARIADB_HOME/my.cnf <<EOF
[galera]
wsrep_on=on
wsrep_provider=/usr/local/software/mariadb/lib/libgalera_smm.so
wsrep_cluster_address=gcomm://192.168.1.112,192.168.1.113,192.168.1.114
wsrep_cluster_name=my_galera_cluster
wsrep_node_name=service02
wsrep_node_address=192.168.1.113
wsrep_sst_method=mariabackup
wsrep_sst_auth=mariabackup:Admin@123
wsrep_slave_threads=4
wsrep_mode=REPLICATE_MYISAM
innodb_flush_log_at_trx_commit=2
EOF
```

完成配置后，重新启动MariaDB服务以应用新配置：

```bash
sudo systemctl restart mariadbd
```

### 6.3 查看集群

```sql
MariaDB [(none)]> show status like "wsrep_cluster_size";
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 3     |
+--------------------+-------+
MariaDB [(none)]> show status like "wsrep_incoming_addresses";
+--------------------------+----------------------------------------------------------+
| Variable_name            | Value                                                    |
+--------------------------+----------------------------------------------------------+
| wsrep_incoming_addresses | 192.168.1.112:3306,192.168.1.113:3306,192.168.1.114:3306 |
+--------------------------+----------------------------------------------------------+
```

### 6.4 修改第一个节点配置

当所有集群都建立连接后，可以修改初始节点，也就是第一个节点配置，将wsrep_cluster_address配置上集群的IP地址。

```bash
$ vi +39 $MARIADB_HOME/my.cnf
wsrep_cluster_address=gcomm://192.168.1.112,192.168.1.113,192.168.1.114
```

配置完后重启服务

```bash
sudo systemctl restart mariadbd
```



## 7. 负载均衡连接

为了实现数据库集群的负载均衡，可以使用JDBC的自动重试机制：

```
jdbc:mariadb:loadbalance://192.168.1.112:3306,192.168.1.113:3306/kongyu
```



## 8. 创建数据

创建数据库

```sql
create database kongyu;
```

创建用户

```sql
grant all on kongyu.* to 'kongyu'@'%' identified by 'Admin@123';
```

创建用户表

```sql
USE kongyu;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

插入示例数据

```sql
INSERT INTO users (username, password, email) VALUES
('user1', 'password1', 'user1@example.com'),
('user2', 'password2', 'user2@example.com'),
('user3', 'password3', 'user3@example.com');
```

查看数据

```
SELECT * FROM users;
```



## 9. 集群故障恢复

### 9.1 断电启动

集群断点启动后，服务一直拉不起来的情况。选择集群任一节点，例如service01

1. 修改grastate.dat文件，将safe_to_bootstrap改为1

```
$ cat /data/service/mariadb/data/grastate.dat
# GALERA saved state
version: 2.1
uuid:    78d7e7d1-571c-11ef-9494-d2dd33f9c962
seqno:   -1
safe_to_bootstrap: 1
```

2. 修改配置文件，将**wsrep_cluster_address**配置为初始化状态

```
$ vi $MARIADB_HOME/my.cnf
wsrep_cluster_address=gcomm://
```

3. 重启节点服务

```
sudo systemctl restart mariadbd
```

4. 重启其他节点服务

待集群正常后再进行下一步

```
sudo systemctl restart mariadbd
```

5. 修改service01的配置

```
$ vi $MARIADB_HOME/my.cnf
wsrep_cluster_address=gcomm://192.168.1.112,192.168.1.113,192.168.1.114
$ sudo systemctl restart mariadbd
```

6. 查看集群

```
show status like "wsrep_incoming_addresses";
```



### 9.1 正常离线

集群全部正常离线，使用systemctl正常停止服务的情况。

1. 查看grastate.dat文件，找到**safe_to_bootstrap: 1**的节点并且注意**seqno**为集群的最大值，假如这里是service03节点

```
$ cat /data/service/mariadb/data/grastate.dat
# GALERA saved state
version: 2.1
uuid:    78d7e7d1-571c-11ef-9494-d2dd33f9c962
seqno:   19
safe_to_bootstrap: 1
```

2. 将service03节点的**wsrep_cluster_address**配置为初始化状态

```
$ vi $MARIADB_HOME/my.cnf
wsrep_cluster_address=gcomm://
```

3. 重启service03节点服务

```
sudo systemctl restart mariadbd
```

4. 重启其他节点服务

待集群正常后再进行下一步

```
sudo systemctl restart mariadbd
```

5. 修改service03的配置

```
$ vi $MARIADB_HOME/my.cnf
wsrep_cluster_address=gcomm://192.168.1.112,192.168.1.113,192.168.1.114
$ sudo systemctl restart mariadbd
```

6. 查看集群

```
show status like "wsrep_incoming_addresses";
```

