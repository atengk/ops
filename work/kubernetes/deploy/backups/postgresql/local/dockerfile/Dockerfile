# 环境
FROM registry.lingo.local/service/debian:12.5

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="用于备份PostgreSQL数据"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2024-08-01"

# 拷贝数据
COPY docker-entrypoint.sh /usr/bin/

# 定位到指定目录
WORKDIR /opt

# 设置时区
ENV TZ=Asia/Shanghai

# 安装软件
RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.cloud.tencent.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y locales bash gzip lsb-release curl gnupg && \
    echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    apt-get update && \
    apt-get install -y postgresql-client-16 && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置编码
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 设置用户
USER 1001:1001

# 设置容器的启动命令
CMD ["docker-entrypoint.sh"]
