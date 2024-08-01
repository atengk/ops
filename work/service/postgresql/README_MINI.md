# 编译和安装PostgreSQL

最小化安装，没有安装额外的插件扩展



**安装依赖工具和库**

```
sudo yum -y install gcc gcc-c++ libicu-devel readline-devel zlib-devel
```

**下载 PostgreSQL 源码**

下载PostgreSQL源码：https://www.postgresql.org/ftp/source/

```
wget https://ftp.postgresql.org/pub/source/v16.3/postgresql-16.3.tar.gz
tar -xzf postgresql-16.3.tar.gz
cd postgresql-16.3
```

**配置**

运行 `./configure` 脚本来检测系统环境并生成相应的Makefile。你可以指定安装目录以及其他选项。例如：

```
./configure --prefix=/usr/local/software/postgresql-16.3
```

**编译和安装**

使用 `make` 命令编译源码：

```
make -j$(nproc)
```

编译完成后，使用以下命令进行安装：

```
make install
```

**编译和安装插件**

```
cd contrib
make -j$(nproc)
make install
```

**查看目录**

```
ll /usr/local/software/postgresql-16.3
ll /usr/local/software/postgresql-16.3/share/extension
/usr/local/software/postgresql-16.3/bin/pg_ctl --version
```

**更新库缓存**

```
echo "/usr/local/software/postgresql-16.3/lib" | sudo tee /etc/ld.so.conf.d/postgresql-16.3.conf
sudo ldconfig
```



# 配置PostgreSQL

## 基础配置

**创建软链接**

```
ln -s /usr/local/software/postgresql-16.3 /usr/local/software/postgresql
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## POSTGRESQL_HOME
export POSTGRESQL_HOME=/usr/local/software/postgresql
export PATH=$PATH:$POSTGRESQL_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
pg_ctl --version
```

## 初始化

**初始化数据目录**

```sh
initdb -D /data/service/postgresql
```

## **修改配置文件**

**配置include目录**

```
$ vi +810 /data/service/postgresql/postgresql.conf
include_dir = 'conf.d'
$ mkdir /data/service/postgresql/conf.d
```

**创建配置文件**

```
cat > /data/service/postgresql/conf.d/override.conf <<EOF
port = 5432
listen_addresses = '0.0.0.0'
max_connections = 1024
shared_buffers = 4GB
work_mem = 64MB
max_parallel_workers_per_gather = 4
max_parallel_maintenance_workers = 2
max_parallel_workers = 8
wal_level = 'logical'
log_timezone = 'Asia/Shanghai'
timezone = 'Asia/Shanghai'
EOF
```

**配置客户端认证**

编辑 `pg_hba.conf` 文件以允许远程连接。添加一行以允许所有IP地址的所有用户使用密码认证（你可以根据需要限制访问）：

```
cat >> /data/service/postgresql/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
```

如果你只想允许特定IP地址范围，你可以更改 `0.0.0.0/0` 为一个更具体的CIDR地址范围，例如 `192.168.1.0/24`。

## 启动服务

**配置系统服务**：

创建一个systemd服务文件以便管理PostgreSQL服务：

```
sudo tee /etc/systemd/system/postgresql.service <<"EOF"
[Unit]
Description=PostgreSQL database server
After=network-online.target

[Service]
Type=forking
Restart=always
RestartSec=10
User=admin
Group=ateng
ExecStart=/usr/local/software/postgresql/bin/pg_ctl -D /data/service/postgresql --log /data/service/postgresql/postgresql.log start
ExecStop=/usr/local/software/postgresql/bin/pg_ctl stop -D /data/service/postgresql -s -m fast
ExecReload=/usr/local/software/postgresql/bin/pg_ctl reload -D /data/service/postgresql -s

[Install]
WantedBy=multi-user.target
EOF
```

**重新加载systemd并启动PostgreSQL服务**

```
sudo systemctl daemon-reload
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## 创建用户

**登录PostgreSQL**

```
psql -d postgres
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
