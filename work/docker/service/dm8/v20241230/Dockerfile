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
