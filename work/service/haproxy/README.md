# HAProxy

HAProxy（High Availability Proxy）是一个开源的负载均衡和反向代理解决方案，广泛用于提高Web应用的可用性和性能。它能够智能地将客户端请求分发到多个后端服务器，支持多种负载均衡算法，并具备主动健康检查、SSL/TLS终止、灵活的配置选项以及高吞吐量和低延迟的特点。HAProxy被广泛应用于各种场景，如Web应用、API网关和数据库负载均衡，是确保应用稳定性和响应速度的理想选择。

## 编译安装步骤

1. **下载HAProxy源码**

   ```bash
   wget http://www.haproxy.org/download/3.0/src/haproxy-3.0.5.tar.gz
   ```

2. **解压源码**

   ```bash
   tar -zxvf haproxy-3.0.5.tar.gz
   cd haproxy-3.0.5
   ```

3. **安装编译软件**

   ```shell
   sudo dnf -y install make gcc openssl-devel zlib-devel
   ```

4. **编译HAProxy**（包含常见的编译选项）

   - 我们可以使用以下命令来编译HAProxy，并启用SSL/TLS、gzip压缩和Systemd支持：
     ```bash
     make -j$(nproc) TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1
     ```
   - **编译选项说明**：
     
     - `TARGET=linux-glibc`：适用于大多数Linux系统。
     - `USE_OPENSSL=1`：启用SSL/TLS支持，需要系统中安装OpenSSL。
     - `USE_ZLIB=1`：启用对gzip压缩的支持。
     - `USE_SYSTEMD=1`：与Systemd集成，方便使用Systemd管理HAProxy服务。

5. **安装HAProxy**

   ```bash
   sudo make PREFIX=/usr/local/software/haproxy install
   ```
   - 这会将HAProxy安装到`/usr/local/software/haproxy`。

6. **配置HAProxy**

   - 创建目录：
     ```bash
     sudo mkdir -p /etc/haproxy /data/service/haproxy
     ```
     
   - 编辑`/etc/haproxy/haproxy.cfg`文件，根据需求配置负载均衡规则。

       ```shell
       sudo tee /etc/haproxy/haproxy.cfg <<"EOF"
       # 全局配置
       global
           log stdout format raw local0
           chroot /data/service/haproxy
           stats timeout 30s
           user root
           group root
           daemon
       
           # 默认的SSL/TLS配置（可选）
           # tune.ssl.default-dh-param 2048
       
       # 默认配置
       defaults
           log     global
           mode    http
           option  httplog
           option  dontlognull
           timeout connect 5000ms
           timeout client  50000ms
           timeout server  50000ms
           retries 3
       
           # 错误页面配置
           option redispatch
           maxconn 2000
           timeout http-request 10s
           timeout queue 1m
           timeout http-keep-alive 10s
       
       # 监听统计页面配置
       listen stats
           bind :8080
           mode http
           stats enable
           stats uri /stats
           stats refresh 10s
           stats realm HAProxy\ Statistics
           stats auth admin:Admin@123  # 访问统计页面的用户名和密码
       EOF
       ```

7. **创建Systemd服务文件**

   - 创建`/etc/systemd/system/haproxy.service`文件，并添加以下内容：
     ```shell
     sudo tee /etc/systemd/system/haproxy.service <<"EOF"
     [Unit]
     Description=HAProxy Load Balancer
     After=network.target
     
     [Service]
     ExecStart=/usr/local/software/haproxy/sbin/haproxy -f /etc/haproxy/haproxy.cfg -db
     ExecReload=/bin/kill -USR2 $MAINPID
     KillMode=mixed
     Restart=always
     
     [Install]
     WantedBy=multi-user.target
     EOF
     ```

8. **启用并启动HAProxy服务**
   
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable haproxy
   sudo systemctl start haproxy
   ```
   
9. **测试HAProxy配置文件**

   - 启动或重载HAProxy之前，测试配置文件的正确性：
     ```bash
     /usr/local/software/haproxy/sbin/haproxy -c -f /etc/haproxy/haproxy.cfg
     ```

10. **访问HAProxy服务监控页面**

    ```bash
    URL: http://192.168.1.113:8080/stats
    Username: admin
    Password: Admin@123
    ```


## 配置负载均衡

**编辑配置文件**

编辑`/etc/haproxy/haproxy.cfg`添加以下内容：

```ini
# 前端配置
frontend http_front
    bind *:8080
    default_backend http_back

    # 允许的请求方法
    acl allowed_methods method GET POST PUT DELETE
    http-request deny if !allowed_methods

# 后端配置
backend http_back
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    server http1 192.168.1.12:8080 check
    server http2 192.168.1.13:8080 check
```

重启服务

```shell
sudo systemctl restart haproxy
```

