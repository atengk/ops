## 安装OpenJDK21

解压软件包

```
tar -zxvf OpenJDK21U-jdk_x64_linux_hotspot_21.0.4_7.tar.gz -C /usr/local/software/
ln -s /usr/local/software/jdk-21.0.4+7 /usr/local/software/jdk21
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## JAVA_HOME
export JAVA_HOME=/usr/local/software/jdk21
export PATH=$PATH:$JAVA_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
java -version
```
