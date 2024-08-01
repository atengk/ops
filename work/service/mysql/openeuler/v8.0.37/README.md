# 安装MySQL

本文档使用**OpenEuler 24.03**操作系统，参考[官方文档](https://dev.mysql.com/doc/refman/8.4/en/binary-installation.html)



## 安装软件包

**查看可用软件包**

```
dnf list mysql-server --showduplicates
```

**安装指定版本软件包**

```
sudo dnf install -y mysql-8.0.37 mysql-server-8.0.37 mysql-common-8.0.37 mysql-config-8.0.37
```

**查看版本**

```
mysql -V
```

## 启动服务

服务配置文件

```
sudo tee /etc/my.cnf.d/mysql-server.cnf <<"EOF"
[mysqld]
authentication_policy=caching_sha2_password
skip-name-resolve
mysqlx=0
explicit_defaults_for_timestamp
port=3306
datadir=/data/service/mysql
socket=/data/service/mysql/mysql.sock
log-error=/data/service/mysql/mysqld.log
pid-file=/run/mysqld/mysqld.pid
max_allowed_packet=100M
bind-address=0.0.0.0
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
slow_query_log=1
slow_query_log_file=/data/service/mysql/slow_query.log
long_query_time=10.0
default_time_zone = "+8:00"
lower_case_table_names = 0
max_connections = 1024
max_connect_errors = 1024
skip-log-bin
[client]
port=3306
default-character-set=utf8mb4
socket=/data/service/mysql/mysql.sock
EOF
```

创建目录

```
mkdir -p /data/service/mysql
sudo chown mysql:mysql /data/service/mysql
```

启动服务

```
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

创建普通用户

```
## 创建数据库
create database kongyu;
## 创建用户
create user kongyu@'%' identified by 'kongyu';
grant all privileges on kongyu.* to kongyu@'%' with grant option;
create user kongyu@'localhost' identified by 'kongyu';
grant all privileges on kongyu.* to kongyu@'localhost' with grant option;
```



# 配置主从

确保你有两台服务器或两台虚拟机，一台作为主服务器（Master），一台作为从服务器（Slave）。安装好MySQL 8并进行基本的配置。

### 编辑MySQL配置文件

> `server-id`是MySQL实例的唯一标识符，必须确保在集群中唯一。`log-bin`用于启用二进制日志记录，这是主从复制所需的。

主服务器修改server-id

```
$ sudo vi /etc/my.cnf.d/mysql-server.cnf
[mysqld]
...
server-id=1
log-bin=mysql-bin
max_binlog_size=1024M
binlog_expire_logs_seconds=2592000
binlog-ignore-db=mysql,information_schema,performance_schema,sys
```

从服务器修改server-id

```
$ sudo vi /etc/my.cnf.d/mysql-server.cnf
[mysqld]
...
server-id=2
```

重启服务

```
sudo systemctl restart mysqld
```

### 创建复制用户

登录到MySQL主服务器并创建一个用于复制的用户。

```sql
$ mysql -uroot -pAdmin@123
CREATE USER 'replica'@'%' IDENTIFIED BY 'Admin@123';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
```

### 锁定数据库并获取二进制日志坐标

登录到MySQL主服务器并锁定数据库以确保数据一致性，并获取二进制日志的坐标。

```sql
$ mysql -uroot -pAdmin@123
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
```

记下输出的`File`和`Position`值。这将在配置从服务器时使用。

### 配置复制

登录到MySQL从服务器，并配置复制。

```sql
$ mysql -uroot -pAdmin@123
CHANGE MASTER TO
MASTER_HOST='service01',
MASTER_PORT=3306,
MASTER_USER='replica',
MASTER_PASSWORD='Admin@123',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=863,
GET_MASTER_PUBLIC_KEY=1;
```

启动复制进程：

```
START REPLICA;
```

### 验证复制

在从服务器上检查复制状态：

```sql
SHOW REPLICA STATUS\G;
```

确保`Slave_IO_Running`和`Slave_SQL_Running`都显示为`Yes`。如果有任何错误，可以根据错误信息进行排查。

在主服务器上查看复制节点：

```
SHOW REPLICAS;
```

### 解锁主服务器

在主服务器上解锁数据库：

```
UNLOCK TABLES;
```



# 创建数据

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

