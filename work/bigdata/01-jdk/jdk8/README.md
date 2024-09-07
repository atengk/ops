## 安装JDK1.8

解压软件包

```
tar -zxvf jdk-8u391-linux-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/jdk1.8.0_391 /usr/local/software/jdk1.8.0
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
