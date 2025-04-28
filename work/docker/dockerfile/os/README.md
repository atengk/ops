# 基于不同的操作系统构建容器应用

## Debian

Debian 是一个由全球开发者社区共同维护的自由开源操作系统，以稳定、安全和高质量著称。它支持多种硬件架构，拥有超过 5 万个预编译的软件包，适用于服务器、桌面和嵌入式设备。Debian 的开发过程注重透明、开放与协作，强调自由软件理念，是众多其他 Linux 发行版（如 Ubuntu）的基础。其稳定版更新周期较长，适合对系统可靠性有高要求的场景。
 官网：https://www.debian.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-debian <<"EOF"
FROM debian:12.10

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y locales tzdata curl ca-certificates fontconfig fonts-noto-cjk && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-debian \
    -t registry.lingo.local/service/springboot3-demo:v1.0-debian .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-debian
```



## Ubuntu

Ubuntu 是基于 Debian 的 Linux 发行版，由 Canonical 公司开发与维护，旨在提供一个简洁易用、功能齐全的操作系统。它适用于桌面、服务器、云计算和物联网等多种应用场景。Ubuntu 拥有庞大的用户社区和活跃的更新节奏，每六个月发布一次版本，每两年发布一个长期支持版（LTS）。其友好的界面和丰富的软件资源使其成为最受欢迎的 Linux 系统之一。
 官网：https://ubuntu.com/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-ubuntu <<"EOF"
FROM ubuntu:25.04

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN sed -i "s#http://.*ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#g" /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y locales tzdata curl ca-certificates fontconfig fonts-noto-cjk && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-ubuntu \
    -t registry.lingo.local/service/springboot3-demo:v1.0-ubuntu .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-ubuntu
```



## Rocky Linux

Rocky Linux 是一个开源企业级 Linux 发行版，由原 CentOS 联合创始人 Gregory Kurtzer 发起，旨在作为 RHEL（Red Hat Enterprise Linux）完全兼容的替代品。Rocky Linux 致力于稳定性与长期支持，主要服务对象是企业和数据中心用户。自 CentOS 结束传统稳定版本支持后，Rocky 成为了众多企业和个人寻找 RHEL 兼容系统时的重要选择。
 官网：https://rockylinux.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-rockylinux <<"EOF"
FROM rockylinux/rockylinux:9.5

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN dnf -y install epel-release && \
    dnf -y update && \
    dnf -y install glibc-langpack-zh tzdata ca-certificates fontconfig google-noto-sans-cjk-ttc-fonts && \
    dnf clean all && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-rockylinux \
    -t registry.lingo.local/service/springboot3-demo:v1.0-rockylinux .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-rockylinux
```



## OpenEuler

openEuler 是由华为主导并开源的企业级 Linux 发行版，专注于云计算、边缘计算和多样化计算场景。openEuler 支持多种 CPU 架构（如 x86_64 和 ARM64），致力于打造开放、创新、共赢的操作系统生态。它结合了安全性、高可用性和高性能特性，广泛应用于金融、电信、能源等关键行业，是中国本土化自主操作系统建设的重要代表。
 官网：https://openeuler.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-openeuler <<"EOF"
FROM openeuler/openeuler:24.03

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN dnf -y update && \
    dnf -y install shadow-utils glibc-locale-source glibc-langpack-zh tzdata ca-certificates fontconfig google-noto-sans-cjk-ttc-fonts && \
    dnf clean all && \
    localedef --no-archive -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-openeuler \
    -t registry.lingo.local/service/springboot3-demo:v1.0-openeuler .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-openeuler
```



## OpenAnolis

OpenAnolis（龙蜥）是由阿里巴巴发起并面向社区开源的企业级 Linux 发行版，基于云原生、大数据、AI 等新技术趋势设计。OpenAnolis 兼容 RHEL 生态，注重稳定性和高性能，面向大规模服务器和多云环境优化。它具有完善的软件生态和开源社区，积极推动国产基础软件生态发展，也是 CentOS 替代方案之一。
 官网：https://openanolis.cn/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-openanolis <<"EOF"
FROM registry.openanolis.cn/openanolis/anolisos:23.2

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN dnf -y update && \
    dnf -y install shadow-utils glibc-locale-source glibc-langpack-zh tzdata ca-certificates fontconfig google-noto-sans-cjk-ttc-fonts && \
    dnf clean all && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-openanolis \
    -t registry.lingo.local/service/springboot3-demo:v1.0-openanolis .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-openanolis
```



## AlmaLinux

AlmaLinux 是由 CloudLinux 公司发起，交由 AlmaLinux OS Foundation 维护的开源企业级操作系统。它完全兼容 RHEL，旨在为 CentOS 用户提供一个免费的、长期支持的替代方案。AlmaLinux 社区活跃，承诺对系统提供十年以上的持续安全更新，适合企业、数据中心和开发环境部署。它强调中立性和社区治理，不受单一公司控制。
 官网：https://almalinux.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-almalinux <<"EOF"
FROM almalinux:9.5

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=${UID}:${GID} /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/*.repo && \
    sed -i 's|^# baseurl=http.*/almalinux/|baseurl=https://mirrors.aliyun.com/almalinux/|g' /etc/yum.repos.d/*.repo && \
    dnf -y install epel-release && \
    dnf -y update && \
    dnf -y install \
        glibc-langpack-zh \
        tzdata \
        ca-certificates \
        fontconfig \
        google-noto-sans-cjk-ttc-fonts && \
    dnf clean all && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-almalinux \
    -t registry.lingo.local/service/springboot3-demo:v1.0-almalinux .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-almalinux
```



## CentOS

CentOS（Community ENTerprise Operating System）是一个基于 RHEL 源码构建的开源 Linux 发行版，广泛应用于服务器和企业环境。CentOS 以高稳定性和长期支持闻名，但自 2021 年起，CentOS Linux 逐步转型为 CentOS Stream，成为 RHEL 未来版本的滚动更新预览版，这一变化促使 Rocky Linux 和 AlmaLinux 等项目迅速兴起。
 官网：https://www.centos.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-centos <<"EOF"
FROM centos:centos8

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN rm -f /etc/yum.repos.d/*.repo && \
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo && \
    dnf clean all && dnf makecache && \
    dnf install -y epel-release && \
    dnf -y install glibc-locale-source glibc-langpack-zh tzdata ca-certificates fontconfig google-noto-sans-cjk-ttc-fonts && \
    dnf clean all && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8  && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-centos \
    -t registry.lingo.local/service/springboot3-demo:v1.0-centos .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-centos
```



## Alpine Linux

Alpine Linux 是一个轻量级、安全性高的 Linux 发行版，设计之初就以资源占用小和启动速度快为目标。它采用 musl libc 和 busybox，整体体积非常小，适合嵌入式系统、容器环境（如 Docker）及微服务架构。Alpine 默认启用更严格的安全策略，并且软件包管理器（apk）简洁高效，是许多云计算场景下首选的 Linux 发行版。
 官网：https://alpinelinux.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21-jdk-alpine eclipse-temurin:21-jre-alpine
- eclipse-temurin:17-jdk-alpine eclipse-temurin:17-jre-alpine
- eclipse-temurin:11-jdk-alpine eclipse-temurin:11-jre-alpine
- eclipse-temurin:8-jdk-alpine eclipse-temurin:8-jre-alpine

```
cat > Dockerfile-alpine <<"EOF"
FROM alpine:3.21

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21-jdk-alpine --chown=${UID}:${GID} /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN set -eux && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        tzdata \
        curl \
        ca-certificates \
        font-noto-cjk \
        su-exec \
        shadow \
        bash \
        icu-data-full && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-alpine \
    -t registry.lingo.local/service/springboot3-demo:v1.0-alpine .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-alpine
```



## Fedora

Fedora 是由 Red Hat 赞助、社区主导开发的 Linux 发行版，以集成最新开源技术、推动创新而闻名。它是许多新技术（如 systemd、Wayland、Flatpak）的测试和推广平台，常常走在 Linux 发展的前沿。Fedora 更新周期短（大约每六个月一个新版本），适合喜欢尝试新特性的开发者和技术爱好者。它也是 RHEL 的上游发行版之一。
 官网：https://getfedora.org/

### 编译打包（可选）

如果需要将源码编译打包Jar文件，可以参考该步骤。一般情况下是直接提供了Jar文件的，所以该步骤可选

**创建maven配置文件**

```
cat > settings.xml <<"EOF"
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <mirrorOf>central</mirrorOf>
      <id>alimaven</id>
      <name>阿里云中央仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
```

**编译打包**

```shell
docker run --rm \
    --cpus="2" \
    -m="2g" \
    -v "/data/download/maven/repository":/root/.m2 \
    -v "$PWD":/app \
    -w /app \
    maven:3.9-eclipse-temurin-21 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f pom.xml
```

### 构建镜像

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar springboot3-demo-v1.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建Dockerfile**

其中 `COPY --from=eclipse-temurin:21 --chown=1001:1001 /opt/java/openjdk /opt/jdk` 可以根据实际情况修改JDK版本，以下JDK镜像版本参考

- eclipse-temurin:21 eclipse-temurin:21-jre
- eclipse-temurin:17 eclipse-temurin:17-jre
- eclipse-temurin:11 eclipse-temurin:11-jre
- eclipse-temurin:8 eclipse-temurin:8-jre

```
cat > Dockerfile-fedora <<"EOF"
FROM fedora:42

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG WORK_DIR=/opt/app

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:21 --chown=${UID}:${GID} /opt/java/openjdk /opt/jdk
COPY --chown=${UID}:${GID} docker-entrypoint.sh .
COPY --chown=${UID}:${GID} springboot3-demo-v1.0.jar .

RUN sed -i 's|^metalink=|#metalink=|g' /etc/yum.repos.d/*.repo && \
    sed -i 's|^#baseurl=http.*/pub/fedora/linux/|baseurl=https://mirrors.aliyun.com/fedora/|g' /etc/yum.repos.d/*.repo && \
    dnf -y update && \
    dnf -y install \
        glibc-langpack-zh \
        tzdata \
        ca-certificates \
        fontconfig \
        google-noto-sans-cjk-ttc-fonts && \
    dnf clean all && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER ${UID}:${GID}

ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -f Dockerfile-fedora \
    -t registry.lingo.local/service/springboot3-demo:v1.0-fedora .
```

### 运行镜像

**运行测试**

```
docker run --rm \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar springboot3-demo-v1.0.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/springboot3-demo:v1.0-fedora
```

