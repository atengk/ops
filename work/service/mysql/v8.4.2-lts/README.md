# 安装MySQL

本文档使用**OpenEuler 24.03**、**AnolisOS-8.9**操作系统，参考[官方文档](https://dev.mysql.com/doc/refman/8.4/en/binary-installation.html)

> glibc版本>=2.28都可以使用安装，查看方式`rpm -qa glibc`



## 安装软件包

下载软件包

```
wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.2-linux-glibc2.28-x86_64.tar.xz
```

解压软件包

```
tar -xvf mysql-8.4.2-linux-glibc2.28-x86_64.tar.xz -C /usr/local/software
ln -s /usr/local/software/mysql-8.4.2-linux-glibc2.28-x86_64 /usr/local/software/mysql
```

## 基础配置

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
mysql -V
```

## 启动服务

服务配置文件

```
cat > $MYSQL_HOME/my.cnf <<"EOF"
[mysqld]
authentication_policy=caching_sha2_password
skip-name-resolve
mysqlx=0
explicit_defaults_for_timestamp
basedir=/usr/local/software/mysql
port=3306
socket=/usr/local/software/mysql/mysql.sock
datadir=/data/service/mysql/data
tmpdir=/data/service/mysql/tmp
max_allowed_packet=100M
bind-address=0.0.0.0
pid-file=/usr/local/software/mysql/mysqld.pid
log-error=/data/service/mysql/logs/mysqld.log
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
slow_query_log=1
slow_query_log_file=/data/service/mysql/logs/slow_query.log
long_query_time=10.0
default_time_zone="+8:00"
lower_case_table_names=0
max_connections=1024
max_connect_errors=1024
server-id=1
log-bin=mysql-bin
max_binlog_size=1024M
binlog_expire_logs_seconds=2592000
[client]
port=3306
socket=/usr/local/software/mysql/mysql.sock
default-character-set=utf8mb4
EOF
```

创建目录

```
mkdir -p /data/service/mysql/{data,tmp,logs}
```

初始化服务

```
mysqld --defaults-file=$MYSQL_HOME/my.cnf --initialize-insecure
```

配置systemd

```
sudo tee /usr/lib/systemd/system/mysqld.service <<"EOF"
[Unit]
Description=MySQL Community Server
After=network-online.target
[Service]
ExecStart=/usr/local/software/mysql/bin/mysqld_safe --defaults-file=/usr/local/software/mysql/my.cnf
Type=simple
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
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

## 设置服务

访问服务

```
mysql -uroot
```

设置管理员用户

```
# 修改root@localhost本地用户密码
alter user user() identified by "Admin@123";
# 创建root@%远程用户和密码
create user root@'%' identified by 'Admin@123';
grant all privileges on *.* to root@'%' with grant option;
```



# 配置主从

确保你有两台服务器或两台虚拟机，一台作为主服务器（Master），一台作为从服务器（Slave）。安装好MySQL 8并进行基本的配置。

| IP                     | Server |
| ---------------------- | ------ |
| 192.168.1.112 server01 | 主服务 |
| 192.168.1.113 server02 | 从服务 |

## 编辑MySQL配置文件

> `server-id`是MySQL实例的唯一标识符，必须确保在集群中唯一。`log-bin`用于启用二进制日志记录，这是主从复制所需的。

主服务器修改server-id

```
$ vi +25 $MYSQL_HOME/my.cnf
[mysqld]
...
server-id=1
```

从服务器修改server-id

```
$ vi +25 $MYSQL_HOME/my.cnf 
[mysqld]
...
server-id=2
```

重启服务

```
sudo systemctl restart mysqld
```

## 创建复制用户

登录到MySQL主服务器并创建一个用于复制的用户。

```sql
$ mysql -uroot -pAdmin@123
CREATE USER 'replica'@'%' IDENTIFIED BY 'Admin@123';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
```

## 锁定数据库并获取二进制日志坐标

登录到MySQL主服务器并锁定数据库以确保数据一致性，并获取二进制日志的坐标。

```sql
$ mysql -uroot -pAdmin@123
FLUSH TABLES WITH READ LOCK;
SHOW BINARY LOGS;
```

记下输出的最新的`Log_name`和`File_size`值。这将在配置从服务器时使用。

## 配置复制

登录到MySQL从服务器，并配置复制。

```sql
$ mysql -uroot -pAdmin@123
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='server01',
SOURCE_PORT=3306,
SOURCE_USER='replica',
SOURCE_PASSWORD='Admin@123',
SOURCE_LOG_FILE='mysql-bin.000003',
SOURCE_LOG_POS=865,
GET_SOURCE_PUBLIC_KEY=1;
```

启动复制进程：

```
START REPLICA;
```

## 验证复制

在从服务器上检查复制状态：

```sql
SHOW REPLICA STATUS\G;
```

确保`Slave_IO_Running`和`Slave_SQL_Running`都显示为`Yes`。如果有任何错误，可以根据错误信息进行排查。

在主服务器上查看复制节点：

```
SHOW REPLICAS;
```

## 解锁主服务器

在主服务器上解锁数据库：

```
UNLOCK TABLES;
```



# 配置主主

确保已经配置好主从了，主主就是在从节点也开启bin-log，然后主节点和从节点互相同步

| IP                     | Server           |
| ---------------------- | ---------------- |
| 192.168.1.112 server01 | 主服务           |
| 192.168.1.113 server02 | 从服务 => 主服务 |

## 创建复制用户

登录到MySQL从服务器并创建一个用于复制的用户。

```sql
$ mysql -uroot -pAdmin@123
CREATE USER 'replica'@'%' IDENTIFIED BY 'Admin@123';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
```

## 锁定数据库并获取二进制日志坐标

登录到MySQL从服务器并锁定数据库以确保数据一致性，并获取二进制日志的坐标。

```sql
$ mysql -uroot -pAdmin@123
FLUSH TABLES WITH READ LOCK;
SHOW BINARY LOGS;
```

记下输出的最新的`Log_name`和`File_size`值。这将在配置从服务器时使用。

## 配置复制

登录到MySQL主服务器，并配置复制。

```sql
$ mysql -uroot -pAdmin@123
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='server02',
SOURCE_PORT=3306,
SOURCE_USER='replica',
SOURCE_PASSWORD='Admin@123',
SOURCE_LOG_FILE='mysql-bin.000003',
SOURCE_LOG_POS=879,
GET_SOURCE_PUBLIC_KEY=1;
```

启动复制进程：

```
START REPLICA;
```

## 验证复制

在主服务器上检查复制状态：

```sql
SHOW REPLICA STATUS\G;
```

确保`Slave_IO_Running`和`Slave_SQL_Running`都显示为`Yes`。如果有任何错误，可以根据错误信息进行排查。

在从服务器上查看复制节点：

```
SHOW REPLICAS;
```

## 解锁从服务器

在从服务器上解锁数据库：

```
UNLOCK TABLES;
```

## 负载均衡连接

使用 jdbc 的自动重试机制

```
jdbc:mysql:loadbalance://192.168.1.112:3306,192.168.1.113:3306/kongyu
```



# 创建数据

创建数据库

```sql
create database kongyu;
```

创建用户

```sql
create user kongyu@'%' identified by 'kongyu';
grant all privileges on kongyu.* to kongyu@'%' with grant option;
create user kongyu@'localhost' identified by 'kongyu';
grant all privileges on kongyu.* to kongyu@'localhost' with grant option;
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

