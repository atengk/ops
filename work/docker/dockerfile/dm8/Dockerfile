# 环境
FROM ubuntu:23.10

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="操作系统版本是：ubuntu:23.10，达梦数据库版本是：20230417"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2023-11-08"

# 拷贝数据
COPY dmdbms /opt/dmdbms
COPY docker-entrypoint.sh /docker-entrypoint.sh

# 定位到指定目录
WORKDIR /opt/dmdbms

# 设置环境变量
ENV LD_LIBRARY_PATH /opt/dmdbms/bin
ENV DM_HOME /opt/dmdbms
ENV PATH $PATH:$DM_HOME/bin

# 设置编码和时区
ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai

# 达梦数据库相关的设置
ENV SYSDBA_PWD Admin@123
ENV DATA_PATH /data
ENV PAGE_SIZE 32
ENV EXTENT_SIZE 32
ENV CASE_SENSITIVE n
ENV LENGTH_IN_CHAR 1
ENV CHARSET 0
ENV DB_NAME dmdb
ENV INSTANCE_NAME dmserver
ENV PORT_NUM 5236

# 安装软件
RUN sed -i "s#http://.*ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y tzdata && \
    apt-get clean && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置容器的启动命令
CMD ["/docker-entrypoint.sh"]
