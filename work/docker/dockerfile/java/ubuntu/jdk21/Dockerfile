# 环境
FROM registry.lingo.local/service/ubuntu:24.04

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="操作系统版本是：ubuntu:24.04，Java版本是：Eclipse Temurin发版的OpenJDK 21"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2024-06-21"

# 拷贝数据
ADD OpenJDK21U-*.tar.gz /opt/

# 定位到指定目录
WORKDIR /opt

# 设置 JDK 相关的环境变量
ENV JAVA_HOME=/opt/jdk21
ENV PATH=$PATH:$JAVA_HOME/bin

# 设置时区
ENV TZ=Asia/Shanghai

# 安装软件
RUN sed -i "s#http://.*ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y locales tzdata curl && \
    apt-get clean && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    mv /opt/jdk-21* /opt/jdk21 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置编码
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh

# 设置用户
USER 1001:1001

# 设置容器的启动命令
CMD ["java", "-version"]
