# 达梦数据库

达梦数据库（DM）是一款国产关系型数据库管理系统，由达梦数据库公司开发，主要面向政府、金融、电力等行业。其具有高性能、高可靠性、强安全性和兼容性，支持SQL标准和多种数据库功能，如事务管理、数据备份、恢复等。DM数据库提供跨平台支持，能够在多种操作系统上运行，广泛应用于大规模数据处理和高并发场景。

- [官网地址](https://eco.dameng.com/document/dm/zh-cn/start/dm-install-docker.html)

## 官网镜像

使用官网提供的镜像完成达梦数据库的安装和使用

**下载镜像**

通过该地址下载Docker镜像：https://eco.dameng.com/download/

```
wget https://download.dameng.com/eco/dm8/dm8_20241230_x86_rh6_64_rq_single.tar
```

**读取镜像**

```
# docker load -i dm8_20241230_x86_rh6_64_rq_single.tar
Loaded image: dm8:dm8_20241230_rev255012_x86_rh6_64
```

**推送到仓库**

```
docker tag dm8:dm8_20241230_rev255012_x86_rh6_64 registry.lingo.local/service/dm8:dm8_20241230_rev255012_x86_rh6_64
docker push registry.lingo.local/service/dm8:dm8_20241230_rev255012_x86_rh6_64
```

**保存镜像**

```
docker save registry.lingo.local/service/dm8:dm8_20241230_rev255012_x86_rh6_64 | gzip -c > image-dm8_20241230_rev255012_x86_rh6_64.tar.gz
rm -f dm8_20241230_x86_rh6_64_rq_single.tar
```

**创建目录**

```
sudo mkdir -p /data/container/dm8
sudo chown -R 1000:1000 /data/container/dm8
```

**运行服务**

```
docker run -d --name=ateng-dm8 \
  -p 20026:5236 --restart=always \
  -v /data/container/dm8:/opt/dmdbms/data \
  -e LD_LIBRARY_PATH=/opt/dmdbms/bin \
  -e PAGE_SIZE=32 \
  -e EXTENT_SIZE=32 \
  -e CASE_SENSITIVE=0 \
  -e UNICODE_FLAG=0 \
  -e INSTANCE_NAME=DMSERVER \
  -e BLANK_PAD_MODE=0 \
  -e LOG_SIZE=256 \
  -e BUFFER=1000 \
  -e SYSDBA_PWD=Admin@123 \
  -e SYSAUDITOR_PWD=Admin@123 \
  registry.lingo.local/service/dm8:dm8_20241230_rev255012_x86_rh6_64
```

**查看日志**

```
docker logs -f ateng-dm8
```

**使用服务**

```
Address: 192.168.1.12:20026
Username: SYSDBA
Password: Admin@123
```

**删除服务**

停止服务

```
docker stop ateng-dm8
```

删除服务

```
docker rm ateng-dm8
```

删除目录

```
sudo rm -rf /data/container/dm8
```

## 自定义镜像

因为官网提供的镜像有些参数涉及不全面，所以这里使用官网提供的安装包自定义制作镜像

### 下载原生镜像

**下载镜像**

通过该地址下载Docker镜像：https://eco.dameng.com/download/

```
wget https://download.dameng.com/eco/dm8/dm8_20241230_x86_rh6_64_rq_single.tar
```

**读取镜像**

```
# docker load -i dm8_20241230_x86_rh6_64_rq_single.tar
Loaded image: dm8:dm8_20241230_rev255012_x86_rh6_64
```

### 构建镜像

**创建Dockerfile**

```
cat > Dockerfile <<"EOF"
# 原始镜像
FROM dm8:dm8_20241230_rev255012_x86_rh6_64 AS builder

# 环境
FROM ubuntu:24.04

# 拷贝原始镜像的文件
COPY --from=builder --chown=1001:1001 /opt/dmdbms /opt/dmdbms

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="操作系统版本是：ubuntu:24.04，达梦数据库版本是：v20241230"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2025-02-13"

# 拷贝文件
COPY --chown=1001:1001 docker-entrypoint.sh /docker-entrypoint.sh

# 定位到指定目录
WORKDIR /opt/dmdbms

# 设置环境变量
ENV LD_LIBRARY_PATH /opt/dmdbms/bin
ENV DM_HOME /opt/dmdbms
ENV PATH $PATH:$DM_HOME/bin

# 设置编码和时区
ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai

# 安装软件
RUN sed -i "s#http://.*ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y tzdata && \
    apt-get clean && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    groupadd -g 1001 dinstall && \
    useradd -u 1001 -g dinstall -m dmdba && \
    mkdir -p /data && \
    chown 1001:1001 -R /opt /data && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置用户
USER 1001:1001

# 设置容器的启动命令
ENTRYPOINT ["/docker-entrypoint.sh"]
EOF
```

**创建脚本**

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash

# 配置初始化参数变量
export SYSDBA_PWD=${SYSDBA_PWD:-Admin@123}
export SYSAUDITOR_PWD=${SYSAUDITOR_PWD:-Admin@123}
export DATA_PATH=${DATA_PATH:-/data}
export PAGE_SIZE=${PAGE_SIZE:-32}
export EXTENT_SIZE=${EXTENT_SIZE:-32}
export CASE_SENSITIVE=${CASE_SENSITIVE:-n}
export UNICODE_FLAG=${UNICODE_FLAG:-0}
export LOG_SIZE=${LOG_SIZE:-256}
export BUFFER=${BUFFER:-1000}
export DB_NAME=${DB_NAME:-dmdb}
export INSTANCE_NAME=${INSTANCE_NAME:-dmserver}
export PORT_NUM=${PORT_NUM:-5236}
# 初始化参数
export DMINIT_OPTS=${DMINIT_OPTS:-path=${DATA_PATH} PAGE_SIZE=${PAGE_SIZE} EXTENT_SIZE=${EXTENT_SIZE} CASE_SENSITIVE=${CASE_SENSITIVE} UNICODE_FLAG=${UNICODE_FLAG} DB_NAME=${DB_NAME} INSTANCE_NAME=${INSTANCE_NAME} PORT_NUM=${PORT_NUM} LOG_SIZE=${LOG_SIZE} BUFFER=${BUFFER} SYSDBA_PWD=${SYSDBA_PWD} SYSAUDITOR_PWD=${SYSAUDITOR_PWD} }

## 初始化配置
if [ ! -d "${DATA_PATH}/${DB_NAME}" ]; then
    echo -e "\033[1;3$((RANDOM%10%8))m 开始初始化达梦数据库... \033[0m"
    echo "dminit ${DMINIT_OPTS}"
    dminit ${DMINIT_OPTS}
    echo -e "\033[1;3$((RANDOM%10%8))m 初始化达梦数据库完成！ \033[0m"
fi

## 启动达梦数据库
echo -e "\033[1;3$((RANDOM%10%8))m 启动达梦数据库... \033[0m"
dmserver /data/dmdb/dm.ini -noconsole
EOF
```

**构建镜像**

```
docker build -t registry.lingo.local/service/dm8:v20241230 .
```

**推送到仓库**

```
docker push registry.lingo.local/service/dm8:v20241230
```

**保存镜像**

```
docker save registry.lingo.local/service/dm8:v20241230 | gzip -c > image-dm8_v20241230.tar.gz
```

### 运行容器

**创建目录**

```
sudo mkdir -p /data/container/dm8
sudo chown -R 1001:1001 /data/container/dm8
```

**运行服务**

设置指定的参数

```
docker run -d --name=ateng-dm8 \
  -p 20026:5236 --restart=always \
  -v /data/container/dm8:/data \
  -e PAGE_SIZE=32 \
  -e EXTENT_SIZE=32 \
  -e CASE_SENSITIVE=0 \
  -e UNICODE_FLAG=0 \
  -e INSTANCE_NAME=DMSERVER \
  -e DB_NAME=dmdb \
  -e BLANK_PAD_MODE=0 \
  -e LOG_SIZE=256 \
  -e BUFFER=1000 \
  -e SYSDBA_PWD=Admin@123 \
  -e SYSAUDITOR_PWD=Admin@123 \
  registry.lingo.local/service/dm8:v20241230
```

也可以直接设置**DMINIT_OPTS**这一个环境变量，直接设置所有的参数

```
docker run -d --name=ateng-dm8 \
  -p 20026:5236 --restart=always \
  -v /data/container/dm8:/data \
  -e DMINIT_OPTS="path=/data PAGE_SIZE=32 EXTENT_SIZE=32 CASE_SENSITIVE=n UNICODE_FLAG=0 DB_NAME=dmdb INSTANCE_NAME=dmserver PORT_NUM=5236 LOG_SIZE=256 BUFFER=1000 SYSDBA_PWD=Admin@123 SYSAUDITOR_PWD=Admin@123" \
  registry.lingo.local/service/dm8:v20241230
```

**查看日志**

```
docker logs -f ateng-dm8
```

**使用服务**

```
Address: 192.168.1.12:20026
Username: SYSDBA
Password: Admin@123
```

**删除服务**

停止服务

```
docker stop ateng-dm8
```

删除服务

```
docker rm ateng-dm8
```

删除目录

```
sudo rm -rf /data/container/dm8
```

