# 编译安装Redis

## 安装服务

安装编译软件

```
sudo yum -y install gcc make
```

解压软件包

```
tar -zxvf redis-6.2.14.tar.gz
cd redis-6.2.14
```

编译和安装

```
make -j$(nproc)
make PREFIX=/usr/local/software/redis-6.2.14 install
ln -s /usr/local/software/redis-6.2.14 /usr/local/software/redis
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## REDIS_HOME
export REDIS_HOME=/usr/local/software/redis-6.2.14
export PATH=$PATH:$REDIS_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
redis-server --version
```

## 编辑配置

编辑配置文件

```
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
maxclients 10000
maxmemory 50GB
maxmemory-policy volatile-lru
io-threads 10
io-threads-do-reads yes
EOF
```

编辑内核配置

```
sudo tee /etc/sysctl.d/99-redis.conf <<EOF
net.core.somaxconn=511
vm.overcommit_memory=1
EOF
sudo sysctl -f /etc/sysctl.d/99-redis.conf
```

## 启动服务

systemd管理服务

```
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

启动服务

```
sudo systemctl daemon-reload
sudo systemctl start redis
sudo systemctl enable redis
```

查看服务

```
REDISCLI_AUTH=Admin@123 redis-cli info server
```



# 配置主从

> 确保你有两台服务器或两台虚拟机，一台作为主服务器（Master），一台作为从服务器（Slave）。安装好Redis并进行基本的配置。

在从节点配置主节点的地址和密码验证

```
$ vi +$ $REDIS_HOME/conf/redis.conf
...
slaveof service01 6379
masterauth Admin@123
```

重启从节点服务

```
sudo systemctl restart redis
```

验证配置

```
REDISCLI_AUTH=Admin@123 redis-cli info replication
```

