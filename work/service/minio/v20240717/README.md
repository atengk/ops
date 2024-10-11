# MinIO

MinIO 是一个高性能的对象存储系统，专为大规模数据基础设施设计，兼容 Amazon S3 API。它可以用于存储任意类型的非结构化数据，如图片、视频、备份、日志文件等。MinIO 以开源软件的形式提供，支持通过标准的 S3 API 访问，适合在私有云、公有云和混合云环境中部署。

## MinIO 单机安装指南

### 1. 下载 MinIO 服务器和客户端

首先，通过以下命令下载 MinIO 服务器和客户端二进制文件：

```bash
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2024-07-16T23-46-41Z
wget https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2024-07-15T17-46-06Z
```

### 2. 安装 MinIO

将下载的二进制文件复制到系统的可执行文件目录并赋予执行权限：

```bash
cp minio.RELEASE.2024-07-16T23-46-41Z /usr/local/bin/minio
cp mc.RELEASE.2024-07-15T17-46-06Z /usr/local/bin/mcli
chmod +x /usr/local/bin/{minio,mcli}
```

### 3. 创建数据目录

创建一个目录用于存储 MinIO 数据：

```bash
mkdir -p /data/service/minio
```

### 4. 创建 MinIO 配置文件

为 MinIO 创建环境变量文件 `/etc/default/minio`，配置存储路径和服务参数：

```bash
sudo tee /etc/default/minio <<EOF
MINIO_VOLUMES="/data/service/minio"
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=Admin@123
EOF
```

**配置说明**:
- `MINIO_VOLUMES` 定义了 MinIO 存储数据的路径，这里为 `/data/minio`。
- `MINIO_OPTS` 配置了服务监听端口 `9000` 和控制台端口 `9001`。
- 根据安全需求，请务必更改默认的管理员用户名和密码。

### 5. 使用 systemd 管理 MinIO 服务

为了便于管理和设置服务的开机自启动，创建 `systemd` 服务文件：

```bash
sudo tee /etc/systemd/system/minio.service << "EOF"
[Unit]
Description=MinIO Server
Documentation=https://docs.min.io
After=network-online.target

[Service]
User=admin
Group=ateng
Type=simple
Restart=on-failure
RestartSec=5
EnvironmentFile=-/etc/default/minio
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF
```

**说明**:

- `User` 和 `Group` 根据实际的系统用户配置。
- `ExecStart` 使用配置文件中的变量启动 MinIO。

加载并启动 MinIO 服务：

```bash
systemctl daemon-reload
systemctl start minio
systemctl enable minio
```

### 6. 访问 MinIO 控制台

安装完成后，您可以通过以下 URL 访问 MinIO 控制台：

```
URL: http://localhost:9001/
Username: admin
Password: Admin@123
```

**提示**:  
- 请根据网络配置调整访问 URL，如果防火墙限制了访问，请确保开放端口 `9000` 和 `9001`。
- 强烈建议在生产环境中使用强密码并启用 TLS 加密。

### 7. 使用 mcli 添加 MinIO 服务器

使用 MinIO 客户端工具 `mcli` 添加 MinIO 服务器进行管理：

```bash
mcli config host add minio http://localhost:9000 admin Admin@123 --api s3v4
```

### 8. 查看 MinIO 服务器状态

可以通过 `mcli` 查看 MinIO 服务器的状态和信息：

```bash
mcli admin info minio
```



## MinIO 集群安装指南

### 1. 下载 MinIO 服务器和客户端

首先，通过以下命令下载 MinIO 服务器和客户端二进制文件：

```bash
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2024-07-16T23-46-41Z
wget https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2024-07-15T17-46-06Z
```

确保下载了与操作系统匹配的最新稳定版本。可以访问 [MinIO Releases](https://dl.min.io) 查看最新发布版本。

### 2. 安装 MinIO

将下载的二进制文件复制到系统的可执行文件目录并赋予执行权限：

```bash
cp minio.RELEASE.2024-07-16T23-46-41Z /usr/local/bin/minio
cp mc.RELEASE.2024-07-15T17-46-06Z /usr/local/bin/mcli
chmod +x /usr/local/bin/{minio,mcli}
```

**说明**:  
- `minio` 是 MinIO 服务器端，`mcli` 是 MinIO 客户端工具。

### 3. 创建数据目录

为 MinIO 服务器创建存储数据的目录。每个节点需要创建多个数据目录：

```bash
mkdir -p /data/service/minio/data{01..02}
```

**说明**:  
- 目录 `/data/service/minio/data01` 和 `/data/service/minio/data02` 将被用于存储 MinIO 集群数据。  
- 根据需求，可以扩展 `data{01..02}`，例如 `data{01..04}`。
- 集群模式的存储目录不能和根目录在同一个分区上。

### 4. 创建 MinIO 配置文件

接下来，创建并配置 MinIO 环境变量文件 `/etc/default/minio`：

```bash
sudo tee /etc/default/minio <<EOF
MINIO_VOLUMES="http://192.168.1.101:9000/data/service/minio/data{01..02} http://192.168.1.102:9000/data/service/minio/data{01..02} http://192.168.1.103:9000/data/service/minio/data{01..02}"
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=Admin@123
EOF
```

**配置说明**:
- `MINIO_VOLUMES` 定义了集群中的存储卷路径。请确保节点数量不少于2个，并且不同节点的 IP 地址正确。
- **重要**: 存储目录应位于与操作系统不同的硬盘上，以避免性能问题或潜在的磁盘冲突。
- `MINIO_OPTS` 指定了 MinIO 服务的监听端口和控制台端口。默认情况下，MinIO 服务器在 `:9000` 端口上运行，控制台在 `:9001` 端口上。

### 5. 使用 systemd 管理 MinIO 服务

创建 MinIO 的 `systemd` 服务文件，以便将 MinIO 服务设置为开机启动并便于管理：

```bash
sudo tee /etc/systemd/system/minio.service << "EOF"
[Unit]
Description=MinIO Server
Documentation=https://docs.min.io
After=network-online.target

[Service]
User=admin
Group=ateng
Type=simple
Restart=on-failure
RestartSec=5
EnvironmentFile=-/etc/default/minio
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF
```

**说明**:
- `User` 和 `Group` 字段应根据系统实际用户和组进行调整。
- `ExecStart` 将根据之前配置的环境变量启动 MinIO 服务。

加载并启动服务：

```bash
systemctl daemon-reload
systemctl start minio
systemctl enable minio
```

### 6. 访问 MinIO 控制台

您可以通过以下 URL 访问 MinIO 的 Web 控制台进行管理：

```
URL: http://192.168.1.101:9001/
Username: admin
Password: Admin@123
```

**提示**:  
请确保端口 `9001` 已在防火墙中开放，并根据安全需求更改默认的用户名和密码。

### 7. 使用 mcli 添加 MinIO 服务器

通过 MinIO 客户端工具 `mcli` 添加 MinIO 服务器并进行管理：

```bash
mcli config host add minio http://192.168.1.101:9000 admin Admin@123 --api s3v4
```

**说明**:  
- `minio` 为服务器名称，可以自定义命名。  
- `--api s3v4` 指定了 S3 API 版本。

### 8. 查看 MinIO 集群状态

使用 `mcli` 命令可以查看 MinIO 集群的状态和信息：

```bash
mcli admin info minio
```

此命令将返回 MinIO 集群的配置信息、状态和健康检查结果。

