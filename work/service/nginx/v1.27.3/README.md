# Nginx

Nginx 是一个高性能的开源 Web 服务器、反向代理服务器和负载均衡器。它以其轻量级、异步事件驱动架构而闻名，能够高效处理大量并发连接。Nginx 常用于静态文件服务、负载均衡、SSL 终端处理和反向代理等任务，广泛应用于高流量网站。由于其高性能、灵活配置和低资源消耗，Nginx 在现代 Web 基础设施中得到了广泛使用。

- [官网链接](https://nginx.org/)

## 安装Nginx

### 1. 下载 Nginx 源代码

首先，使用 `wget` 从官方 Nginx 网站下载最新版本的 Nginx 源代码包：

```bash
wget https://nginx.org/download/nginx-1.27.3.tar.gz
```

### 2. 解压缩源代码包

下载完成后，使用 `tar` 解压缩 Nginx 源代码：

```bash
tar -zxvf nginx-1.27.3.tar.gz
```

### 3. 进入源代码目录

解压后进入 Nginx 源代码的目录：

```bash
cd nginx-1.27.3
```

### 4. 安装依赖包

在编译 Nginx 之前，需要安装以下依赖包：

```bash
sudo yum install -y gcc pcre-devel zlib-devel openssl-devel make
```

这些依赖包包括：  
- `gcc`: C 编译器  
- `pcre-devel`: Perl Compatible Regular Expressions (用于解析正则表达式)  
- `zlib-devel`: zlib 压缩库  
- `openssl-devel`: SSL 库  
- `make`: 编译工具

### 5. 配置 Nginx 编译选项

配置 Nginx 并启用一些额外的模块。以下命令会将 Nginx 安装到 `/usr/local/software/nginx` 目录，并启用 SSL、HTTP/2、gzip 静态文件压缩、状态监控以及 Real IP 模块：

```bash
./configure \
    --prefix=/usr/local/software/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_realip_module
```

- `--prefix=/usr/local/software/nginx`: 指定 Nginx 的安装目录。
- `--conf-path`: 配置文件路径。
- `--with-http_ssl_module`: 启用 SSL 模块，用于支持 HTTPS。
- `--with-http_v2_module`: 启用 HTTP/2 模块，提高网站性能。
- `--with-http_gzip_static_module`: 支持 gzip 静态文件压缩，减少传输数据量。
- `--with-http_stub_status_module`: 启用状态监控模块，查看 Nginx 运行状态。
- `--with-http_realip_module`: 获取客户端的真实 IP 地址，适用于反向代理场景。

### 6. 编译与安装 Nginx

使用 `make` 命令编译 Nginx，并使用系统的所有 CPU 核心来加速编译：

```bash
make -j$(nproc)
```

接着，执行安装：

```bash
make install
```

配置环境变量

```
sudo ln -s /usr/local/software/nginx/sbin/nginx /usr/bin/nginx
```

查看版本

```
nginx -V
```

### 7. 配置 Nginx

创建配置目录和设置权限

```
sudo mkdir -p /etc/nginx/conf.d/
sudo chown -R admin:ateng /etc/nginx
```

创建并编辑 Nginx 主配置文件。以下配置文件为 `/etc/nginx/nginx.conf`，它包含基本的日志、事件、HTTP 设置等：

```bash
tee /etc/nginx/nginx.conf <<"EOF"
user admin ateng;
worker_processes auto;
error_log /usr/local/software/nginx/logs/error.log warn;
pid /usr/local/software/nginx/logs/nginx.pid;
events {
    worker_connections 1024;
    use epoll;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /usr/local/software/nginx/logs/access.log  main;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    include /etc/nginx/conf.d/*.conf;
}
EOF
```

配置文件解释

- `user`: worker processes使用admin用户运行。

- `worker_processes auto;`: 根据 CPU 核心数自动设置 Nginx 的工作进程数，优化资源利用率。
- `error_log /usr/local/software/nginx/logs/error.log warn;`: 设置错误日志的路径和日志级别为 `warn`，记录警告和更严重的错误。
- `pid /usr/local/software/nginx/logs/nginx.pid;`: 指定 Nginx 进程 ID 文件的路径，便于进程管理。
- `worker_connections 1024;`: 每个工作进程最大允许的并发连接数，设置为 1024。
- `use epoll;`: 使用 `epoll` 事件模型，提高 Nginx 在 Linux 系统上的并发处理能力。
- `include mime.types;`: 引入文件类型与扩展名的映射表，以确保 Nginx 正确处理不同类型的文件。
- `default_type application/octet-stream;`: 设置默认文件类型为 `octet-stream`，适用于未识别的文件类型。
- `log_format main ...;`: 定义访问日志的格式，记录客户端 IP 地址、请求时间、状态码、用户代理等详细信息。
- `access_log /usr/local/software/nginx/logs/access.log main;`: 指定访问日志的存储位置和使用的日志格式。
- `sendfile on;`: 开启高效文件传输功能，减少数据拷贝，提升传输效率。
- `tcp_nopush on;`: 减少传输过程中的网络包数量，优化数据传输。
- `tcp_nodelay on;`: 禁用 `Nagle` 算法，减少网络延迟，适用于延迟敏感的应用。
- `keepalive_timeout 65;`: 设置客户端连接的保持时间为 65 秒，允许长时间的连接保持。
- `types_hash_max_size 2048;`: 增大文件类型映射表的哈希大小，提升文件类型查找效率。
- `include /etc/nginx/conf.d/*.conf;`: 包含额外的 Nginx 配置文件，便于扩展和管理多个虚拟主机或独立配置。

### 8. 配置 Systemd 服务

为了方便管理 Nginx 服务，您可以创建一个 Systemd 服务文件 `/etc/systemd/system/nginx.service`。该文件将控制 Nginx 的启动、停止和重载操作：

```bash
sudo tee /etc/systemd/system/nginx.service <<"EOF"
[Unit]
Description=Nginx HTTP Server
After=network.target

[Service]
User=root
Group=root
Type=forking
Restart=on-failure
RestartSec=5
ExecStartPre=/usr/local/software/nginx/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/local/software/nginx/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/usr/local/software/nginx/sbin/nginx -s reload
ExecStop=/usr/local/software/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target
EOF
```

注意：
- master process使用root用户运行

### 9. 启动并启用 Nginx 服务

重新加载 Systemd 配置并启动 Nginx 服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start nginx
```

设置 Nginx 开机自启动：

```bash
sudo systemctl enable nginx
```

