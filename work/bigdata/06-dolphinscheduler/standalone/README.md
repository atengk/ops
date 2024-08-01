# 安装DolphinScheduler

> Apache DolphinScheduler 是一个分布式易扩展的可视化DAG工作流任务调度开源系统。适用于企业级场景，提供了一个可视化操作任务、工作流和全生命周期数据处理过程的解决方案。
>
> https://dolphinscheduler.apache.org/zh-cn/docs/3.2.0/guide/installation/standalone
>

文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述             |
| ------------- | --------- | ---------------- |
| 192.168.1.131 | bigdata01 | StandaloneServer |

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



## 使用服务

启动服务

```
$DS_HOME/bin/dolphinscheduler-daemon.sh start standalone-server
```

访问服务

```
URL: http://192.168.1.109:12345/dolphinscheduler/ui
Username: admin
Password: dolphinscheduler123
```

