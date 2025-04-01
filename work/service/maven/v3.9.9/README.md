# Apache Maven

Apache Maven 是一个基于 POM（Project Object Model）项目对象模型的构建管理工具，主要用于 Java 项目。它提供依赖管理、构建自动化和项目生命周期管理，简化开发流程。Maven 采用统一的依赖管理机制，通过中央仓库下载依赖，确保项目一致性。其插件体系强大，支持编译、测试、打包、部署等任务，提高开发效率。

- [官网链接](https://maven.apache.org/)
- [下载地址](https://maven.apache.org/download.cgi)
- [Maven仓库](https://central.sonatype.com/search)



**下载软件包**

```
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
```

**解压软件包**

```
tar -zxvf apache-maven-3.9.9-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-maven-3.9.9 /usr/local/software/maven
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## MAVEN_HOME
export MAVEN_HOME=/usr/local/software/maven
export PATH=$PATH:$MAVEN_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
mvn --version
```

**配置本地仓库地址**

编辑 `vi /usr/local/software/maven/conf/settings.xml` 配置文件修改以下内容

```xml
  <localRepository>/data/download/maven/repository/</localRepository>
```

创建目录

```
sudo mkdir -p /data/download/maven
sudo chown -R admin:ateng  /data/download/maven
```

**配置国内镜像源**

编辑 `vi /usr/local/software/maven/conf/settings.xml` 配置文件修改以下内容

```xml
  <mirrors>
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
```

**使用命令**

使用命令获取系统环境信息，并测试镜像源和本地仓库地址是否配置正确

```
mvn help:system
```

