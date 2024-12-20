# 安装PostgreSQL

本文档使用**OpenEuler 24.03**操作系统



## 安装软件包

**查看可用软件包**

```
dnf list postgresql-server --showduplicates
```

**安装指定版本软件包**

```
sudo dnf -y install postgresql-server-15.6 postgresql-15.6 postgresql-contrib-15.6 
```

**查看版本**

```
pg_ctl --version
```

**修改数据目录**

```
$ sudo vi /usr/lib/systemd/system/postgresql.service
Environment=PGDATA=/data/service/postgresql
$ sudo systemctl daemon-reload
$ sudo mkdir -p /data/service/postgresql
$ sudo chown postgres:postgres /data/service/postgresql
```

**初始化目录**

```
sudo postgresql-setup --initdb
```

## **修改配置文件**

**配置include目录**

```
$ sudo vi +803 /data/service/postgresql/postgresql.conf
include_dir = 'conf.d'
$ sudo mkdir /data/service/postgresql/conf.d
```

**创建配置文件**

```
$ sudo tee /data/service/postgresql/conf.d/override.conf <<EOF
port = 5432
listen_addresses = '0.0.0.0'
max_connections = 1024
huge_pages = off
shared_buffers = 4GB
work_mem = 64MB
max_parallel_workers_per_gather = 4
max_parallel_maintenance_workers = 2
max_parallel_workers = 8
wal_level = 'logical'
log_timezone = 'Asia/Shanghai'
timezone = 'Asia/Shanghai'
EOF
$ sudo chown postgres:postgres -R /data/service/postgresql/conf.d
```

**配置客户端认证**

编辑 `pg_hba.conf` 文件以允许远程连接。添加一行以允许所有IP地址的所有用户使用密码认证（你可以根据需要限制访问）：

```
sudo tee -a /data/service/postgresql/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
```

如果你只想允许特定IP地址范围，你可以更改 `0.0.0.0/0` 为一个更具体的CIDR地址范围，例如 `192.168.1.0/24`。

## 启动服务

**启动PostgreSQL服务**

```
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## 创建用户

**登录PostgreSQL**

```
$ sudo su - postgres
$ psql
```

**创建超级用户**

```
CREATE USER root WITH PASSWORD 'Admin@123' SUPERUSER;
\du
```

创建数据库

```
CREATE DATABASE kongyu OWNER root;
```

使用超级用户远程访问

```
$ PGPASSWORD='Admin@123' psql -h 192.168.1.109 -p 5432 -U root kongyu
kongyu=# \l
```
