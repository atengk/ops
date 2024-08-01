# 环境
FROM ubuntu:23.10

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="该镜像作用于KubeSphere的DevOps的Jenkins Agent，\
其中各个软件包版本是：jdk-8u381、apache-maven-3.5.4、git-2.40.1、node-v14.16.0、docker-v20.10.17、kubectl-v1.23.12、helm-v3.9.4，\
同时还设置了系统UTF-8编码和Asia/Shanghai时区、SSH秘钥"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2023-11-03"

# 拷贝数据
ADD jdk-8u381-linux-x64.tar.gz /opt/
ADD apache-maven-3.5.4-bin.tar.gz /opt/
ADD node-v14.16.0-linux-x64.tar.gz /opt/
COPY settings.xml /opt/apache-maven-3.5.4/conf/
COPY docker /usr/local/bin/
COPY kubectl /usr/local/bin/
COPY helm /usr/local/bin/
COPY daemon.json /etc/docker/daemon.json
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
COPY --chmod=600 ssh /root/.ssh

# 设置 jdk maven git node 相关的环境变量
ENV JAVA_HOME /opt/jdk1.8.0_381
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH .:$JAVA_HOME/lib:$JRE_HOME/lib
ENV MAVEN_HOME /opt/apache-maven-3.5.4
ENV NODEJS_HOME /opt/node-v14.16.0-linux-x64
ENV PATH $PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin:$NODEJS_HOME/bin

# 设置编码和时区
ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai

# 安装软件
RUN sed -i "s#http://.*ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y gettext git tzdata && \
    apt-get clean

# 定位到指定目录
WORKDIR /opt

# 配置和安装
RUN npm config --location=global set registry https://registry.npmmirror.com && \
    git config --global user.name "孔余" && \
    git config --global user.email "2385569970@qq.com" && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g' /etc/ssh/ssh_config && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置容器的启动命令
CMD ["./docker-entrypoint.sh"]
