#!/bin/bash

## 配置参数
HTTP_PORT=80
HTTP_DIR=/opt/http

set -x

## 安装http
yum localinstall -y --disablerepo=* --skip-broken httpd/packages/*.rpm

## 去掉apache首页，显示目录结构
sed -i "s#-Indexes#+Indexes#" /etc/httpd/conf.d/welcome.conf 
## 修改数据目录
mkdir -p ${HTTP_DIR}
#sed -i "s#DocumentRoot .*#DocumentRoot \"${HTTP_DIR}\"#" /etc/httpd/conf/httpd.conf
sed -i "s#/var/www/html#${HTTP_DIR}#" /etc/httpd/conf/httpd.conf
## 设置端口
sed -i "s#Listen .*#Listen ${HTTP_PORT}#" /etc/httpd/conf/httpd.conf

## 启动http
systemctl restart httpd
systemctl enable httpd
