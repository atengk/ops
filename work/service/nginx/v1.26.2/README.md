# Nginx 安装与配置文档

本文档将指导您如何从源代码安装 Nginx 并进行相关配置。以下步骤适用于基于 `yum` 包管理器的 Linux 系统（如 CentOS 或 RHEL）。

## 安装Nginx

### 1. 下载 Nginx 源代码

首先，使用 `wget` 从官方 Nginx 网站下载最新版本的 Nginx 源代码包：

```bash
wget https://nginx.org/download/nginx-1.26.2.tar.gz
```

### 2. 解压缩源代码包

下载完成后，使用 `tar` 解压缩 Nginx 源代码：

```bash
tar -zxvf nginx-1.26.2.tar.gz
```

### 3. 进入源代码目录

解压后进入 Nginx 源代码的目录：

```bash
cd nginx-1.26.2
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
sudo make install
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
export NGINX_HOME=/usr/local/software/nginx
export PATH=$PATH:$NGINX_HOME/sbin
EOF
source ~/.bash_profile
```

查看版本

```
nginx -V
```

### 7. 配置 Nginx

创建并编辑 Nginx 主配置文件。以下配置文件为 `/etc/nginx/nginx.conf`，它包含基本的日志、事件、HTTP 设置等：

```bash
sudo tee /etc/nginx/nginx.conf <<"EOF"
user root;
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

- `user`: 使用root用户运行。

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

创建 `nginx.conf.d` 目录，用于存放虚拟主机等其他配置文件：

```bash
sudo mkdir -p /etc/nginx/conf.d/
```

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
- 使用root用户运行，不然一些特殊端口无法绑定，例如80和443。

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



## 配置Server

### 简单的示例

创建一个简单的示例，来测试Nginx是否正常

```
sudo tee /etc/nginx/conf.d/demo.conf <<EOF
server {
  listen 8000;
  server_name _;
  root /data/service/frontend/demo;
  index index.html;
}
EOF
```

创建文件

```
mkdir -p /data/service/frontend/demo
echo "hello world" > /data/service/frontend/demo/index.html
```

重新读取配置

```
sudo systemctl reload nginx
```

访问服务

```
curl localhost:8000
```

### 配置Vue资源服务

创建配置文件

```nginx
sudo tee /etc/nginx/conf.d/8001-vue-demo.conf <<"EOF"
server {
    listen       8001;
    server_name  _;

    location / {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS, HEAD';
            add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept, Authorization, token';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Length' 0;
            return 204;
        }

        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS, HEAD';
        add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept, Authorization, token';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Max-Age' 1728000;

        proxy_set_header Host               $host;
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_redirect                      off;

        root   /data/service/frontend/vue-demo/dist;
        index  index.html;
        try_files $uri $uri/ /index.html;
    }
}
EOF
```

配置解释

- `listen 8001;`: 指定服务器监听的端口。
- `server_name _;`: 设定服务器名称为 `_`，通常用于匹配所有请求。
- `location / { ... }`: 处理所有以 `/` 开头的请求。
    - `if ($request_method = 'OPTIONS') { ... }`: 处理 CORS 预检请求（`OPTIONS` 方法）。设置适当的 CORS 头部，并返回 204 状态码。

    - `add_header 'Access-Control-Allow-Origin' '*';`: 设置允许所有来源访问的 CORS 头部。
    - `add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';`: 允许的请求方法。
    - `add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept';`: 允许的请求头。
    - `add_header 'Access-Control-Allow-Credentials' 'true';`: 允许发送凭证（如 cookies）。
    - `add_header 'Access-Control-Max-Age' 1728000;`: 预检请求的缓存时间。

    - `proxy_set_header` 指令: 设置传递到后端服务器的请求头部，确保获取客户端真实 IP 等信息。

    - `root /data/service/frontend/vue-html/dist;`: 设置根目录为构建后的文件位置。
    - `index index.html;`: 指定默认首页文件。
    - `try_files $uri $uri/ /index.html;`: 尝试匹配请求的 URI 或目录，如果都不存在，则返回 `index.html`，通常用于前端路由。

创建数据目录并解压文件

```shell
mkdir -p /data/service/frontend/vue-demo/
cd /data/service/frontend/vue-demo/
unzip dist.zip
```

重新读取配置

```
sudo systemctl reload nginx
```

访问服务

```
http://192.168.1.112:8001
```



### 配置HTTPS

#### 1. 使用 OpenSSL 创建自签名证书

首先，我们需要生成 SSL 证书和私钥。以下是使用 OpenSSL 创建自签名证书的步骤和命令：

详细的生成证书参考：https://kongyu666.github.io/work/#/work/service/tls/tls-openssl/

```bash
# 创建目录
sudo mkdir -p /etc/nginx/ssl

# 生成私钥
sudo openssl genrsa -out /etc/nginx/ssl/private.key 2048

# 生成自签名证书
sudo openssl req -new -x509 -key /etc/nginx/ssl/private.key -out /etc/nginx/ssl/certificate.crt -days 365 -utf8 \
    -subj "/C=CN/ST=重庆市/L=重庆市/O=阿腾集团/OU=研发中心/CN=nginx.ateng.local"
```

这些命令将生成一个私钥文件 `private.key` 和一个自签名证书文件 `certificate.crt`，有效期为 365 天。

- `openssl genrsa`：生成一个 RSA 私钥。

- `openssl req -new -x509`：创建一个新的 X.509 证书请求，并使用私钥签名生成自签名证书。

    - `/C=AU`: 国家代码（2 个字母），例如 AU 表示澳大利亚。

    - `/ST=Some-State`: 州或省的名称。

    - `/L=Some-City`: 城市名称。

    - `/O=My-Company`: 组织名称（公司名）。

    - `/OU=My-Department`: 组织单位名称（部门）。

    - `/CN=your_domain.com`: 通用名称（通常是服务器的 FQDN 或者域名），替换为你的域名。

#### 2. 配置 Nginx 使用 HTTPS

以下是一个简单的 Nginx 配置文件，启用 HTTPS 并使用刚刚创建的 SSL 证书：

```nginx
sudo tee /etc/nginx/conf.d/demo-https.conf <<"EOF"
server {
    listen 80;
    server_name nginx.ateng.local;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;  # 监听 443 端口并启用 SSL

    server_name nginx.ateng.local;  # 替换为你的域名

    ssl_certificate /etc/nginx/ssl/certificate.crt;  # SSL 证书路径
    ssl_certificate_key /etc/nginx/ssl/private.key;  # SSL 私钥路径

    ssl_protocols TLSv1.2 TLSv1.3;  # 启用的 SSL 协议
    ssl_ciphers HIGH:!aNULL:!MD5;   # 安全加密算法配置

    location / {
        root /data/service/frontend/demo-https;  # 网站根目录
        index index.html;
    }
}
EOF
```

配置说明

- **`listen 443 ssl;`**: Nginx 监听 443 端口并启用 SSL（HTTPS）。
- **`server_name your_domain.com;`**: 替换为你自己的域名。
- **`ssl_certificate`**: 指定 SSL 证书的路径。
- **`ssl_certificate_key`**: 指定 SSL 私钥的路径。
- **`ssl_protocols`**: 启用的 SSL/TLS 协议版本，这里使用 TLS 1.2 和 TLS 1.3。
- **`ssl_ciphers`**: 指定允许的加密算法，用于增强安全性。
- **`location /`**: 定义网站的根目录。
- **`if ($scheme = http)`**: 将 HTTP 请求重定向到 HTTPS，确保所有流量使用加密连接。

#### 3. 创建文件

```
mkdir -p /data/service/frontend/demo-https
echo "hello world https" > /data/service/frontend/demo-https/index.html
```

#### 4. 启动或重新加载 Nginx

在配置完 Nginx 后，启动或重新加载服务以使更改生效：

```bash
sudo systemctl reload nginx
```

通过上述配置，Nginx 将启用 HTTPS 并使用生成的自签名证书。请注意，自签名证书通常用于开发和测试环境，而不是生产环境。在生产环境中，建议使用受信任的证书颁发机构（CA）签发的证书。

#### 5. 访问服务

```
curl --cacert /etc/nginx/ssl/certificate.crt https://nginx.ateng.local
```

