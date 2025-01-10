# DolphinScheduler

DolphinScheduler 是一个开源的分布式工作流调度系统，专为数据处理和任务调度设计。支持 DAG 可视化任务编排，具备强大的任务依赖管理、高可用性和扩展性。它易于集成，支持多种任务类型，适合大规模数据工程和复杂工作流场景。

- [官网安装文档](https://dolphinscheduler.apache.org/zh-cn/docs/3.2.2/guide/installation/standalone)



文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述             |
| ------------- | --------- | ---------------- |
| 192.168.1.131 | bigdata01 | StandaloneServer |



## 基础配置

**下载软件包**

```
wget https://archive.apache.org/dist/dolphinscheduler/3.2.2/apache-dolphinscheduler-3.2.2-bin.tar.gz
```

**解压软件包**

```
tar -zxvf apache-dolphinscheduler-3.2.2-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-dolphinscheduler-3.2.2-bin /usr/local/software/dolphinscheduler
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## DS_HOME
export DS_HOME=/usr/local/software/dolphinscheduler
export PATH=$PATH:$DS_HOME/bin
EOF
source ~/.bash_profile
```



## 启动服务

**编辑启动环境**

设置JDK和运行参数

```
tee -a $DS_HOME/bin/env/dolphinscheduler_env.sh <<"EOF"
export JAVA_HOME=/usr/local/software/jdk8
export JAVA_OPTS="-Xms1g -Xmx1g"
EOF
```

**启动服务**

```
$DS_HOME/bin/dolphinscheduler-daemon.sh start standalone-server
```

**查看日志**

```
tail -f  $DS_HOME/standalone-server/logs/dolphinscheduler-standalone.log
```

**访问服务**

```
URL: http://192.168.1.109:12345/dolphinscheduler/ui
Username: admin
Password: dolphinscheduler123
```

**停止服务**

```
$DS_HOME/bin/dolphinscheduler-daemon.sh stop standalone-server
```



## 服务自启

**编辑配置文件**

```
sudo tee /etc/systemd/system/dolphinscheduler.service <<"EOF"
[Unit]
Description=DolphinScheduler
Documentation=https://dolphinscheduler.apache.org/zh-cn
After=network.target
[Service]
Type=forking
Environment="SPARK_HOME=/usr/local/software/spark"
WorkingDirectory=/usr/local/software/dolphinscheduler
ExecStart=/usr/local/software/dolphinscheduler/bin/dolphinscheduler-daemon.sh start standalone-server
ExecStop=/usr/local/software/dolphinscheduler/bin/dolphinscheduler-daemon.sh stop standalone-serverorg.apache.spark.deploy.worker.Worker 1
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable dolphinscheduler.service
sudo systemctl start dolphinscheduler.service
sudo systemctl status dolphinscheduler.service
```
