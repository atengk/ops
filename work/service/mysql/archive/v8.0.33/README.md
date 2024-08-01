# 安装MySQL



## 安装软件包

解压软件包

```
tar -zxvf mysql-community-v8.0.33.tar.gz
cd mysql-community-v8.0.33/
```

安装依赖包

```
yum -y install perl net-tools
```

安装客户端依赖

```
rpm -Uvh mysql-community-client-plugins-8.0.33-1.el7.x86_64.rpm mysql-community-libs-8.0.33-1.el7.x86_64.rpm mysql-community-common-8.0.33-1.el7.x86_64.rpm mysql-community-libs-compat-8.0.33-1.el7.x86_64.rpm
```

安装客户端

```
rpm -ivh mysql-community-client-8.0.33-1.el7.x86_64.rpm
```

安装服务端

```
rpm -ivh mysql-community-icu-data-files-8.0.33-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-8.0.33-1.el7.x86_64.rpm
```

## 启动服务

编辑配置文件

```
cat > /etc/my.cnf <<"EOF"
[mysqld]
authentication_policy=caching_sha2_password
skip-name-resolve
explicit_defaults_for_timestamp
basedir=/usr/
plugin_dir=/usr/lib64/mysql/plugin
lc-messages-dir=/usr/share/mysql-8.0
port=3306
socket=/var/lib/mysql/mysql.sock
datadir=/data/service/mysql/data
tmpdir=/data/service/mysql/tmp
max_allowed_packet=100M
bind-address=0.0.0.0
pid-file=/var/lib/mysql/mysqld.pid
log-error=/data/service/mysql/logs/mysqld.log
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
slow_query_log=1
slow_query_log_file=/data/service/mysql/logs/slow_query.log
long_query_time=10.0
default_time_zone = "+8:00"
lower_case_table_names = 1
max_connections = 1024
max_connect_errors = 50
server-id=1
log-bin=mysql-bin
max_binlog_size=200M
binlog_expire_logs_seconds=604800
[client]
port=3306
socket=/var/lib/mysql/mysql.sock
default-character-set=UTF8
plugin_dir=/usr/lib64/mysql/plugin
EOF
```

创建目录

```
mkdir -p /data/service/mysql/{data,tmp,logs}
chown mysql:mysql -R /data/service/mysql
```

关闭SELinux

> 如果改变MySQL的存储目录，需要关闭SELinux

```
setenforce 0
```

启动服务

```
systemctl daemon-reload
systemctl start mysqld
systemctl enable mysqld
```

## 设置服务

查看密码

```
grep 'temporary password' /data/service/mysql/logs/mysqld.log
```

访问服务

```
mysql -uroot -p
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
## 如果需要使用简单密码，需要修改系统参数:
set global validate_password.policy=0;
set global validate_password.length=4;
## 创建用户
create user kongyu@'%' identified by 'kongyu';
grant all privileges on kongyu.* to kongyu@'%' with grant option;
create user kongyu@'localhost' identified by 'kongyu';
grant all privileges on kongyu.* to kongyu@'localhost' with grant option;
```



# 升级MySQL

停止服务

```
systemctl stop mysqld
```

将全部的包一起升级，自动处理依赖问题

```
rpm -Uvh mysql-community-client-plugins-8.0.33-1.el7.x86_64.rpm mysql-community-libs-8.0.33-1.el7.x86_64.rpm mysql-community-common-8.0.33-1.el7.x86_64.rpm mysql-community-libs-compat-8.0.33-1.el7.x86_64.rpm mysql-community-client-8.0.33-1.el7.x86_64.rpm mysql-community-icu-data-files-8.0.33-1.el7.x86_64.rpm mysql-community-server-8.0.33-1.el7.x86_64.rpm
```

启动服务

```
systemctl start mysqld
```

使用服务

```
[root@localhost mysql-community-v8.0.33]# mysql -uroot -p
mysql> select version();
+-----------+
| version() |
+-----------+
| 8.0.33    |
+-----------+
1 row in set (0.00 sec)
```

