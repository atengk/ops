# Redis

Redis 是一个开源的高性能内存数据库，支持多种数据结构，包括字符串、哈希、列表、集合、有序集合等。它具有丰富的功能，如持久化、主从复制、集群、事务、发布/订阅等，能够实现高并发的访问。Redis 以其快速的读写速度，常用于缓存、会话存储、排行榜、实时分析、消息队列等场景，提升应用性能。它提供简单易用的接口，同时支持多种编程语言，广泛应用于互联网、游戏、电商等领域。

更多信息请参考官方文档：[https://redis.io/](https://redis.io/)

---

## 编译安装 Redis

**安装前先参考[前置条件](https://kongyu666.github.io/work/#/work/service/00-basic/)**

### 1. 安装依赖

首先安装编译所需的软件：

```bash
sudo yum -y install gcc make
```

### 2. 下载并解压 Redis

下载 Redis 源码包并解压：

```bash
wget https://download.redis.io/releases/redis-7.4.1.tar.gz
tar -zxvf redis-7.4.1.tar.gz
cd redis-7.4.1
```

### 3. 编译与安装

使用 `make` 进行编译，并安装到指定目录：

```bash
make -j$(nproc)
make PREFIX=/usr/local/software/redis-7.4.1 install
ln -s /usr/local/software/redis-7.4.1 /usr/local/software/redis
```

### 4. 配置环境变量

编辑环境变量，使得 Redis 命令全局可用：

```bash
cat >> ~/.bash_profile <<"EOF"
## REDIS_HOME
export REDIS_HOME=/usr/local/software/redis-7.4.1
export PATH=$PATH:$REDIS_HOME/bin
EOF
source ~/.bash_profile
```

### 5. 查看 Redis 版本

```bash
redis-server --version
```

---

## 配置 Redis

### 1. 编辑 Redis 配置文件

创建配置文件目录并编写 `redis.conf`：

```bash
mkdir -p $REDIS_HOME/conf/ /data/service/redis/
cat > $REDIS_HOME/conf/redis.conf <<EOF
bind 0.0.0.0
port 6379
databases 20
dir /data/service/redis
logfile /data/service/redis/redis-server.log
requirepass Admin@123
protected-mode no
daemonize no
save ""
appendonly yes
maxclients 1024
maxmemory 8GB
maxmemory-policy volatile-lru
io-threads 10
io-threads-do-reads yes
EOF
```

配置文件字段说明

- **bind**：设置 Redis 监听的 IP 地址。`0.0.0.0` 表示接受来自任何 IP 的连接，适用于开发环境。生产环境中建议设置为特定的 IP 地址以增强安全性。
- **port**：Redis 服务监听的端口，默认是 `6379`，可以根据需要修改。
- **databases**：指定 Redis 支持的数据库数量，类似于 MySQL 中的不同数据库。每个数据库都有自己的数据空间。
- **dir**：指定数据文件的存储目录。`appendonly.aof` 或 `dump.rdb` 文件会存储在这里。
- **logfile**：指定日志文件的存储路径，用于记录 Redis 的运行日志和错误信息。
- **requirepass**：设置访问 Redis 的密码，增强安全性，防止未经授权的访问。
- **protected-mode**：保护模式开启时，Redis 仅允许来自 `localhost` 的连接。关闭保护模式后，可以从任意地址访问 Redis。
- **daemonize**：设置为 `yes` 后，Redis 会在后台以守护进程的方式运行。若使用 systemd 管理服务，建议设置为 `no`。
- **save**：指定自动保存的条件，`""` 表示禁用快照保存方式。推荐使用 AOF 持久化时禁用此功能。
- **appendonly**：开启 AOF 持久化，Redis 会在每次修改数据后将操作记录到 `appendonly.aof` 文件中。
- **maxclients**：设置 Redis 可以同时连接的客户端最大数量，适用于高并发的场景。
- **maxmemory**：指定 Redis 允许使用的最大内存大小。超过此限制时，Redis 将根据 `maxmemory-policy` 执行数据淘汰策略。
- **maxmemory-policy**：定义当内存超限时的淘汰策略。`volatile-lru` 表示优先移除即将过期的数据。
- **io-threads**：指定 Redis 使用的 IO 线程数量。增加线程数可以提高处理大量连接的能力。
- **io-threads-do-reads**：开启后，Redis 的 IO 线程也会处理读取操作，适用于需要高读取性能的场景。

### 2. 调整系统内核参数

优化 Redis 所需的系统参数：

```bash
sudo tee /etc/sysctl.d/99-redis.conf <<EOF
net.core.somaxconn=511
vm.overcommit_memory=1
EOF
sudo sysctl -f /etc/sysctl.d/99-redis.conf
```

内核参数字段说明

- **net.core.somaxconn**：用于设置等待连接队列的最大长度。默认值为 `128`，将其增加到 `511` 能更好地支持高并发连接。适用于 Redis 这样的网络应用程序，因为它在高负载时可能需要处理大量的连接。

- **vm.overcommit_memory**：控制内存分配策略。`0` 表示内核会根据计算机的可用内存情况决定是否允许分配内存，`1` 表示允许内核超量分配内存。这对 Redis 很重要，因为 Redis 需要能够在启动时申请大块内存来缓存数据。设置为 `1` 可以避免内存不足导致的 Redis 启动失败或崩溃。

## 启动 Redis 服务

### 1. 配置 systemd 管理服务

创建 `redis.service` 文件以便使用 `systemd` 管理 Redis：

```bash
sudo tee /etc/systemd/system/redis.service <<EOF
[Unit]
Description=Redis data structure server
Documentation=https://redis.io/documentation
After=network-online.target

[Service]
ExecStart=/usr/local/software/redis/bin/redis-server /usr/local/software/redis/conf/redis.conf --supervised systemd
Type=simple
Restart=on-failure
RestartSec=10
TimeoutStartSec=90
TimeoutStopSec=120
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng

[Install]
WantedBy=multi-user.target
EOF
```

### 2. 启动 Redis 服务

```bash
sudo systemctl daemon-reload
sudo systemctl start redis
sudo systemctl enable redis
```

### 3. 查看 Redis 服务状态

验证 Redis 是否正常运行：

```bash
export REDISCLI_AUTH=Admin@123
redis-cli info server
```

---

## 配置 Redis 主从复制

服务器信息

| IP            | 主机名    | 描述   |
| ------------- | --------- | ------ |
| 192.168.1.112 | service01 | 主节点 |
| 192.168.1.113 | service02 | 从节点 |

确保你有两台服务器或虚拟机，一台作为主服务器（Master），一台作为从服务器（Slave），并且两台机器均已安装并配置好 Redis。

### 1. 在从节点配置主从关系

编辑从节点的 `redis.conf` 文件，添加主节点地址和密码验证：

```bash
vi $REDIS_HOME/conf/redis.conf
# 添加以下内容：
slaveof service01 6379
masterauth Admin@123
```

### 2. 重启从节点服务

```bash
sudo systemctl restart redis
```

### 3. 验证主从复制状态

```bash
export REDISCLI_AUTH=Admin@123 
redis-cli info replication
```



## 配置 Redis 集群模式

服务器信息

| IP            | 主机名    | 描述                   |
| ------------- | --------- | ---------------------- |
| 192.168.1.112 | service01 | 6001、6002两个服务节点 |
| 192.168.1.113 | service02 | 6001、6002两个服务节点 |
| 192.168.1.114 | service03 | 6001、6002两个服务节点 |

Redis 集群模式用于在多台服务器上部署 Redis 实例，以实现数据分布和高可用性。以下是配置 Redis 集群模式的步骤和说明。

### 1. 准备工作

要创建 Redis 集群，需要至少 6 个 Redis 节点（3 个主节点和 3 个从节点），可以在不同的服务器上，也可以在同一台服务器上用不同端口运行多个 Redis 实例。

### 2. 编辑 Redis 配置文件

为每个 Redis 实例创建单独的配置文件，并修改以下参数：

服务6001

```bash
export redisPort=6001
mkdir -p /data/service/redis/${redisPort}
cat > $REDIS_HOME/conf/redis-${redisPort}.conf <<EOF
bind 0.0.0.0
port ${redisPort}
databases 20
dir /data/service/redis/${redisPort}
logfile /data/service/redis/${redisPort}/redis-server.log
requirepass Admin@123
masterauth Admin@123
protected-mode no
daemonize no
save ""
appendonly yes
maxclients 1024
maxmemory 8GB
maxmemory-policy volatile-lru
io-threads 10
io-threads-do-reads yes
## 集群配置
cluster-enabled yes
cluster-config-file nodes-${redisPort}.conf
cluster-node-timeout 15000
EOF
```

服务6002

```bash
export redisPort=6002
mkdir -p /data/service/redis/${redisPort}
cat > $REDIS_HOME/conf/redis-${redisPort}.conf <<EOF
bind 0.0.0.0
port ${redisPort}
dir /data/service/redis/${redisPort}
logfile /data/service/redis/${redisPort}/redis-server.log
requirepass Admin@123
masterauth Admin@123
protected-mode no
daemonize no
save ""
appendonly yes
maxclients 1024
maxmemory 8GB
maxmemory-policy volatile-lru
io-threads 10
io-threads-do-reads yes
## 集群配置
cluster-enabled yes
cluster-config-file nodes-${redisPort}.conf
cluster-node-timeout 15000
EOF
```

配置文件字段说明

- **cluster-enabled**：设置为 `yes` 以启用 Redis 集群模式，使该实例能够作为集群中的一个节点运行。
- **cluster-config-file**：指定集群配置文件路径，用于存储 Redis 集群的节点信息。Redis 启动时会自动生成这个文件。
- **cluster-node-timeout**：配置集群节点之间的通信超时时间，超时后会认为节点失联。单位为毫秒。

### 3. 启动 Redis 实例

使用 `systemd` 管理 Redis：

服务6001

```bash
export redisPort=6001
sudo tee /etc/systemd/system/redis-${redisPort}.service <<EOF
[Unit]
Description=Redis data structure server
Documentation=https://redis.io/documentation
After=network-online.target

[Service]
ExecStart=/usr/local/software/redis/bin/redis-server /usr/local/software/redis/conf/redis-${redisPort}.conf --supervised systemd
Type=simple
Restart=always
RestartSec=10
User=admin
Group=ateng

[Install]
WantedBy=multi-user.target
EOF
```

服务6002

```bash
export redisPort=6002
sudo tee /etc/systemd/system/redis-${redisPort}.service <<EOF
[Unit]
Description=Redis data structure server
Documentation=https://redis.io/documentation
After=network-online.target

[Service]
ExecStart=/usr/local/software/redis/bin/redis-server /usr/local/software/redis/conf/redis-${redisPort}.conf --supervised systemd
Type=simple
Restart=always
RestartSec=10
User=admin
Group=ateng

[Install]
WantedBy=multi-user.target
EOF
```

使用以下命令启动每个 Redis 实例：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now redis-6001
sudo systemctl enable --now redis-6002
```

### 4. 创建 Redis 集群

启动所有实例后，使用 `redis-cli` 命令创建集群：

```bash
export REDISCLI_AUTH=Admin@123
redis-cli --cluster create \
    service01:6001 service01:6002 \
    service02:6001 service02:6002 \
    service03:6001 service03:6002 \
    --cluster-replicas 1
```

- **--cluster-replicas 1**：指定每个主节点有一个从节点。

此命令会提示你确认创建集群，输入 `yes` 即可。

### 5. 验证集群状态

使用以下命令查看 Redis 集群的状态：

```bash
redis-cli -c -h 192.168.1.112 -p 6001 cluster info
```

还可以使用以下命令查看集群的节点信息：

```bash
redis-cli -c -h 192.168.1.112 -p 6001 cluster nodes
```

### 集群配置注意事项

- **节点数量**：至少需要 6 个节点（3 主 3 从），以确保在主节点故障时能自动进行故障转移。
- **端口映射**：在集群模式下，除了 Redis 数据端口（如 6379）外，每个实例还会使用 `+10000` 的端口用于集群通信（如 16379）。确保防火墙配置允许这些端口的通信。
- **分片数据**：Redis 集群会自动将数据分片到不同的主节点中，每个节点负责不同的键空间。客户端需要使用集群模式连接（如 `redis-cli -c`）。



## 安装模块

我使用的操作系统是 `OpenEuler 24.03`，可以直接下载官网提供的Redis Stack包中的lib，详情可以参考下载地址：https://redis.io/downloads/ 的 **Redis Stack downloads** 部分。本来想用编译安装这些模块的，但是涉及的依赖太多，研究起来有点浪费时间就直接用官网的算了。

**下载Redis Stack**

```
wget https://packages.redis.io/redis-stack/redis-stack-server-7.4.0-v1.rhel9.x86_64.tar.gz
```

**解压软件包**

```
tar -zxvf redis-stack-server-7.4.0-v1.rhel9.x86_64.tar.gz
```

**拷贝模块包**

```
cp -r ./redis-stack-server-7.4.0-v1/lib /usr/local/software/redis/
```

**编辑配置文件**

将需要的模块添加到 `/usr/local/software/redis/conf/redis.conf` 文件中

```
loadmodule /usr/local/software/redis/lib/rejson.so
loadmodule /usr/local/software/redis/lib/redisearch.so
```

**重启服务**

```
sudo systemctl restart redis
```

