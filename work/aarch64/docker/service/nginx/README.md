# Nginx

Nginx 是一个高性能的开源 Web 服务器、反向代理服务器和负载均衡器。它以其轻量级、异步事件驱动架构而闻名，能够高效处理大量并发连接。Nginx 常用于静态文件服务、负载均衡、SSL 终端处理和反向代理等任务，广泛应用于高流量网站。由于其高性能、灵活配置和低资源消耗，Nginx 在现代 Web 基础设施中得到了广泛使用。

- [官网链接](https://nginx.org/)



**下载镜像**

```
docker pull bitnami/nginx:1.27.3
```

**推送到仓库**

```
docker tag bitnami/nginx:1.27.3 registry.lingo.local/bitnami/nginx:1.27.3
docker push registry.lingo.local/bitnami/nginx:1.27.3
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/nginx:1.27.3 | gzip -c > image-nginx_1.27.3.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/nginx/{config,data}
sudo chown -R 1001 /data/container/nginx
```

**创建配置文件**

创建配置文件

```
sudo tee /data/container/nginx/config/my_demo.conf <<"EOF"
server {
  listen 8000;
  server_name _;
  root /data/demo;
  index index.html;
}
EOF
```

创建静态页面

```
mkdir /data/container/nginx/data/demo
echo "hello world" > /data/container/nginx/data/demo/index.html
```

**运行服务**

```
docker run -d --name ateng-nginx \
  -p 20027:8000 --restart=always \
  -v /data/container/nginx/config/my_demo.conf:/opt/bitnami/nginx/conf/server_blocks/my_demo.conf:ro \
  -v /data/container/nginx/data:/data \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/nginx:1.27.3
```

**查看日志**

```
docker logs -f ateng-nginx
```

**使用服务**

```
Demo URL: http://172.16.0.149:20027
```

**删除服务**

停止服务

```
docker stop ateng-nginx
```

删除服务

```
docker rm ateng-nginx
```

删除目录

```
sudo rm -rf /data/container/nginx
```

