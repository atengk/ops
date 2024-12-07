# OpenJDK

Eclipse Temurin 是一个由 Eclipse 基金会支持的开源 Java 运行时环境（JRE）和 Java 开发工具包（JDK）。它提供了一个高性能、可靠的 OpenJDK 构建版本，旨在为开发人员和企业提供一个免费的、符合标准的 Java 发行版。Temurin 的构建遵循 OpenJDK 的规范，并且得到了持续的社区支持和更新。

- [官网链接](https://adoptium.net/zh-CN/temurin/releases/)



## 下载软件包

**下载JDK**

建议在官方的Web界面下载：[地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jre&version=8)

```shell
wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u432-b06/OpenJDK8U-jre_x64_linux_hotspot_8u432b06.tar.gz
```

**下级基础镜像**

```shell
docker pull debian:12.8
```



## 开发环境镜像

开发环境安装了很多软件包，方便开发时调试，其他配置都是相同的

**构建镜像**

```shell
docker build -f Dockerfile-dev -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev .
```

**测试镜像**

```shell
docker run --rm registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev
```



## 生产环境镜像

**构建镜像**

```shell
docker build -f Dockerfile-prod -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre .
```

**测试镜像**

```shell
docker run --rm registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre
```



## 保存镜像

将以上构建的镜像保存到本地

```shell
docker save \
  registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev \
  registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre \
  | gzip -c > images_java-debian12_temurin_openjdk-jdk-8-jre.tar.gz
```



