# Jenkins Agent镜像构建



## Dockerfile

创建 `Dockerfile-all-builder` 文件，添加以下内容

```dockerfile
# 复制镜像软件
FROM docker:27.3 AS builder_docker

# 镜像基础
FROM debian:12.10

# 作者/元信息
LABEL maintainer="阿腾 <2385569970@qq.com>" \
      org.opencontainers.image.title="DevOps 工具集镜像" \
      org.opencontainers.image.description="包含 Java、Maven、Node.js、Golang、Python、Docker、kubectl、kustomize、helm 等常用工具的开发运维环境" \
      org.opencontainers.image.authors="阿腾" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.created="2025-05-10T12:00:00+08:00" \
      org.opencontainers.image.licenses="MIT"

# 定义构建时的参数，WORK_DIR软件包安装目录、DATA_DIR软件包的数据目录
ARG WORK_DIR=/usr/local/software \
    DATA_DIR=/data

# 定义容器的用户信息，需要和inbound-agent镜像的用户信息保持一致
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# 设置工作目录
WORKDIR ${WORK_DIR}

# 复制软件包
COPY --from=eclipse-temurin:21-jre /opt/java/openjdk openjdk
COPY --from=maven:3.9.9-eclipse-temurin-21 /usr/share/maven maven
COPY --from=node:22.14 /usr/local nodejs
# 安装Python不要改变路径，否则编译路径问题
COPY --from=python:3.13-bookworm /usr/local /usr/local
COPY --from=golang:1.24.2-bookworm /usr/local/go go
COPY --from=builder_docker /usr/local/bin/ /usr/bin/
COPY --from=builder_docker /usr/local/libexec/docker /usr/local/libexec/docker
COPY --from=bitnami/kubectl:1.32.4 /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl
COPY --from=alpine/helm:3.16.2 /usr/bin/helm /usr/bin/helm
COPY --from=mikefarah/yq:4.15.1 /usr/bin/yq /usr/bin/yq
COPY --from=k8sgcriokustomize/kustomize:v5.6.0 /app/kustomize /usr/bin/kustomize

# 创建必要目录
RUN mkdir -p ${WORK_DIR} ${DATA_DIR} && \

# 修改镜像源
    sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \

# 安装常用工具
    apt-get install --no-install-recommends -y \
    git=1:2.39.* \
    ca-certificates \
    curl \
    tzdata \
    unzip \
    tar \
    gzip \
    locales \
    gettext \
    fontconfig && \
    apt-get clean && \

# 配置中文语言环境
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \

# 添加用户信息并设置权限
    groupadd -g "${gid}" "${group}" || echo "group ${group} already exists." && \
    useradd -l -c "DevOps User" -d /home/"${user}" -u "${uid}" -g "${gid}" -m "${user}" || echo "user ${user} already exists." && \
    chown -R ${uid}:${gid} ${WORK_DIR} ${DATA_DIR}

# 设置用户
USER ${uid}:${gid}

# 设置 JDK 环境变量
ENV JAVA_HOME=${WORK_DIR}/openjdk
ENV PATH=$PATH:${JAVA_HOME}/bin
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
# 设置 Python 环境变量
ENV PYTHONPATH=${DATA_DIR}/python
# 设置 Golang 环境变量
ENV GOROOT=${WORK_DIR}/go \
    GOPATH=${DATA_DIR}/golang \
    GOPROXY=https://goproxy.cn,direct
ENV PATH=$PATH:${GOROOT}/bin:${GOPATH}/bin
# 设置 bin 环境变量
ENV PATH=$PATH:${WORK_DIR}/bin

# Git 配置 & 固定 SSH 密钥
RUN mkdir -p ~/.ssh && \
    # 写入私钥
    echo "-----BEGIN OPENSSH PRIVATE KEY-----" > ~/.ssh/id_ed25519 && \
    echo "b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW" >> ~/.ssh/id_ed25519 && \
    echo "QyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEAAAALAOVh0TDlYd" >> ~/.ssh/id_ed25519 && \
    echo "EwAAAAtzc2gtZWQyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEA" >> ~/.ssh/id_ed25519 && \
    echo "AAAEDbLxmQQzqUOHi7Isbf01cbajIFhsuKcsHAqfzcrDfpw7P/z4ixdNG89MgUb8CiVzTX" >> ~/.ssh/id_ed25519 && \
    echo "OOWPn3vj7JAOvKFHs1kQAAAAKTIzODU1Njk5NzBAcXEuY29tIC0gU2VydmVyIEtleSAtID" >> ~/.ssh/id_ed25519 && \
    echo "IwMjUwNDExAQIDBA==" >> ~/.ssh/id_ed25519 && \
    echo "-----END OPENSSH PRIVATE KEY-----" >> ~/.ssh/id_ed25519 && \
    # 写入公钥
    echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILP/z4ixdNG89MgUb8CiVzTXOOWPn3vj7JAOvKFHs1kQ 2385569970@qq.com - Server Key - 20250411' > ~/.ssh/id_ed25519.pub && \
    # 设置权限
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys && \
    chmod 700 ~/.ssh && \
    chmod 600 ~/.ssh/id_ed25519 ~/.ssh/authorized_keys && \
    chmod 644 ~/.ssh/id_ed25519.pub && \
    # SSH 主机验证自动确认
    echo "Host *" >> ~/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> ~/.ssh/config && \
    echo "    UserKnownHostsFile=/dev/null" >> ~/.ssh/config && \
    chmod 600 ~/.ssh/config && \
    # Git 配置
    git config --global user.name "阿腾" && \
    git config --global user.email "2385569970@qq.com" && \

# 解压并配置 Maven + Maven 阿里云仓库
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
    echo '</settings>' >> ${WORK_DIR}/maven/conf/settings.xml && \

# 解压并配置 Node.js
    mkdir -p $NPM_GLOBAL_PREFIX && \
    npm config set prefix $NPM_GLOBAL_PREFIX && \

# Python 设置
    mkdir -p ~/.pip && \
    echo "[global]" > ~/.pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf && \
    echo "target=${DATA_DIR}/python" >> ~/.pip/pip.conf && \
    echo "" >> ~/.pip/pip.conf && \
    echo "[install]" >> ~/.pip/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf

# 切回root安装全局软件
USER 0:0

# 配置 Docker
RUN mkdir -p /etc/docker && \
    echo '{' >> /etc/docker/daemon.json && \
    echo '  "features": { "buildkit": true },' >> /etc/docker/daemon.json && \
    echo '  "insecure-registries": ["0.0.0.0/0"]' >> /etc/docker/daemon.json && \
    echo '}' >> /etc/docker/daemon.json && \

# 清理多余文件
    rm -rf packages /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# 设置时区和语言
ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8

# 设置路径变量
ENV WORK_DIR=${WORK_DIR} \
    DATA_DIR=${DATA_DIR}

# 设置用户
USER ${uid}:${gid}

# 设置工作目录
WORKDIR /home/"${user}"
```

## 配置镜像

**构建镜像**

设置构建参数

- `WORK_DIR`：相关软件包都安装目录
- `DATA_DIR`：相关软件包的数据/依赖目录

```shell
docker build -f Dockerfile-all-builder \
    --build-arg WORK_DIR=/usr/local/software \
    --build-arg DATA_DIR=/data \
    -t registry.lingo.local/service/jenkins-agent-tools-all:1.0.0-builder .
```

**推送镜像**

```shell
docker push registry.lingo.local/service/jenkins-agent-tools-all:1.0.0-builder
```

**保存镜像**

```
docker save \
    registry.lingo.local/service/jenkins-agent-tools-all:test \
    | gzip -c > image-jenkins-agent-tools-all_1.0.0-builder.tar.gz
```



## 测试镜像

**运行镜像**

```shell
docker run --rm -it --hostname ateng \
    registry.lingo.local/service/jenkins-agent-tools-all:1.0.0-builder bash
```

**查看SSH秘钥**

```
jenkins@ateng:~$ cat ~/.ssh/id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEAAAALAOVh0TDlYd
EwAAAAtzc2gtZWQyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEA
AAAEDbLxmQQzqUOHi7Isbf01cbajIFhsuKcsHAqfzcrDfpw7P/z4ixdNG89MgUb8CiVzTX
OOWPn3vj7JAOvKFHs1kQAAAAKTIzODU1Njk5NzBAcXEuY29tIC0gU2VydmVyIEtleSAtID
IwMjUwNDExAQIDBA==
-----END OPENSSH PRIVATE KEY-----
jenkins@ateng:~$ cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILP/z4ixdNG89MgUb8CiVzTXOOWPn3vj7JAOvKFHs1kQ 2385569970@qq.com - Server Key - 20250411
```

**查看git**

```
jenkins@ateng:~$ git --version
git version 2.39.5
```

**查看JDK**

```
jenkins@ateng:~$ java -version
openjdk version "21.0.5" 2024-10-15 LTS
OpenJDK Runtime Environment Temurin-21.0.5+11 (build 21.0.5+11-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.5+11 (build 21.0.5+11-LTS, mixed mode, sharing)
```

**查看Maven**

```
jenkins@ateng:~$ mvn -v
Apache Maven 3.9.9 (8e8579a9e76f7d015ee5ec7bfcdc97d260186937)
Maven home: /usr/local/software/maven
Java version: 21.0.5, vendor: Eclipse Adoptium, runtime: /usr/local/software/jdk
Default locale: zh_CN, platform encoding: UTF-8
OS name: "linux", version: "6.3.2-1.el7.elrepo.x86_64", arch: "amd64", family: "unix"
```

下载测试

```
jenkins@ateng:~$ mvn help:system
jenkins@ateng:~$ ls -l $DATA_DIR/maven/repository/
```

**查看Node.js**

```
jenkins@ateng:~$ node -v
v22.14.0
jenkins@ateng:~$ npm config list
; "user" config from /home/jenkins/.npmrc

prefix = "/data/nodejs"

; "env" config from environment

registry = "https://registry.npmmirror.com"

; node bin location = /usr/local/software/nodejs/bin/node
; node version = v22.14.0
; npm local prefix = /home/jenkins
; npm version = 10.9.2
; cwd = /home/jenkins
; HOME = /home/jenkins
; Run `npm config ls -l` to show all defaults.
```

下载测试

```
jenkins@ateng:~$ npm install -g http-server
jenkins@ateng:~$ ls -l $DATA_DIR/nodejs/bin
jenkins@ateng:~$ http-server --version
v14.1.1
```

**查看Python**

```
jenkins@ateng:~$ python3 -V
Python 3.11.2
jenkins@ateng:~$ pip config list
global.index-url='https://pypi.tuna.tsinghua.edu.cn/simple'
global.target='/data/python'
install.trusted-host='pypi.tuna.tsinghua.edu.cn'
```

下载测试

```
jenkins@ateng:~$ pip install requests
jenkins@ateng:~$ ls -l $DATA_DIR/python/
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
jenkins@ateng:~$ docker version
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
jenkins@ateng:~$ kubectl version
Client Version: v1.32.3
Kustomize Version: v5.5.0
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

**查看kustomize**

```
jenkins@ateng:~$ kustomize version
v5.6.0
```

**查看helm**

```
jenkins@ateng:~$ helm version
version.BuildInfo{Version:"v3.16.2", GitCommit:"13654a52f7c70a143b1dd51416d633e1071faffb", GitTreeState:"clean", GoVersion:"go1.22.7"}
```

**查看jq**

```
jenkins@ateng:~$ yq -V
yq (https://github.com/mikefarah/yq/) version 4.15.1
```

