# FoundationDB

FoundationDB 是一个开源的分布式数据库系统，最初由 FoundationDB 公司开发，后被 Apple 收购并开源。它的设计目标是高性能、可扩展性和强一致性，并且支持多种数据模型。通过其独特的架构，FoundationDB 提供了一个统一的、键值对存储的底层数据库，其他数据模型（如文档、关系型等）都可以基于它构建。

- [GitHub地址](https://github.com/apple/foundationdb)

- [官方文档](https://apple.github.io/foundationdb/configuration.html?highlight=fdbserver#fdbserver-section)

## 前置条件

- 参考：[基础配置](/work/service/00-basic/)

## 单节点安装

服务器信息

| IP            | 主机名    | 说明 |
| ------------- | --------- | ---- |
| 192.168.1.112 | bigdata01 |      |

### 1. 下载 FoundationDB 二进制文件

从 GitHub 官方页面下载 FoundationDB 的各个组件：

```bash
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbbackup.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbcli.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbserver.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbmonitor.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/libfdb_c.x86_64.so
```

> **说明**：这些文件包含 FoundationDB 的备份工具、命令行工具、数据库服务器、监控管理程序以及客户端库，确保功能完整。

### 2. 移动文件并赋予执行权限

将下载的二进制文件移动到 `/usr/local/bin`，并设置文件为可执行：

```bash
mkdir -p /usr/local/software/foundationdb-7.3.43/bin
ln -s /usr/local/software/foundationdb-7.3.43 /usr/local/software/foundationdb

mv fdbbackup.x86_64 /usr/local/software/foundationdb/bin/fdbbackup
mv fdbcli.x86_64 /usr/local/software/foundationdb/bin/fdbcli
mv fdbmonitor.x86_64 /usr/local/software/foundationdb/bin/fdbmonitor
mv fdbserver.x86_64 /usr/local/software/foundationdb/bin/fdbserver

chmod +x /usr/local/software/foundationdb/bin/*

ln -s /usr/local/software/foundationdb/bin/fdbbackup /usr/local/software/foundationdb/bin/backup_agent
```

> **注意**：将 `fdbbackup` 设置为 `backup_agent` 的符号链接有助于简化后续的备份操作。

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## FDB_HOME
export FDB_HOME=/usr/local/software/foundationdb
export PATH=$PATH:$FDB_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
$ fdbserver --version
FoundationDB 7.3 (v7.3.43)
source version 412531b5c97fa84343da94888cc949a4d29e8c29
protocol fdb00b073000000
```

### 3. 创建目录结构与配置文件

创建 FoundationDB 所需的配置文件目录、数据存储目录和日志存储目录：

```bash
sudo mkdir -p /etc/foundationdb
sudo touch /etc/foundationdb/foundationdb.conf
sudo mkdir -p /data/service/foundationdb/data/4500
sudo mkdir -p /data/service/foundationdb/log
sudo chown -R admin:ateng /etc/foundationdb /data/service/foundationdb
```

> **说明**：
>
> - `/etc/foundationdb` 用于存放配置文件。
> - `/data/foundationdb/data/4500` 是数据存储目录，`4500` 表示服务端口。
> - `/data/foundationdb/log` 是日志存储目录。
> - 使用 `chown` 命令修改文件夹权限，确保指定用户有权限进行操作。

### 4. 配置集群文件

创建 `fdb.cluster` 文件，用于存储集群信息：

```bash
cat > /etc/foundationdb/fdb.cluster <<"EOF"
mycluster:abcd1234abcd5678@bigdata01:4500
EOF
```

> **注意**：`mycluster` 是集群名称，`abcd1234abcd5678` 是集群密钥，请替换为实际密钥和 IP 地址或映射。

### 5. 编辑 FoundationDB 配置文件

在 `foundationdb.conf` 文件中配置 `fdbmonitor` 和 `fdbserver`，使服务按预期运行：

```bash
cat > /etc/foundationdb/foundationdb.conf <<"EOF"
[fdbmonitor]
user = admin
group = ateng

[general]
restart-delay = 60
cluster-file = /etc/foundationdb/fdb.cluster

[fdbserver]
command = /usr/local/software/foundationdb/bin/fdbserver
public-address = auto:$ID
listen-address = public
datadir = /data/service/foundationdb/data/$ID
logdir = /data/service/foundationdb/log
memory = 4GiB

[fdbserver.4500]

[backup_agent]
command = /usr/local/software/foundationdb/bin/backup_agent
logdir = /data/service/foundationdb/log

[backup_agent.1]
EOF
```

> **说明**：
>
> - `[fdbmonitor]`：定义监控进程的运行用户和组。
> - `[fdbserver]`：配置服务器的监听地址、数据存储路径、日志路径等。
> - `$ID` 是服务器实例的标识符，`4500` 是端口号。

### 6. 启动 FoundationDB 服务

使用 `systemd` 配置FoundationDB服务

```
sudo tee /etc/systemd/system/foundationdb.service <<"EOF"
[Unit]
Description=FoundationDB Monitor
Documentation=https://apple.github.io/foundationdb/
After=network.target

[Service]
Type=simple
User=admin
Group=ateng
ExecStart=/usr/local/software/foundationdb/bin/fdbmonitor --conffile /etc/foundationdb/foundationdb.conf --lockfile /tmp/fdbmonitor.pid
ExecStop=/bin/kill -s TERM $MAINPID
PIDFile=/tmp/fdbmonitor.pid
PrivateTmp=true
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl start foundationdb
sudo systemctl enable foundationdb
```

> **说明**：`fdbmonitor` 负责启动和管理 `fdbserver`，并在发生崩溃时自动重启服务。

### 7. 初始化集群配置

使用 `fdbcli` 初始化单节点 SSD 模式：

```bash
fdbcli -C /etc/foundationdb/fdb.cluster --exec 'configure new single ssd'
```

> **说明**：该命令将集群配置为单节点 SSD 模式，这是一种适用于单节点部署的存储类型。

### 8. 检查集群状态

运行以下命令，检查 FoundationDB 的集群状态，确保其正常运行：

```bash
fdbcli -C /etc/foundationdb/fdb.cluster --exec status
```

> **说明**：`status` 命令会显示集群的详细状态，包括健康状态、节点信息、数据存储状态等。

### 9. 使用示例

进入客户端

```
$ fdbcli -C /etc/foundationdb/fdb.cluster
Using cluster file `/etc/foundationdb/fdb.cluster'.

The database is available.

Welcome to the fdbcli. For help, type `help'.
fdb>
```

设置写模式

> 默认情况下 `fdbcli` 处于只读模式，为了在数据库中进行写操作（如 `set`、`clear` 键值），需要先启用 `writemode`。完成写操作后，建议将写模式关闭，以避免意外的数据修改：

```
fdb> writemode on
fdb> writemode off
```

设置键值对

```
fdb> set mykey myvalue
```

获取键值

```
fdb> get mykey
```

查看key

```
fdb> getrange "" \xff
fdb> getrange a z
```

删除键

```
fdb> clear mykey
```



## 分布式集群安装

服务器信息

| IP            | 主机名    | 说明 |
| ------------- | --------- | ---- |
| 192.168.1.112 | bigdata01 |      |
| 192.168.1.113 | bigdata02 |      |
| 192.168.1.114 | bigdata03 |      |

### 1. 下载 FoundationDB 二进制文件

从 GitHub 官方页面下载 FoundationDB 的各个组件：

```bash
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbbackup.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbcli.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbserver.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/fdbmonitor.x86_64
wget https://github.com/apple/foundationdb/releases/download/7.3.43/libfdb_c.x86_64.so
```

> **说明**：这些文件包含 FoundationDB 的备份工具、命令行工具、数据库服务器、监控管理程序以及客户端库，确保功能完整。

### 2. 移动文件并赋予执行权限

将下载的二进制文件移动到 `/usr/local/bin`，并设置文件为可执行：

```bash
mkdir -p /usr/local/software/foundationdb-7.3.43/bin
ln -s /usr/local/software/foundationdb-7.3.43 /usr/local/software/foundationdb

mv fdbbackup.x86_64 /usr/local/software/foundationdb/bin/fdbbackup
mv fdbcli.x86_64 /usr/local/software/foundationdb/bin/fdbcli
mv fdbmonitor.x86_64 /usr/local/software/foundationdb/bin/fdbmonitor
mv fdbserver.x86_64 /usr/local/software/foundationdb/bin/fdbserver

chmod +x /usr/local/software/foundationdb/bin/*

ln -s /usr/local/software/foundationdb/bin/fdbbackup /usr/local/software/foundationdb/bin/backup_agent
```

> **注意**：将 `fdbbackup` 设置为 `backup_agent` 的符号链接有助于简化后续的备份操作。

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## FDB_HOME
export FDB_HOME=/usr/local/software/foundationdb
export PATH=$PATH:$FDB_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
$ fdbserver --version
FoundationDB 7.3 (v7.3.43)
source version 412531b5c97fa84343da94888cc949a4d29e8c29
protocol fdb00b073000000
```

### 3. 创建目录结构与配置文件

创建 FoundationDB 所需的配置文件目录、数据存储目录和日志存储目录：

```bash
sudo mkdir -p /etc/foundationdb
sudo touch /etc/foundationdb/foundationdb.conf
sudo mkdir -p /data/service/foundationdb/data/4500
sudo mkdir -p /data/service/foundationdb/log
sudo chown -R admin:ateng /etc/foundationdb /data/service/foundationdb
```

> **说明**：
>
> - `/etc/foundationdb` 用于存放配置文件。
> - `/data/foundationdb/data/4500` 是数据存储目录，`4500` 表示服务端口。
> - `/data/foundationdb/log` 是日志存储目录。
> - 使用 `chown` 命令修改文件夹权限，确保指定用户有权限进行操作。

### 4. 配置集群文件

创建 `fdb.cluster` 文件，用于存储集群信息：

```bash
cat > /etc/foundationdb/fdb.cluster <<"EOF"
mycluster:abcd1234abcd5678@bigdata01:4500,bigdata02:4500,bigdata03:4500
EOF
```

> **注意**：`mycluster` 是集群名称，`abcd1234abcd5678` 是集群密钥，请替换为实际密钥和 IP 地址或映射。

### 5. 编辑 FoundationDB 配置文件

在 `foundationdb.conf` 文件中配置 `fdbmonitor` 和 `fdbserver`，使服务按预期运行：

```bash
cat > /etc/foundationdb/foundationdb.conf <<"EOF"
[fdbmonitor]
user = admin
group = ateng

[general]
restart-delay = 60
cluster-file = /etc/foundationdb/fdb.cluster

[fdbserver]
command = /usr/local/software/foundationdb/bin/fdbserver
public-address = auto:$ID
listen-address = public
datadir = /data/service/foundationdb/data/$ID
logdir = /data/service/foundationdb/log
memory = 4GiB

[fdbserver.4500]

[backup_agent]
command = /usr/local/software/foundationdb/bin/backup_agent
logdir = /data/service/foundationdb/log

[backup_agent.1]
EOF
```

> **说明**：
>
> - `[fdbmonitor]`：定义监控进程的运行用户和组。
> - `[fdbserver]`：配置服务器的监听地址、数据存储路径、日志路径等。
> - `$ID` 是服务器实例的标识符，`4500` 是端口号。

### 6. 启动 FoundationDB 服务

使用 `systemd` 配置FoundationDB服务

```
sudo tee /etc/systemd/system/foundationdb.service <<"EOF"
[Unit]
Description=FoundationDB Monitor
Documentation=https://apple.github.io/foundationdb/
After=network.target

[Service]
Type=simple
User=admin
Group=ateng
ExecStart=/usr/local/software/foundationdb/bin/fdbmonitor --conffile /etc/foundationdb/foundationdb.conf --lockfile /tmp/fdbmonitor.pid
ExecStop=/bin/kill -s TERM $MAINPID
PIDFile=/tmp/fdbmonitor.pid
PrivateTmp=true
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl start foundationdb
sudo systemctl enable foundationdb
```

> **说明**：`fdbmonitor` 负责启动和管理 `fdbserver`，并在发生崩溃时自动重启服务。

### 7. 初始化集群配置

使用 `fdbcli` 初始化集群：

> configure new double ssd: 适用于分布式集群，提供更高的容错性（两份数据副本）
>
> configure new triple ssd: 提供三份数据副本，更高的数据可用性和容错性

```bash
fdbcli -C /etc/foundationdb/fdb.cluster --exec 'configure new triple ssd'
```

配置协调器（Coordinator）

> 在一个节点上，通过 `fdbcli` 指定集群的协调器节点。`coordinators auto` 会自动选择当前集群中的节点作为协调器。建议至少配置 3 个协调器节点以保证高可用性。

```
fdbcli -C /etc/foundationdb/fdb.cluster --exec "coordinators auto"
```

### 8. 检查集群状态

运行以下命令，检查 FoundationDB 的集群状态，确保其正常运行：

```bash
fdbcli -C /etc/foundationdb/fdb.cluster --exec status
```

> **说明**：`status` 命令会显示集群的详细状态，包括健康状态、节点信息、数据存储状态等。

### 9. 使用示例

进入客户端

```
$ fdbcli -C /etc/foundationdb/fdb.cluster
Using cluster file `/etc/foundationdb/fdb.cluster'.

The database is available.

Welcome to the fdbcli. For help, type `help'.
fdb>
```

设置写模式

> 默认情况下 `fdbcli` 处于只读模式，为了在数据库中进行写操作（如 `set`、`clear` 键值），需要先启用 `writemode`。完成写操作后，建议将写模式关闭，以避免意外的数据修改：

```
fdb> writemode on
fdb> writemode off
```

设置键值对

```
fdb> set mykey myvalue
```

获取键值

```
fdb> get mykey
```

查看key

```
fdb> getrange "" \xff
fdb> getrange a z
```

删除键

```
fdb> clear mykey
```

