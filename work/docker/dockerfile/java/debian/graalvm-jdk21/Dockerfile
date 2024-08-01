# 环境
FROM registry.lingo.local/service/debian:12.5

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="操作系统版本是：debian:12.5，Java版本是：Oracle发版的Graalvm JDK 21"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2024-06-20"

# 拷贝数据
ADD graalvm-jdk-21_linux-x64_bin.tar.gz /opt/
ADD apache-maven-3.9.6-bin.tar.gz /opt/
COPY --chown=1001:1001 settings.xml /opt/apache-maven-3.9.6/conf/

# 定位到指定目录
WORKDIR /opt

# 设置 JDK 相关的环境变量
ENV JAVA_HOME=/opt/jdk21
ENV MAVEN_HOME /opt/apache-maven-3.9.6
ENV PATH $PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin

# 设置时区
ENV TZ=Asia/Shanghai

# 安装软件
RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.cloud.tencent.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y locales curl gcc binutils zlib1g-dev && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    mv /opt/graalvm-jdk-21* /opt/jdk21 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置编码
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8


# 设置用户
USER 1001:1001

# 设置容器的启动命令
CMD ["java", "-version"]
