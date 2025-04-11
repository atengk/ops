# Jenkins Agent镜像构建



## 软件包下载

将以下这些安装包下载后放到 `./packages/` 目录下

**JDK**

- [OpenJDK21安装文档](/work/service/openjdk/openjdk21/)

建议在官方的Web界面下载：[地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jre&version=21)

Jenkins Agent镜像必须要配置JDK环境

```shell
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jre_x64_linux_hotspot_21.0.5_11.tar.gz
```

**Maven**

- [Apache Maven安装文档](/work/service/maven/v3.9.9/)

```shell
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
```

**Node.js**

- [Node.js安装文档](/work/service/nodejs/v22.14.0/)

```shell
wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz
```

**Golang**

```
wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
```

**Docker**

- [Docker安装文档](/work/docker/deploy/v27.3.1/)

```
wget https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz
wget https://github.com/docker/buildx/releases/download/v0.19.2/buildx-v0.19.2.linux-amd64
wget https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-x86_64
```

**kubectl**

```shell
curl -LO https://dl.k8s.io/release/v1.32.3/bin/linux/amd64/kubectl
```

**Helm**

- [Helm安装文档](/work/kubernetes/deploy/helm/)

```shell
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
```



## 创建Dockerfile

```dockerfile
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
```

**构建镜像**

设置构建参数

- `WORK_DIR`：相关软件包都安装目录
- `DATA_DIR`：相关软件包的数据/依赖目录

```shell
docker build -f Dockerfile \
    --build-arg WORK_DIR=/usr/local/software \
    --build-arg DATA_DIR=/data \
    -t registry.lingo.local/service/jenkins-agent-tools-all:1.0.0 .
```



## 测试镜像

**运行镜像**

```shell
docker run --rm -it --hostname ateng \
    registry.lingo.local/service/jenkins-agent-tools-all:1.0.0 bash
```

**查看SSH秘钥**

```
root@ateng:~# cat ~/.ssh/id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEAAAALAOVh0TDlYd
EwAAAAtzc2gtZWQyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEA
AAAEDbLxmQQzqUOHi7Isbf01cbajIFhsuKcsHAqfzcrDfpw7P/z4ixdNG89MgUb8CiVzTX
OOWPn3vj7JAOvKFHs1kQAAAAKTIzODU1Njk5NzBAcXEuY29tIC0gU2VydmVyIEtleSAtID
IwMjUwNDExAQIDBA==
-----END OPENSSH PRIVATE KEY-----
root@ateng:~# cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILP/z4ixdNG89MgUb8CiVzTXOOWPn3vj7JAOvKFHs1kQ 2385569970@qq.com - Server Key - 20250411
```

**查看git**

```
root@ateng:~# git --version
git version 2.39.5
```

**查看JDK**

```
root@ateng:~# java -version
openjdk version "21.0.5" 2024-10-15 LTS
OpenJDK Runtime Environment Temurin-21.0.5+11 (build 21.0.5+11-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.5+11 (build 21.0.5+11-LTS, mixed mode, sharing)
```

**查看Maven**

```
root@ateng:~# mvn -v
Apache Maven 3.9.9 (8e8579a9e76f7d015ee5ec7bfcdc97d260186937)
Maven home: /usr/local/software/maven
Java version: 21.0.5, vendor: Eclipse Adoptium, runtime: /usr/local/software/jdk
Default locale: zh_CN, platform encoding: UTF-8
OS name: "linux", version: "6.3.2-1.el7.elrepo.x86_64", arch: "amd64", family: "unix"
```

下载测试

```
root@ateng:~# mvn help:system
root@ateng:~# ls -l /data/maven/repository/
```

**查看Node.js**

```
root@ateng:~# node -v
v22.14.0
root@ateng:~# npm config list
; "user" config from /root/.npmrc

prefix = "/data/nodejs"

; "env" config from environment

registry = "https://registry.npmmirror.com"

; node bin location = /usr/local/software/nodejs/bin/node
; node version = v22.14.0
; npm local prefix = /root
; npm version = 10.9.2
; cwd = /root
; HOME = /root
; Run `npm config ls -l` to show all defaults.
```

下载测试

```
root@ateng:~# npm install -g http-server
root@ateng:~# ls -l /data/nodejs/bin
root@ateng:~# http-server --version
v14.1.1
```

**查看Python**

```
root@ateng:~# python3 -V
Python 3.11.2
root@ateng:~# pip config list
global.index-url='https://pypi.tuna.tsinghua.edu.cn/simple'
global.target='/data/python'
install.trusted-host='pypi.tuna.tsinghua.edu.cn'
```

下载测试

```
root@ateng:~# pip install requests
root@ateng:~# ls -l /data/python/
```

**查看Golang**

```
root@ccaf9d7bea4c:~# go version
go version go1.24.2 linux/amd64
root@ccaf9d7bea4c:~# go env
```

下载测试

```
root@ccaf9d7bea4c:~# go install github.com/jesseduffield/lazygit@latest
root@ccaf9d7bea4c:~# ls -l $GOPATH/bin
```

**查看Docker**

```
root@ateng:~# docker version
Client:
 Version:           27.3.1
 API version:       1.47
 Go version:        go1.22.7
 Git commit:        ce12230
 Built:             Fri Sep 20 11:39:44 2024
 OS/Arch:           linux/amd64
 Context:           default
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

**查看kubectl**

```
root@ateng:~# kubectl version
Client Version: v1.32.3
Kustomize Version: v5.5.0
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

**查看helm**

```
root@ateng:~# helm version
version.BuildInfo{Version:"v3.16.2", GitCommit:"13654a52f7c70a143b1dd51416d633e1071faffb", GitTreeState:"clean", GoVersion:"go1.22.7"}
```



## 保存镜像

**推送镜像**

```shell
docker push registry.lingo.local/service/jenkins-agent-tools-all:1.0.0
```

**保存镜像**

```
docker save \
    registry.lingo.local/service/jenkins-agent-tools-all:1.0.0 \
    | gzip -c > image-jenkins-agent-tools-all_1.0.0.tar.gz
```

