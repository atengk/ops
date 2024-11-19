# JuiceFS

**JuiceFS** 是一款面向云原生设计的高性能分布式文件系统，在 Apache 2.0 开源协议下发布。提供完备的 [POSIX](https://en.wikipedia.org/wiki/POSIX) 兼容性，可将几乎所有对象存储接入本地作为海量本地磁盘使用，亦可同时在跨平台、跨地区的不同主机上挂载读写。

参考链接：

- [官网](https://juicefs.com/docs/zh/community/introduction/)



## 安装

**下载软件包**

```
wget https://github.com/juicedata/juicefs/releases/download/v1.2.1/juicefs-1.2.1-linux-amd64.tar.gz
```

**安装**

```
mkdir -p juicefs
tar -zxvf juicefs-1.2.1-linux-amd64.tar.gz -C juicefs
sudo cp juicefs/juicefs /usr/bin/
```

**查看版本**

```
$ juicefs version
juicefs version 1.2.1+2024-08-30.cd871d1
```



## 创建文件系统

参考链接：

- [分布式模式](https://juicefs.com/docs/zh/community/getting-started/for_distributed)

- [对象存储MinIO](https://kongyu666.github.io/work/#/work/service/minio/v20241013/)

参考格式

```
redis[s]://[<username>:<password>@]<host>[:<port>]/<db>
```

### 元数据Redis

#### Redis单机模式

[参考链接](https://juicefs.com/docs/zh/community/databases_for_metadata#redis)

配置环境变量

```shell
export META_PASSWORD=Admin@123
export META_URL=redis://192.168.1.10:42784/2
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```

#### Redis哨兵模式

[参考链接](https://juicefs.com/docs/zh/community/redis_best_practices/#sentinel-mode)

配置环境变量

```shell
export META_PASSWORD=Admin@123
export META_URL=redis://:password@masterName,1.2.3.4,1.2.5.6:26379/2
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```

#### Redis集群模式

[参考链接](https://juicefs.com/docs/zh/community/redis_best_practices/#cluster-mode)

配置环境变量

```shell
export META_PASSWORD=Admin@123
export META_URL=redis://127.0.0.1:7000,127.0.0.1:7001,127.0.0.1:7002/1
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```

### 元数据PostgreSQL

[参考链接](https://juicefs.com/docs/zh/community/databases_for_metadata#postgresql)

参考格式

```
postgres://[username][:<password>]@<host>[:5432]/<database-name>[?parameters]
```

配置环境变量

```shell
export META_PASSWORD=Lingo@local_postgresql_5432
export META_URL=postgres://postgres@192.168.1.10:32297/juicefs
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```

### 元数据MySQL

[参考链接](https://juicefs.com/docs/zh/community/databases_for_metadata#mysql)

参考格式

```
mysql://<username>[:<password>]@(<host>:3306)/<database-name>
```

配置环境变量

```shell
export META_PASSWORD=Admin@123
export META_URL=mysql://root@(192.168.1.10:35725)/juicefs
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```

### 元数据ETCD

[参考链接](https://juicefs.com/docs/zh/community/databases_for_metadata#etcd)

参考格式

```
etcd://[user:password@]<addr>[,<addr>...]/<prefix>
```

#### HTTP+认证模式

配置环境变量

```shell
export META_PASSWORD=Admin@123
export META_URL=etcd://root@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```

#### HTTPS模式

配置环境变量

> server-name: 需要是证书支持的域名

```shell
export META_URL="etcd://192.168.1.112:2379/jfs?cert=/etc/ssl/etcd/ssl/admin-k8s-master01.pem&cacert=/etc/ssl/etcd/ssl/ca.pem&key=/etc/ssl/etcd/ssl/admin-k8s-master01-key.pem&server-name=k8s-master01"
```

创建文件系统

```shell
juicefs format \
    --storage minio \
    --bucket http://dev.minio.lingo.local/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    $META_URL \
    juicefs
```



## 使用文件系统

**挂载文件系统**

```shell
sudo mkdir -p /juicefs
sudo -E juicefs mount \
    --background \
    --cache-dir /var/jfsCache \
    --cache-size 100G \
    -o allow_other,writeback_cache \
    $META_URL \
    /juicefs
```

**查看挂载**

```
$ df -hT /juicefs
文件系统                    类型          大小  已用  可用 已用% 挂载点
JuiceFS:juicefs-minio-redis fuse.juicefs  1.0P  1.1G  1.0P    1% /juicefs
```

**验证文件系统**

```
juicefs bench /juicefs
```

**卸载文件系统**

卸载

```
sudo juicefs umount /juicefs
```

强制卸载

> 以下内容包含的命令可能会导致文件损坏、丢失，请务必谨慎操作！

```
sudo juicefs umount --force /juicefs
```

**销毁文件系统**

查看文件系统的UUID

```
juicefs status $META_URL
```

销毁文件系统

```
juicefs destroy $META_URL db851171-8e7c-4196-893e-3b44d6ff471c
```



## 开机自动挂载

[参考链接](https://juicefs.com/docs/zh/community/mount_juicefs_at_boot_time#%E4%BD%BF%E7%94%A8-systemdmount-%E5%AE%9E%E7%8E%B0%E8%87%AA%E5%8A%A8%E6%8C%82%E8%BD%BD)

**设置环境变量**

```shell
export META_PASSWORD=Admin@123
export META_URL=redis://192.168.1.10:42784/2
```

**配置systemd.mount**

> 注意：`systemd.mount` 文件的文件名和挂载点路径需要保持一致。

```shell
sudo tee /etc/systemd/system/juicefs.mount <<EOF
[Unit]
Description=Mount JuiceFS
After=network.target

[Mount]
Environment="META_PASSWORD=$META_PASSWORD"
What=$META_URL
Where=/juicefs
Type=juicefs
Options=cache-dir=/var/jfsCache,cache-size=100G,_netdev,allow_other,writeback_cache

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
EOF
```

**启动 JuiceFS 挂载**

```
sudo ln -s /usr/bin/juicefs /sbin/mount.juicefs
sudo systemctl daemon-reload
sudo systemctl enable --now juicefs.mount
```

**查看挂载**

```
$ df -hT /juicefs
文件系统                    类型          大小  已用  可用 已用% 挂载点
JuiceFS:juicefs-minio-redis fuse.juicefs  1.0P  1.1G  1.0P    1% /juicefs
```

