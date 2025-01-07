## OpenJDK8

Eclipse Temurin 是一个由 Eclipse 基金会支持的开源 Java 运行时环境（JRE）和 Java 开发工具包（JDK）。它提供了一个高性能、可靠的 OpenJDK 构建版本，旨在为开发人员和企业提供一个免费的、符合标准的 Java 发行版。Temurin 的构建遵循 OpenJDK 的规范，并且得到了持续的社区支持和更新。

OpenJDK 8 是 Java 平台的开源实现，符合 Java SE 8 规范。它包括 Java 虚拟机 (JVM)、类库和 Java 编译器，支持 Lambdas、Stream API 和新日期时间 API 等功能。OpenJDK 是 Oracle JDK 的基础，广泛用于开发和部署 Java 应用。

- [官网地址](https://adoptium.net/zh-CN/)



**下载软件包**

- [下载地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jdk&version=8)

**解压软件包**

```bash
tar -zxvf OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz -C /usr/local/software/
ln -s /usr/local/software/jdk8u432-b06 /usr/local/software/jdk8
```

**配置环境变量**

```bash
cat >> ~/.bash_profile <<"EOF"
## JAVA_HOME
export JAVA_HOME=/usr/local/software/jdk8
export PATH=$PATH:$JAVA_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```bash
$ java -version
openjdk version "1.8.0_432"
OpenJDK Runtime Environment (Temurin)(build 1.8.0_432-b06)
OpenJDK 64-Bit Server VM (Temurin)(build 25.432-b06, mixed mode)
```
