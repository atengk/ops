# Java应用镜像构建

## Debian

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



## Rocky

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



## CentOS

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



## Alpine

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

