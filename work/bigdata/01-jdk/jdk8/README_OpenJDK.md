## 安装OpenJDK8

下载地址

https://adoptium.net/zh-CN/temurin/releases/?os=linux&arch=x64&package=jdk&version=8

解压软件包

```
tar -zxvf OpenJDK8U-jdk_x64_linux_hotspot_8u412b08.tar.gz -C /usr/local/software/
ln -s /usr/local/software/jdk8u412-b08 /usr/local/software/jdk1.8.0
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## JAVA_HOME
export JAVA_HOME=/usr/local/software/jdk1.8.0
export PATH=$PATH:$JAVA_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
java -version
```
