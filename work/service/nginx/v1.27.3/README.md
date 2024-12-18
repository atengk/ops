# Nginx

Nginx 是一个高性能的开源 Web 服务器、反向代理服务器和负载均衡器。它以其轻量级、异步事件驱动架构而闻名，能够高效处理大量并发连接。Nginx 常用于静态文件服务、负载均衡、SSL 终端处理和反向代理等任务，广泛应用于高流量网站。由于其高性能、灵活配置和低资源消耗，Nginx 在现代 Web 基础设施中得到了广泛使用。

- [官网链接](https://nginx.org/)

## 前置条件

- 参考：[基础配置](/work/service/00-basic/)

## 下载软件包

**下载 Nginx 源代码**

首先，使用 `wget` 从官方 Nginx 网站下载最新版本的 Nginx 源代码包：

```bash
wget https://nginx.org/download/nginx-1.27.3.tar.gz
```

**解压缩源代码包**

下载完成后，使用 `tar` 解压缩 Nginx 源代码：

```bash
tar -zxvf nginx-1.27.3.tar.gz
```

**进入源代码目录**

解压后进入 Nginx 源代码的目录：

```bash
cd nginx-1.27.3
```



## 编译和安装

**安装依赖包**

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

**配置 Nginx 编译选项**

配置 Nginx 并启用一些额外的模块

```bash
./configure \
    --prefix=/usr/local/software/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-stream \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_realip_module
```

- `--prefix=/usr/local/software/nginx`: 指定 Nginx 的安装目录。
- `--conf-path`: 配置文件路径。
- `--with-http_ssl_module`: 启用 SSL 模块，用于支持 HTTPS。
- `--with-http_v2_module`: 启用 HTTP/2 模块，提高网站性能。
- `--with-stream`: 启用 TCP 和 UDP 流量的代理与负载均衡
- `--with-http_gzip_static_module`: 支持 gzip 静态文件压缩，减少传输数据量。
- `--with-http_stub_status_module`: 启用状态监控模块，查看 Nginx 运行状态。
- `--with-http_realip_module`: 获取客户端的真实 IP 地址，适用于反向代理场景。

**编译与安装 Nginx**

使用 `make` 命令编译 Nginx，并使用系统的所有 CPU 核心来加速编译：

```bash
make -j$(nproc)
```

接着，执行安装：

```bash
sudo make install
```

**配置环境变量**

```
sudo ln -s /usr/local/software/nginx/sbin/nginx /usr/bin/nginx
```

**查看版本**

```
nginx -V
```



## 配置服务

**创建配置目录和设置权限**

```
sudo mkdir -p /etc/nginx/conf.d/ /etc/nginx/stream.conf.d
sudo chown -R admin:ateng /etc/nginx
```

**创建并编辑 Nginx 主配置文件**

以下配置文件为 `/etc/nginx/nginx.conf`，它包含基本的日志、事件、HTTP 设置等：

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
stream {
    proxy_timeout 10s;
    proxy_connect_timeout 5s;
    include /etc/nginx/stream.conf.d/*.conf;
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

配置文件解释：

全局设置

- **`user admin ateng;`**: 指定 Nginx 进程使用 `admin` 用户和 `ateng` 用户组运行，提升安全性和权限控制。
- **`worker_processes auto;`**: 根据 CPU 核心数自动设置工作进程数，优化多核性能。
- **`error_log /usr/local/software/nginx/logs/error.log warn;`**: 错误日志路径及级别，`warn` 记录警告及更严重的问题。
- **`pid /usr/local/software/nginx/logs/nginx.pid;`**: 指定存储进程 ID 的文件路径，便于管理 Nginx 进程。

`events` 块

- **`worker_connections 1024;`**: 单个工作进程允许的最大并发连接数。
- **`use epoll;`**: 指定 `epoll` 事件驱动模型，提升并发处理能力（适用于 Linux 系统）。

`stream` 块

- **`proxy_timeout 10s;`**: 后端代理超时时间为 10 秒。
- **`proxy_connect_timeout 5s;`**: 后端连接超时时间为 5 秒。
- **`include /etc/nginx/stream.conf.d/\*.conf;`**: 引入 `stream` 相关配置文件，方便管理 TCP/UDP 流量代理配置。

`http` 块

- **`include mime.types;`**: 加载文件类型映射表，确保 Nginx 能正确处理各种文件类型。
- **`default_type application/octet-stream;`**: 未识别的文件默认作为二进制流处理。
- **`log_format main ...;`**: 定义访问日志格式，记录详细的请求信息，包括客户端 IP、请求方法、状态码等。
- **`access_log /usr/local/software/nginx/logs/access.log main;`**: 使用 `main` 格式记录访问日志。
- **`sendfile on;`**: 启用高效文件传输，减少数据拷贝。
- **`tcp_nopush on;`**: 优化数据包传输，提升网络效率。
- **`tcp_nodelay on;`**: 禁用 Nagle 算法，降低延迟。
- **`keepalive_timeout 65;`**: 长连接保持时间为 65 秒。
- **`types_hash_max_size 2048;`**: 设置 MIME 类型哈希表的最大尺寸，提升查找效率。
- **`include /etc/nginx/conf.d/\*.conf;`**: 加载额外的 HTTP 配置文件，便于管理虚拟主机等功能。



## 启动服务

**配置 Systemd 服务**

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

**启动并启用 Nginx 服务**

重新加载 Systemd 配置并启动 Nginx 服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nginx
```

查看服务状态

```bash
sudo systemctl status nginx
```

查看日志

```
tail -f /usr/local/software/nginx/logs/*.log
```

