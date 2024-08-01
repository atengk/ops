# 环境
FROM ubuntu:23.10

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="用于备份ETCD数据到MinIO中"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2023-12-20"

# 拷贝数据
ADD etcd-v3.5.1-binary.tar.gz /usr/bin
ADD minio-v20231214-binary.tar.gz /usr/bin
COPY backup-etcd-to-minio.sh /usr/bin

# 定位到指定目录
WORKDIR /usr/bin

# 设置编码和时区
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV TZ=Asia/Shanghai

# 安装软件
RUN sed -i "s#http://.*ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y tzdata bash gzip && \
    apt-get clean && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置容器的启动命令
CMD ["backup-etcd-to-minio.sh"]
