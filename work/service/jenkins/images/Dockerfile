# 镜像基础
FROM debian:12.10

# 作者/元信息
LABEL maintainer="阿腾 <2385569970@qq.com>" \
      org.opencontainers.image.title="DevOps 工具集镜像" \
      org.opencontainers.image.description="包含 Java、Maven、Node.js、Docker、Go 等常用工具的开发运维环境" \
      org.opencontainers.image.authors="阿腾" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.created="2025-04-11T12:00:00+08:00" \
      org.opencontainers.image.licenses="MIT"

# 定义构建时的参数，WORK_DIR软件包安装目录、DATA_DIR软件包的数据目录
ARG WORK_DIR=/usr/local/software \
    DATA_DIR=/data

# 设置工作目录
WORKDIR ${WORK_DIR}

# 复制依赖包
COPY packages packages

# 修改镜像源 & 更新系统
RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get upgrade -y

# 安装常用工具
RUN apt-get install -y \
    python3=3.11.* python3-pip=23.* \
    git=1:2.39.* \
    locales \
    curl \
    unzip zip \
    rar unrar p7zip-full \
    tar gzip bzip2 \
    xz-utils \
    psmisc htop lsof netcat-openbsd telnet iftop psmisc nfs-common \
    vim \
    tree \
    gettext-base \
    net-tools \
    iproute2 \
    iputils-ping \
    less \
    wget \
    jq \
    dnsutils \
    traceroute \
    tcpdump \
    nmap \
    fontconfig \
    fonts-dejavu-core \
    fonts-noto-cjk \
    fonts-liberation && \
    apt-get clean

# 配置中文语言环境
RUN echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8

# Git 配置 & SSH 优化
RUN git config --global user.name "阿腾" && \
    git config --global user.email "2385569970@qq.com" && \
    sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g' /etc/ssh/ssh_config && \
    ssh-keygen -t ed25519 -P "" -f ~/.ssh/id_ed25519 -C "2385569970@qq.com - Server Key - $(date +%Y%m%d)" && \
    cat ~/.ssh/id_*.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

# 创建必要目录
RUN mkdir -p /workspace /home/jenkins /data ${WORK_DIR} ${DATA_DIR}

# 解压并配置 JDK
RUN tar -zxvf packages/OpenJDK*.tar.gz -C ${WORK_DIR}/ && \
    mv ${WORK_DIR}/jdk* ${WORK_DIR}/jdk
# 设置 JDK 环境变量
ENV JAVA_HOME=${WORK_DIR}/jdk
ENV PATH=$PATH:${JAVA_HOME}/bin

# 解压并配置 Maven + Maven 阿里云仓库
RUN tar -zxvf packages/apache-maven*.tar.gz -C ${WORK_DIR}/ && \
    mv ${WORK_DIR}/apache-maven* ${WORK_DIR}/maven && \
    mkdir -p ${DATA_DIR}/maven/repository && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' > ${WORK_DIR}/maven/conf/settings.xml && \
    echo '<settings>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '  <localRepository>${DATA_DIR}/maven/repository</localRepository>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '  <mirrors>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '    <mirror>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '      <id>alimaven</id>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '      <name>aliyun maven</name>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '      <mirrorOf>central</mirrorOf>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '    </mirror>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '  </mirrors>' >> ${WORK_DIR}/maven/conf/settings.xml && \
    echo '</settings>' >> ${WORK_DIR}/maven/conf/settings.xml
# 设置 Maven 环境变量
ENV MAVEN_HOME=${WORK_DIR}/maven
ENV PATH=$PATH:${MAVEN_HOME}/bin

# 设置Node.js国内镜像源
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com \
    NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node \
    NPM_GLOBAL_PREFIX=${DATA_DIR}/nodejs
# 设置 Node.js 环境变量
ENV NODEJS_HOME=${WORK_DIR}/nodejs
ENV PATH=$PATH:${NODEJS_HOME}/bin:$NPM_GLOBAL_PREFIX/bin
# 解压并配置 Node.js
RUN tar -xJvf packages/node-*.tar.xz -C ${WORK_DIR}/ && \
    mv ${WORK_DIR}/node* ${WORK_DIR}/nodejs && \
    mkdir -p $NPM_GLOBAL_PREFIX && \
    npm config set prefix $NPM_GLOBAL_PREFIX

# Python 设置
RUN echo "[global]" > /etc/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf && \
    echo "target=${DATA_DIR}/python" >> /etc/pip.conf && \
    echo "" >> /etc/pip.conf && \
    echo "[install]" >> /etc/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf
ENV PYTHONPATH=${DATA_DIR}/python

# 解压并配置 Golang
RUN tar -zxvf packages/go*.tar.gz -C ${WORK_DIR}/ && \
    mkdir -p ${DATA_DIR}/golang
# 设置 Golang 环境变量
ENV GOROOT=${WORK_DIR}/go \
    GOPATH=${DATA_DIR}/golang \
    GOPROXY=https://goproxy.cn,direct
ENV PATH=$PATH:${GOROOT}/bin:${GOPATH}/bin

# 解压并配置 Docker
RUN tar -zxvf packages/docker-*.tgz -C /tmp && \
    cp -v /tmp/docker/* /usr/bin/ && \
    mkdir -p /usr/lib/docker/cli-plugins && \
    cp packages/buildx-* /usr/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/lib/docker/cli-plugins/docker-buildx && \
    cp packages/docker-compose-linux-x86_64 /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose && \
    mkdir -p /etc/docker && \
    echo '{' >> /etc/docker/daemon.json && \
    echo '  "features": { "buildkit": true },' >> /etc/docker/daemon.json && \
    echo '  "insecure-registries": ["0.0.0.0/0"]' >> /etc/docker/daemon.json && \
    echo '}' >> /etc/docker/daemon.json

# 解压并安装 Helm、复制 kubectl
RUN tar -zxvf packages/helm-*.tar.gz -C /tmp && \
    cp /tmp/linux-amd64/helm /usr/bin && \
    cp packages/kubectl* /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# 清理多余文件
RUN rm -rf packages /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置时区和语言
ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# 设置路径变量
ENV WORK_DIR=${WORK_DIR} \
    DATA_DIR=${DATA_DIR}

# 设置工作目录
WORKDIR /root
