# OpenResty

OpenResty 是基于 Nginx 的高性能 Web 平台，集成了 Lua 脚本语言，适用于构建高并发 Web 应用、API 网关和动态服务。它通过嵌入 Lua 实现轻量级逻辑处理，具备高扩展性，常用于处理请求转发、缓存、限流、鉴权等场景，是开发高性能服务的理想选择。

Nginx 和 OpenResty 的主要区别在于扩展性和灵活性。Nginx 本身是一款高性能的 Web 服务器，主要用于静态资源服务、反向代理和负载均衡，它通过配置文件进行管理和优化。而 OpenResty 基于 Nginx，但集成了 Lua 脚本引擎，允许直接在配置文件中编写 Lua 脚本处理请求，极大增强了扩展性和动态处理能力。总的来说，Nginx 适合传统的静态服务，OpenResty 更适合需要动态内容和业务逻辑处理的场景。

- [官网地址](https://openresty.org/cn/)



## 基础准备

**下载软件包**

```
wget https://openresty.org/download/openresty-1.27.1.2.tar.gz
```

**解压软件包**

```
tar -zxvf openresty-1.27.1.2.tar.gz
cd openresty-1.27.1.2
```

**安装依赖**

Ubuntu/Debian：

```
sudo apt update
sudo apt install -y build-essential zlib1g-dev libpcre3 libpcre3-dev libssl-dev perl make curl
```

CentOS/RHEL：

```
sudo yum install -y gcc make pcre-devel openssl-devel zlib-devel perl curl
```

## 编译安装

**配置编译参数**

```
./configure \
    --prefix=/usr/local/software/openresty \
    --conf-path=/etc/nginx/nginx.conf \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-pcre-jit \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-stream_ssl_module
```

- `--prefix`: 指定 OpenResty 的安装目录为 `/usr/local/software/openresty`
- `--conf-path`: 设置主配置文件路径为 `/etc/nginx/nginx.conf`
- `--with-http_ssl_module`: 启用 HTTPS 支持（基于 OpenSSL）
- `--with-http_v2_module`: 启用 HTTP/2 协议，提高连接复用和传输效率
- `--with-pcre-jit`: 启用 PCRE JIT 加速，提升正则表达式处理性能
- `--with-http_realip_module`: 支持获取客户端真实 IP，适用于反向代理场景
- `--with-http_gzip_static_module`: 启用静态 gzip 支持，可直接发送 `.gz` 文件，节省带宽
- `--with-http_stub_status_module`: 开启 Nginx 状态页模块，用于监控连接和请求情况
- `--with-stream`: 启用 Stream 模块，支持 TCP/UDP 转发
- `--with-stream_ssl_module`: 给 Stream 模块增加 SSL 支持，用于加密的 TCP 代理服务

**编译和安装**

```
make -j$(nproc)
sudo make install
```

**配置软链接**

```
ln -s /usr/local/software/openresty/bin/openresty /usr/bin/openresty
```

**查看版本**

```
openresty -version
```

输出以下内容：

```
nginx version: openresty/1.27.1.2
```

## 配置文件

**创建配置目录**

```
sudo mkdir -p /etc/nginx/conf.d/ /etc/nginx/stream.conf.d /data/service/openresty/logs
sudo chown -R admin:ateng /etc/nginx /data/service/openresty/logs
```

**编辑配置文件**

```
tee /etc/nginx/nginx.conf <<"EOF"
user admin ateng;
worker_processes auto;
error_log /data/service/openresty/logs/error.log warn;
pid /data/service/openresty/logs/nginx.pid;
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
    access_log  /data/service/openresty/logs/access.log  main;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    include /etc/nginx/conf.d/*.conf;
}
EOF
```

## 启动服务

**配置 Systemd 服务**

```bash
sudo tee /etc/systemd/system/openresty.service <<"EOF"
[Unit]
Description=OpenResty Server
After=network.target

[Service]
User=root
Group=root
Type=forking
ExecStartPre=/usr/local/software/openresty/bin/openresty -t -c /etc/nginx/nginx.conf
ExecStart=/usr/local/software/openresty/bin/openresty -c /etc/nginx/nginx.conf
ExecReload=/usr/local/software/openresty/bin/openresty -s reload
ExecStop=/usr/local/software/openresty/bin/openresty -s stop
Restart=on-failure
RestartSec=10
TimeoutStartSec=30
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable --now openresty
```

**查看服务状态**

```
sudo systemctl status openresty
```

**查看日志**

```
tail -f /data/service/openresty/logs/*.log
```



## 访问测试

**创建配置文件**

```
tee /etc/nginx/conf.d/demo.conf <<EOF
server {
  listen 8000;
  server_name _;
  root /data/service/frontend/demo;
  index index.html;
}
EOF
```

**创建文件**

```
mkdir -p /data/service/frontend/demo
echo "hello world" > /data/service/frontend/demo/index.html
```

**重新读取配置**

```
sudo systemctl reload openresty
```

**访问服务**

```
curl localhost:8000
```

