# 安装DolphinScheduler

> Apache DolphinScheduler 是一个分布式易扩展的可视化DAG工作流任务调度开源系统。适用于企业级场景，提供了一个可视化操作任务、工作流和全生命周期数据处理过程的解决方案。
>
> https://dolphinscheduler.apache.org/zh-cn/docs/3.2.0/guide/installation/pseudo-cluster
>
> https://dolphinscheduler.apache.org/zh-cn/docs/3.2.0/guide/installation/cluster

文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                        |
| ------------- | --------- | --------------------------- |
| 192.168.1.131 | bigdata01 | master、worker、apiServer   |
| 192.168.1.132 | bigdata02 | master、worker、alertServer |
| 192.168.1.133 | bigdata03 | master、worker              |

## 基础环境配置

解压软件包

```
tar -zxvf apache-dolphinscheduler-3.2.0-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-dolphinscheduler-3.2.0-bin /usr/local/software/dolphinscheduler
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## DS_HOME
export DS_HOME=/usr/local/software/dolphinscheduler
export PATH=$PATH:$DS_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```

```



## 准备启动环境

安装进程树分析工具

```
sudo yum -y install psmisc
```

准备zookeeper

```
bigdata01:2181,bigdata02:2181,bigdata03:2181
```

mysql创建数据库

> 数据源配置：https://github.com/apache/dolphinscheduler/blob/3.2.0-release/docs/docs/zh/guide/howto/datasource-setting.md

```
DolphinScheduler 元数据存储在关系型数据库中，故需创建相应的数据库和用户。
（1）创建数据库
mysql> CREATE DATABASE lingo_dolphinscheduler; 
（2）创建用户
mysql> CREATE USER 'dolphinscheduler'@'%' IDENTIFIED BY 
'dolphinscheduler';
（3）赋予用户相应权限
mysql> GRANT ALL PRIVILEGES ON lingo_dolphinscheduler.* TO 
'dolphinscheduler'@'%';
mysql> flush privileges;
```

配置数据库驱动

> 移动到 DolphinScheduler 的每个模块的 libs 目录下，其中包括 `api-server/libs` 和 `alert-server/libs` 和 `master-server/libs` 和 `worker-server/libs`。

```
cd $DS_HOME
cp ~/bigdata/mysql-connector-j-8.0.33.jar alert-server/libs/ 
cp ~/bigdata/mysql-connector-j-8.0.33.jar api-server/libs/ 
cp ~/bigdata/mysql-connector-j-8.0.33.jar master-server/libs/ 
cp ~/bigdata/mysql-connector-j-8.0.33.jar worker-server/libs/ 
cp ~/bigdata/mysql-connector-j-8.0.33.jar tools/libs/
```

初始化数据库

```
bash $DS_HOME/tools/bin/upgrade-schema.sh
```



## 配置一键部署脚本

修改 install_env.sh 文件

```
$ vi $DS_HOME/bin/env/install_env.sh
$ egrep -v "^$|^#" $DS_HOME/bin/env/install_env.sh
ips=bigdata01,bigdata02,bigdata03
sshPort=22
masters=bigdata01
workers=bigdata01:default,bigdata02:default,bigdata03:default
alertServer=bigdata02
apiServers=bigdata01
installPath=/tmp/dolphinscheduler
deployUser=admin
zkRoot=/dolphinscheduler
```

修改 dolphinscheduler_env.sh 文件

```
vi $DS_HOME/bin/env/dolphinscheduler_env.sh
$ egrep -v "^$|^#" $DS_HOME/bin/env/dolphinscheduler_env.sh
export JAVA_HOME=/usr/local/software/jdk1.8.0
export DATABASE=mysql
export SPRING_PROFILES_ACTIVE=${DATABASE}
export SPRING_DATASOURCE_URL="jdbc:mysql://192.168.1.10:35725/lingo_dolphinscheduler"
export SPRING_DATASOURCE_USERNAME=dolphinscheduler
export SPRING_DATASOURCE_PASSWORD=dolphinscheduler
export SPRING_CACHE_TYPE=${SPRING_CACHE_TYPE:-none}
export SPRING_JACKSON_TIME_ZONE=${SPRING_JACKSON_TIME_ZONE:-UTC}
export MASTER_FETCH_COMMAND_NUM=${MASTER_FETCH_COMMAND_NUM:-10}
export REGISTRY_TYPE=zookeeper
export REGISTRY_ZOOKEEPER_CONNECT_STRING=bigdata01:2181,bigdata02:2181,bigdata03:2181
export HADOOP_HOME=/usr/local/software/hadoop
export HADOOP_CONF_DIR=/usr/local/software/hadoop/etc/hadoop
export SPARK_HOME=${SPARK_HOME:-/opt/soft/spark}
export PYTHON_LAUNCHER=${PYTHON_LAUNCHER:-/opt/soft/python}
export HIVE_HOME=${HIVE_HOME:-/opt/soft/hive}
export FLINK_HOME=${FLINK_HOME:-/opt/soft/flink}
export DATAX_LAUNCHER=${DATAX_LAUNCHER:-/opt/soft/datax/bin/python3}
export PATH=$HADOOP_HOME/bin:$SPARK_HOME/bin:$PYTHON_LAUNCHER:$JAVA_HOME/bin:$HIVE_HOME/bin:$FLINK_HOME/bin:$DATAX_LAUNCHER:$PATH
```

创建临时目录

> 所有节点都需要创建

```
mkdir -p /tmp/dolphinscheduler/
```



## 启动服务

使用上面配置的部署用户**admin**运行以下命令完成部署，部署后的运行日志将存放在 logs 文件夹内

```
[admin@bigdata01 dolphinscheduler]$ $DS_HOME/bin/install.sh
```



## 使用服务

访问服务

```
URL: http://192.168.1.131:12345/dolphinscheduler/ui
Username: admin
Password: dolphinscheduler123
```



## 启停服务

```
cd $DS_HOME

# 一键停止集群所有服务
bash ./bin/stop-all.sh

# 一键开启集群所有服务
bash ./bin/start-all.sh

# 启停 Master
bash ./bin/dolphinscheduler-daemon.sh stop master-server
bash ./bin/dolphinscheduler-daemon.sh start master-server

# 启停 Worker
bash ./bin/dolphinscheduler-daemon.sh start worker-server
bash ./bin/dolphinscheduler-daemon.sh stop worker-server

# 启停 Api
bash ./bin/dolphinscheduler-daemon.sh start api-server
bash ./bin/dolphinscheduler-daemon.sh stop api-server

# 启停 Alert
bash ./bin/dolphinscheduler-daemon.sh start alert-server
bash ./bin/dolphinscheduler-daemon.sh stop alert-server
```

