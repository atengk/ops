# kkFileView

kkFileView为文件文档在线预览解决方案，该项目使用流行的spring boot搭建，易上手和部署，基本支持主流办公文档的在线预览，如doc,docx,xls,xlsx,ppt,pptx,pdf,txt,zip,rar,图片,视频,音频等等

- [官网链接](https://www.kkview.cn/zh-cn/index.html)



**下载源码包**

从以下链接下载源码包

- https://gitee.com/kekingcn/file-online-preview/releases/tag/v4.4.0

**解压源码**

```
export KK_VERSION=4.4.0
tar -zxvf file-online-preview-v${KK_VERSION}.tar.gz
```

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
    maven:3.9-eclipse-temurin-8 \
    mvn clean package -DskipTests \
    -s settings.xml \
    -f file-online-preview-v4.4.0/server/pom.xml
```

**整理文件**

```
mv file-online-preview-v${KK_VERSION}/server/target/kkFileView-${KK_VERSION}.tar.gz .
rm -rf file-online-preview-v${KK_VERSION}/
```

**创建启动脚本**

```shell
cat > docker-entrypoint.sh <<"EOF"
#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar bin/kkFileView-4.4.0.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.config.location=config/application.properties}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
EOF
chmod +x docker-entrypoint.sh
```

**创建 Dockerfile**

```dockerfile
cat > Dockerfile <<"EOF"
FROM linuxserver/libreoffice:7.6.7

ARG KK_VERSION=4.4.0
ARG WORK_DIR=/opt/kkFileView-${KK_VERSION}

WORKDIR ${WORK_DIR}

ADD kkFileView-${KK_VERSION}.tar.gz /tmp
COPY docker-entrypoint.sh .

RUN set -eux && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        tzdata \
        curl \
        ca-certificates \
        fontconfig \
        font-noto-cjk \
        su-exec \
        shadow \
        bash \
        icu-data-full && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    mv /tmp/kkFileView-${KK_VERSION}/* . && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENV KKFILEVIEW_BIN_FOLDER=${WORK_DIR}/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

EXPOSE 8012
ENTRYPOINT ["./docker-entrypoint.sh"]
EOF
```

**构建镜像**

```
docker build -t registry.lingo.local/service/kkfileview:v4.4.0-alpine-7.6.7 .
```

**运行测试**

使用默认启动命令

```
docker run --rm --name kkfileview \
    -p 18012:8012 \
    registry.lingo.local/service/kkfileview:v4.4.0-alpine-7.6.7
```

自定义启动命令

```
docker run --rm --name kkfileview \
    -p 18012:8012 \
    -e JAR_CMD="-jar bin/kkFileView-4.4.0.jar" \
    -e JAVA_OPTS="-Xms1024m -Xmx1024m" \
    -e SPRING_OPTS="--spring.config.location=config/application.properties" \
    registry.lingo.local/service/kkfileview:v4.4.0-alpine-7.6.7
```

**推送镜像到仓库**

```
docker push registry.lingo.local/service/kkfileview:v4.4.0-alpine-7.6.7
```

**保存镜像**

```
docker save registry.lingo.local/service/kkfileview:v4.4.0-alpine-7.6.7 |
    gzip -c > image-kkfileview_v4.4.0-alpine-7.6.7.tar.gz
```

