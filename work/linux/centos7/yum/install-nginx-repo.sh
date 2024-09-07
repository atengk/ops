#!/bin/bash

## 配置参数
NGINX_PORT=80
NGINX_DIR=/opt/nginx

set -x

## 安装http
yum localinstall -y --disablerepo=* --skip-broken nginx/packages/*.rpm

## 创建数据目录
mkdir -p ${NGINX_DIR}

## 配置文件
cat > /etc/nginx/conf.d/data.conf <<EOF
autoindex on;# 显示目录
autoindex_exact_size on;# 显示文件大小
autoindex_localtime on;# 显示文件时间

server {
    charset      utf-8,gbk;
    listen       ${NGINX_PORT};
    server_name  _;
    root         ${NGINX_DIR};
}
EOF

## 启动nginx
systemctl restart nginx
systemctl enable nginx
