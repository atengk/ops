# 编译安装Nginx

## 安装nginx

1. 安装编辑软件

```
yum -y install gcc pcre pcre-devel zlib zlib-devel openssl openssl-devel make
```

2. 解压软件包

```
tar -zxvf nginx-1.23.4.tar.gz
cd nginx-1.23.4
```

3. 配置编译选项

> 配置 Nginx 的编译选项，生成 Makefile

```
./configure --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/nginx/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-pcre-jit \
    --with-file-aio
```

4. 编译和安装

```
make && make install
```

5. systemd管理服务

```
cat > /etc/systemd/system/nginx.service<<"EOF"
[Unit]
Description=Nginx HTTP Server
After=network.target
[Service]
User=root
Type=forking
Restart=on-failure
RestartSec=5
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start nginx
systemctl enable nginx
```

## 启动nginx

1. 优化nginx.conf

```
cp nginx.conf /etc/nginx/nginx.conf
mkdir -p /etc/nginx/conf.d/
systemctl reload nginx
```

2. 示例demo

```
cat > /etc/nginx/conf.d/demo.conf <<EOF
server {
  listen 80;
  server_name _;
  root /data/service/nginx/demo;
  index index.html;
}
EOF
mkdir -p /data/service/nginx/demo
echo "hello world" > /data/service/nginx/demo/index.html
systemctl reload nginx
```

3. 访问demo

```
curl http://localhost/
```

## 配置HTTPS

1. 拷贝证书文件

```
mkdir -p /etc/nginx/ssl
cp tls/tls-cfssl-nginx-server.pem tls/tls-cfssl-nginx-server-key.pem /etc/nginx/ssl
```

2. 编辑配置文件

```
cat > /etc/nginx/conf.d/demo-https.conf <<EOF
server {
  listen 443 ssl;
  server_name nginx.kongyu.local;
  ssl_certificate   /etc/nginx/ssl/tls-cfssl-nginx-server.pem;
  ssl_certificate_key  /etc/nginx/ssl/tls-cfssl-nginx-server-key.pem;
  root /data/service/nginx/demo-https;
  index index.html;
}
EOF
mkdir -p /data/service/nginx/demo-https/
echo "hello world" > /data/service/nginx/demo-https/index.html
```

3. 重启服务

```
systemctl reload nginx
```

4. 访问https

```
curl -v \
    --cacert tls-cfssl-ca.pem \
    -H "Host: nginx.kongyu.local" \
    https://192.168.1.101
```

