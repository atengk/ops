# OpenJDK21

Eclipse Temurin 是一个由 Eclipse 基金会支持的开源 Java 运行时环境（JRE）和 Java 开发工具包（JDK）。它提供了一个高性能、可靠的 OpenJDK 构建版本，旨在为开发人员和企业提供一个免费的、符合标准的 Java 发行版。Temurin 的构建遵循 OpenJDK 的规范，并且得到了持续的社区支持和更新。

OpenJDK 21 是 Java 平台的开源实现，符合 Java SE 21 规范，作为长期支持 (LTS) 版本推出。它引入了许多新特性和改进，包括虚拟线程 (Project Loom)、记录模式和switch的模式匹配（标准化）、范围内的方法句柄，以及改进的垃圾收集器。OpenJDK 21 提供更高效、更灵活的工具支持，是现代 Java 开发的重要版本。

- [官网地址](https://adoptium.net/zh-CN/)



**下载软件包**

- [下载地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=aarch64&package=jdk&version=21)

**解压软件包**

```
tar -zxvf OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.5_11.tar.gz -C /usr/local/software/
ln -s /usr/local/software/jdk-21.0.5+11 /usr/local/software/jdk21
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## JAVA_HOME
export JAVA_HOME=/usr/local/software/jdk21
export PATH=$PATH:$JAVA_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
java -version
```
