# Java应用镜像构建



## 基础镜像构建

Eclipse Temurin 是一个由 Eclipse 基金会支持的开源 Java 运行时环境（JRE）和 Java 开发工具包（JDK）。它提供了一个高性能、可靠的 OpenJDK 构建版本，旨在为开发人员和企业提供一个免费的、符合标准的 Java 发行版。Temurin 的构建遵循 OpenJDK 的规范，并且得到了持续的社区支持和更新。

- [官网链接](https://adoptium.net/zh-CN/temurin/releases/)

### JDK8

**下载JDK**

建议在官方的Web界面下载：[地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jre&version=8)

```shell
wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u432-b06/OpenJDK8U-jre_x64_linux_hotspot_8u432b06.tar.gz
```

**创建Dockerfile**

安装软件包这条命令中，生产环境中建议最小化安装，软件列表：locales curl fontconfig fonts-dejavu-core fonts-liberation

```
cat > Dockerfile-openjdk8 <<"EOF"
FROM debian:12.10
WORKDIR /opt/app

ADD OpenJDK8U-*.tar.gz /opt/

RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y locales curl unzip zip vim net-tools iproute2 iputils-ping less wget jq dnsutils traceroute tcpdump nmap fontconfig fonts-dejavu-core fonts-liberation && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    mv /opt/jdk* /opt/jdk && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER 1001:1001
ENTRYPOINT ["java"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-openjdk8 \
    -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre .
```

**测试镜像**

```shell
docker run --rm \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre \
    -version
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre
```

**保存镜像**

```
docker save \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre \
    | gzip -c > image-java_debian12_temurin_openjdk-jdk-8-jre.tar.gz
```



### JDK11

**下载JDK**

建议在官方的Web界面下载：[地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jre&version=11)

```shell
wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.25%2B9/OpenJDK11U-jre_x64_linux_hotspot_11.0.25_9.tar.gz
```

**创建Dockerfile**

安装软件包这条命令中，生产环境中建议最小化安装，软件列表：locales curl fontconfig fonts-dejavu-core fonts-liberation

```
cat > Dockerfile-openjdk11 <<"EOF"
FROM debian:12.10
WORKDIR /opt/app

ADD OpenJDK11U-*.tar.gz /opt/

RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y locales curl unzip zip vim net-tools iproute2 iputils-ping less wget jq dnsutils traceroute tcpdump nmap fontconfig fonts-dejavu-core fonts-liberation && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    mv /opt/jdk* /opt/jdk && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER 1001:1001
ENTRYPOINT ["java"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-openjdk11 \
    -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-11-jre .
```

**测试镜像**

```shell
docker run --rm \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-11-jre \
    -version
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-11-jre
```

**保存镜像**

```
docker save \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-11-jre \
    | gzip -c > image-java_debian12_temurin_openjdk-jdk-11-jre.tar.gz
```



### JDK17

**下载JDK**

建议在官方的Web界面下载：[地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jre&version=17)

```shell
wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jre_x64_linux_hotspot_17.0.13_11.tar.gz
```

**创建Dockerfile**

安装软件包这条命令中，生产环境中建议最小化安装，软件列表：locales curl fontconfig fonts-dejavu-core fonts-liberation

```
cat > Dockerfile-openjdk17 <<"EOF"
FROM debian:12.10
WORKDIR /opt/app

ADD OpenJDK17U-*.tar.gz /opt/

RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y locales curl unzip zip vim net-tools iproute2 iputils-ping less wget jq dnsutils traceroute tcpdump nmap fontconfig fonts-dejavu-core fonts-liberation && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    mv /opt/jdk* /opt/jdk && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER 1001:1001
ENTRYPOINT ["java"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-openjdk17 \
    -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-17-jre .
```

**测试镜像**

```shell
docker run --rm \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-17-jre \
    -version
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-17-jre
```

**保存镜像**

```
docker save \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-17-jre \
    | gzip -c > image-java_debian12_temurin_openjdk-jdk-17-jre.tar.gz
```



### JDK21

**下载JDK**

建议在官方的Web界面下载：[地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jre&version=21)

```shell
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jre_x64_linux_hotspot_21.0.5_11.tar.gz
```

**创建Dockerfile**

安装软件包这条命令中，生产环境中建议最小化安装，软件列表：locales curl fontconfig fonts-dejavu-core fonts-liberation

```
cat > Dockerfile-openjdk21 <<"EOF"
FROM debian:12.10
WORKDIR /opt/app

ADD OpenJDK21U-*.tar.gz /opt/

RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y locales curl unzip zip vim net-tools iproute2 iputils-ping less wget jq dnsutils traceroute tcpdump nmap fontconfig fonts-dejavu-core fonts-liberation && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    mv /opt/jdk* /opt/jdk && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

USER 1001:1001
ENTRYPOINT ["java"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-openjdk21 \
    -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre .
```

**测试镜像**

```shell
docker run --rm \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre \
    -version
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre
```

**保存镜像**

```
docker save \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre \
    | gzip -c > image-java_debian12_temurin_openjdk-jdk-21-jre.tar.gz
```



## Java应用镜像构建

### 原生镜像

基于 `基础镜像构建` 的镜像直接运行SpringBoot应用程序

**运行应用**

将宿主机的Jar文件映射到容器内部，然后自定义启动参数运行应用

```
docker run --rm --name springboot-demo \
    -p 18080:8080 \
    -v $(pwd)/springboot3-demo-v1.0.jar:/opt/app/app.jar:ro \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre \
    -server \
    -Xms128m -Xmx1024m \
    -jar app.jar \
    --server.port=8080 \
    --spring.profiles.active=prod
```



### 应用和镜像一体-命令

**创建Dockerfile**

```
cat > Dockerfile-app <<"EOF"
FROM registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre
COPY --chown=1001:1001 springboot3-demo-v1.0.jar app.jar
ENTRYPOINT ["java"]
CMD ["-server", "-Xms128m", "-Xmx1024m", "-jar", "app.jar", "--server.port=8080"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-app \
    -t registry.lingo.local/service/java-app-integrated-cmd:debian12_temurin_openjdk-jdk-21-jre .
```

**测试镜像**

自定义启动参数运行应用

```
docker run --rm --name springboot-demo \
    -p 18080:8080 \
    registry.lingo.local/service/java-app-integrated-cmd:debian12_temurin_openjdk-jdk-21-jre \
    -server \
    -Xms128m -Xmx1024m \
    -jar app.jar \
    --server.port=8080 \
    --spring.profiles.active=prod
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java-app-integrated-cmd:debian12_temurin_openjdk-jdk-21-jre
```

**保存镜像**

```
docker save registry.lingo.local/service/java-app-integrated-cmd:debian12_temurin_openjdk-jdk-21-jre \
  | gzip -c > image-java-app-integrated-cmd_debian12_temurin_openjdk-jdk-21-jre.tar.gz
```



### 应用和镜像一体-脚本

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar /opt/app/app.jar}
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

```
cat > Dockerfile-app <<"EOF"
FROM registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre
COPY --chown=1001:1001 docker-entrypoint.sh docker-entrypoint.sh
COPY --chown=1001:1001 springboot3-demo-v1.0.jar app.jar
ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-app \
    -t registry.lingo.local/service/java-app-integrated-shell:debian12_temurin_openjdk-jdk-21-jre .
```

**测试镜像**

自定义启动参数运行应用，分别指定相关参数

```
docker run --rm --name springboot-demo \
    -p 18080:8080 \
    -e JAR_CMD="-jar /opt/app/app.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/java-app-integrated-shell:debian12_temurin_openjdk-jdk-21-jre
```

自定义启动参数运行应用，统一自定义设置

```
docker run --rm --name springboot-demo \
    -p 18080:8080 \
    -e RUN_CMD="java -server -Xms128m -Xmx1024m -jar /opt/app/app.jar --server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/java-app-integrated-shell:debian12_temurin_openjdk-jdk-21-jre
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java-app-integrated-shell:debian12_temurin_openjdk-jdk-21-jre
```

**保存镜像**

```
docker save registry.lingo.local/service/java-app-integrated-shell:debian12_temurin_openjdk-jdk-21-jre \
  | gzip -c > image-java-app-integrated-shell_debian12_temurin_openjdk-jdk-21-jre.tar.gz
```



### 应用和镜像分离

**创建启动脚本**

根据实际情况修改该脚本

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar /opt/app/app.jar}
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

```
cat > Dockerfile-app <<"EOF"
FROM registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre
COPY --chown=1001:1001 docker-entrypoint.sh docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```shell
docker build -f Dockerfile-app \
    -t registry.lingo.local/service/java-app-separate:debian12_temurin_openjdk-jdk-21-jre .
```

**测试镜像**

将宿主机的Jar文件映射到容器内部，然后自定义启动参数运行应用

```
docker run --rm --name springboot-demo \
    -p 18080:8080 \
    -v $(pwd)/springboot3-demo-v1.0.jar:/opt/app/app.jar:ro \
    -e JAR_CMD="-jar /opt/app/app.jar" \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/java-app-separate:debian12_temurin_openjdk-jdk-21-jre
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java-app-separate:debian12_temurin_openjdk-jdk-21-jre
```

**保存镜像**

```
docker save registry.lingo.local/service/java-app-separate:debian12_temurin_openjdk-jdk-21-jre \
  | gzip -c > image-java-app-separate_debian12_temurin_openjdk-jdk-21-jre.tar.gz
```

