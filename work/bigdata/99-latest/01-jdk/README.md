## OpenJDK8

OpenJDK 8是一个开源的Java开发工具包（JDK），由Oracle主导开发并发布。它实现了Java SE 8规范，包括Java编程语言的核心功能和标准库。OpenJDK 8引入了许多重要的新特性，如Lambda表达式、流（Streams）API、默认方法等，极大地提升了Java的函数式编程能力和开发效率。作为Java的官方参考实现，OpenJDK 8广泛应用于各种Java开发项目中，支持跨平台开发。

Temurin OpenJDK 8是一个由Adoptium（前身为AdoptOpenJDK）维护的开源JDK实现，基于OpenJDK 8标准。它提供了一个高性能、可靠的Java开发和运行环境，适用于多种操作系统，包括Windows、Linux和macOS。Temurin旨在为Java应用提供稳定的支持，同时确保安全性、兼容性和长期维护，是企业和开发者常用的Java平台之一。

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
