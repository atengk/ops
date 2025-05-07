# MinIO

MinIO 是一个高性能的对象存储系统，兼容 Amazon S3 API，专为存储海量非结构化数据而设计。它使用 Golang 编写，支持本地部署和云环境，适用于私有云、混合云和边缘计算等场景。MinIO 提供数据冗余、加密和高可用性，是构建数据湖、备份与恢复等解决方案的理想选择。

- [官网地址](https://min.io/)

## 前置条件

- 参考：[基础配置](/work/service/00-basic/)

## 单机模式

### 1. 下载 MinIO 服务器和客户端

首先，通过以下命令下载 MinIO 服务器和客户端二进制文件：

```bash
wget https://dl.min.io/server/minio/release/linux-arm64/archive/minio.RELEASE.2024-11-07T00-52-20Z
wget https://dl.min.io/client/mc/release/linux-arm64/archive/mc.RELEASE.2024-11-17T19-35-25Z
```

### 2. 安装 MinIO

将下载的二进制文件复制到系统的可执行文件目录并赋予执行权限：

```bash
sudo cp minio.RELEASE.2024-11-07T00-52-20Z /usr/bin/minio
sudo cp mc.RELEASE.2024-11-17T19-35-25Z /usr/bin/mcli
sudo chmod +x /usr/bin/{minio,mcli}
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
EnvironmentFile=-/etc/default/minio
ExecStart=/usr/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF
```

**说明**:

- `User` 和 `Group` 根据实际的系统用户配置。
- `ExecStart` 使用配置文件中的变量启动 MinIO。

加载并启动 MinIO 服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start minio
sudo systemctl enable minio
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



## 集群模式

### 1. 下载 MinIO 服务器和客户端

首先，通过以下命令下载 MinIO 服务器和客户端二进制文件：

```bash
wget https://dl.min.io/server/minio/release/linux-arm64/archive/minio.RELEASE.2024-11-07T00-52-20Z
wget https://dl.min.io/client/mc/release/linux-arm64/archive/mc.RELEASE.2024-11-17T19-35-25Z
```

确保下载了与操作系统匹配的最新稳定版本。可以访问 [MinIO Releases](https://dl.min.io) 查看最新发布版本。

### 2. 安装 MinIO

将下载的二进制文件复制到系统的可执行文件目录并赋予执行权限：

```bash
sudo cp minio.RELEASE.2024-11-07T00-52-20Z /usr/bin/minio
sudo cp mc.RELEASE.2024-11-17T19-35-25Z /usr/bin/mcli
sudo chmod +x /usr/bin/{minio,mcli}
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
- 集群模式的存储目录不能和根目录在同一个分区上，需要挂载单独的分区，如果系统中只有根分区，可以使用`fallocate -l 10G /mnt/minio.img`的方式创建一个文件，然后格式化后挂载到相应的目录。

### 4. 创建 MinIO 配置文件

接下来，创建并配置 MinIO 环境变量文件 `/etc/default/minio`：

```bash
sudo tee /etc/default/minio <<EOF
MINIO_VOLUMES="http://192.168.1.101:9000/data/service/minio/data{01...02} http://192.168.1.102:9000/data/service/minio/data{01...02} http://192.168.1.103:9000/data/service/minio/data{01...02}"
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
EnvironmentFile=-/etc/default/minio
ExecStart=/usr/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF
```

**说明**:
- `User` 和 `Group` 字段应根据系统实际用户和组进行调整。
- `ExecStart` 将根据之前配置的环境变量启动 MinIO 服务。

加载并启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start minio
sudo systemctl enable minio
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



## 配置负载均衡

### Nginx

**编辑配置文件**

编辑`/etc/nginx/conf.d/minio.conf`添加以下内容：

```
upstream minio_api_servers {
    least_conn;
    server 192.168.1.101:9000 max_fails=3 fail_timeout=30s;
    server 192.168.1.102:9000 max_fails=3 fail_timeout=30s;
    server 192.168.1.103:9000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 19000;
    server_name _;

    location / {
        proxy_pass http://minio_api_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

参数含义说明

- `least_conn`: 使用最少连接的负载均衡策略，将请求转发到当前连接数最少的服务器上。
- `server`: 定义后端服务器的 IP 和端口，`max_fails=3` 表示若服务器连续失败 3 次则判定为不可用，`fail_timeout=30s` 表示服务器不可用的超时时间为 30 秒。
- `keepalive`: 定义与后端服务器之间保持的最大长连接数，减少连接开销。
- `listen`: 定义前端监听的端口号，在此配置中为 `19000`。
- `server_name`: 用 `_` 匹配所有请求的域名。
- `proxy_pass`: 转发请求到指定的 `upstream` 组。
- `proxy_set_header`: 设置代理请求头：
    - `Host`: 设置请求头的 `Host` 字段为客户端请求的主机。
    - `X-Real-IP`: 设置请求头的 `X-Real-IP` 字段为客户端真实 IP。
    - `X-Forwarded-For`: 保留所有代理 IP，确保多层代理时能追踪到客户端真实 IP。
    - `X-Forwarded-Proto`: 设置协议头，保留客户端请求的协议类型。
- `proxy_connect_timeout`: 定义代理服务器与后端服务器连接的超时时间。
- `proxy_send_timeout`: 定义发送数据到后端服务器的超时时间。
- `proxy_read_timeout`: 定义从后端服务器读取响应的超时时间。

**重新读取配置**

```
sudo systemctl reload nginx
```

**添加负载均衡后的服务**

```
mcli config host add minio-lb http://192.168.1.101:19000 admin Admin@123 --api s3v4
```

**查看状态**

```
mcli admin info minio-lb
```

### HaProxy

**编辑配置文件**

编辑`/etc/haproxy/haproxy.cfg`添加以下内容：

```
frontend minio_api
    bind *:19000
    default_backend minio_api_servers

backend minio_api_servers
    balance leastconn
    option tcp-check
    server minio01 192.168.1.101:9000 check inter 3s fall 3 rise 2
    server minio02 192.168.1.102:9000 check inter 3s fall 3 rise 2
    server minio03 192.168.1.103:9000 check inter 3s fall 3 rise 2
```

参数含义说明

- `balance leastconn`: 使用最少连接的负载均衡策略，将请求转发到当前连接数最少的服务器上，适用于长连接的负载均衡需求。
- `option httpchk GET /`: 开启 HTTP 健康检查，通过发送 GET 请求检查服务器是否存活。
- `server`: 定义后端服务器的 IP 和端口，并添加健康检查设置：
    - `check`: 开启对服务器的健康检查。
    - `inter 3s`: 设置健康检查的间隔时间为 3 秒。
    - `fall 3`: 如果连续 3 次健康检查失败，判定服务器不可用。
    - `rise 2`: 如果连续 2 次健康检查成功，判定服务器恢复可用。

**重新读取配置**

```
sudo systemctl restart haproxy
```

**添加负载均衡后的服务**

```
mcli config host add minio-lb http://192.168.1.101:19000 admin Admin@123 --api s3v4
```

**查看状态**

```
mcli admin info minio-lb
```

### 
