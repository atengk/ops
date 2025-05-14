# OpenResty 使用文档



## 配置Vue资源服务

**创建目录**

```
mkdir -p /data/service/frontend/vue-demo
cd /data/service/frontend/vue-demo
```

**创建静态资源**

```
unzip dist.zip
```

**创建配置文件**

```
cat > nginx.conf <<"EOF"
worker_processes  1;
user admin ateng;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Gzip 加速压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;

    # 保留真实客户端 IP
    real_ip_header X-Forwarded-For;
    set_real_ip_from 0.0.0.0/0;  # 如果你有反向代理（如 CDN 或网关），请填写它的 IP 段

    server {
        listen       8010;
        server_name  _;

        # 日志
        access_log  logs/access.log;
        error_log   logs/error.log;

        root ./dist;

        # 首页和前端路由支持
        location / {
        # OPTIONS 预检请求处理
            if ($request_method = OPTIONS) {
                add_header Access-Control-Allow-Origin *;
                add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
                add_header Access-Control-Allow-Headers "*";
                return 204;
            }
            
            # 缓存策略
            expires 7d;
            add_header Cache-Control "public";

            # 全局允许跨域
            add_header Access-Control-Allow-Origin * always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
            add_header Access-Control-Allow-Headers "*" always;
        
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # 静态资源缓存策略
        location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|eot|ttf|svg)$ {
            expires 30d;
            access_log off;
            add_header Cache-Control "public, immutable";
            add_header Access-Control-Allow-Origin * always;
        }
        
    }
}
EOF
```

**创建日志目录**

```
mkdir -p logs
```

配置 Systemd

```
sudo tee /etc/systemd/system/openresty-vue-demo.service <<"EOF"
[Unit]
Description=OpenResty Server - Vue Demo
After=network.target

[Service]
User=root
Group=root
Type=forking
WorkingDirectory=/data/service/frontend/vue-demo
ExecStartPre=openresty -p /data/service/frontend/vue-demo -t -c nginx.conf
ExecStart=openresty -p /data/service/frontend/vue-demo -c nginx.conf
ExecReload=openresty -p /data/service/frontend/vue-demo -c nginx.conf -s reload
ExecStop=openresty -p /data/service/frontend/vue-demo -c nginx.conf -s stop
Restart=on-failure
RestartSec=3
TimeoutStartSec=30
TimeoutStopSec=30
KillMode=control-group
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable --now openresty-vue-demo
```

**查看服务状态**

```
sudo systemctl status openresty-vue-demo
```

**查看日志**

```
tail -f logs/*.log
```



## 使用lua脚本

**创建配置文件**

```
tee /etc/nginx/conf.d/demo-hello.conf <<EOF
server {
    listen 8080;
    server_name localhost;

    location /hello {
        content_by_lua_block {
            ngx.say("Hello from OpenResty!")
        }
    }

    # 状态页
    location /status {
        stub_status;
    }
}
EOF
```

**检查配置正确性**

```
openresty -t
```

输出以下内容：

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**重新读取配置**

```
sudo systemctl reload openresty
```

**访问服务**

访问 `/hello`

```
$ curl localhost:8080/hello
Hello from OpenResty!
```

访问 `/status`

```
$ curl localhost:8080/status
Active connections: 1 
server accepts handled requests
 3 3 3 
Reading: 0 Writing: 1 Waiting: 0 
```

