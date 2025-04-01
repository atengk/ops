# OpenJDK17

Eclipse Temurin 是一个由 Eclipse 基金会支持的开源 Java 运行时环境（JRE）和 Java 开发工具包（JDK）。它提供了一个高性能、可靠的 OpenJDK 构建版本，旨在为开发人员和企业提供一个免费的、符合标准的 Java 发行版。Temurin 的构建遵循 OpenJDK 的规范，并且得到了持续的社区支持和更新。

OpenJDK 17 是 Java 平台的开源实现，符合 Java SE 17 规范。作为长期支持 (LTS) 版本，它引入了新特性如 sealed 类、模式匹配的 switch 预览，以及强封装的 JDK 内部 API。OpenJDK 17 提高了性能、安全性和开发效率，是现代 Java 应用开发的稳定基础。

- [官网地址](https://adoptium.net/zh-CN/)



**下载软件包**

- [下载地址](https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jdk&version=17)

**解压软件包**

```
tar -zxvf OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz -C /usr/local/software/
ln -s /usr/local/software/jdk-17.0.13+11 /usr/local/software/jdk17
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## JAVA_HOME
export JAVA_HOME=/usr/local/software/jdk17
export PATH=$PATH:$JAVA_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
java -version
```
