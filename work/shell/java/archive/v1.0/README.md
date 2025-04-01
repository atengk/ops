# Shell脚本管理Java应用



## 启动应用

将脚本 `spring-app.sh`（可以自定义名称） 和应用程序 `spring-app.jar` （根据实际而定，脚本会自动找到当前目录下的Jar包：*.jar）放在同一目录下。

```shell
chmod +x spring-app.sh
./spring-app.sh start
```



## 高级配置

如果需要定义Java&Spring的启动参数、日志、健康监测、优雅关闭等，可以参考高级配置

### 自定义配置

**设置java路径**

```shell
export JAVA_HOME=/usr/local/software/jdk21
```

**设置应用程序全路径**

```shell
export SPRINGBOOT_JAR_PATH="/data/service/application/spring-app.jar"
```

**设置JVM参数**

```shell
export JVM_OPTS="-server -Xms512m -Xmx1024m"
```

**设置Spring Boot应用参数**

```shell
export SPRING_OPTS="--spring.profiles.active=prod"
```

**日志功能**

启用日志功能

```shell
export LOG_ENABLED=true
```

设置清理日志保留的日期

```shell
export LOG_RETENTION_DAYS=7
```

**健康监测**

选择以下一种方式：

不设置健康检查

```shell
export HEALTH_CHECK_METHOD=none
```

日志检查关键字

```shell
export HEALTH_CHECK_METHOD=log
export LOG_KEYWORD="JVM running for"
```

TCP端口检查

```shell
export HEALTH_CHECK_METHOD=tcp
export HEALTH_CHECK_TCP_PORT=8888
```

URL检查

```shell
export HEALTH_CHECK_METHOD=url
export HEALTH_CHECK_URL="http://localhost:8888/actuator/health"
```

**优雅关闭**

等待程序自动退出最大时间（秒）

```shell
export GRACEFUL_SHUTDOWN_TIMEOUT=60
```

### 重启服务

以上自定义配置后重启服务生效

```shell
./spring-app.sh restart
```

### 开机自启

相关路径和文件请自行修改并调试

**编辑环境变量配置文件**

必填的参数：Jar应用的路径

> 注意这样使用的事 cat > xx <<EOF EOF的方式，目的是将当前用户的环境变量`$PATH`写入该配置文件中

```shell
cat > /data/service/application/spring-app.env <<EOF
# 必填
SPRINGBOOT_JAR_PATH="/data/service/application/spring-app.jar"
# 选填
JAVA_HOME=/usr/local/software/jdk21
JVM_OPTS="-server -Xms512m -Xmx4096m"
SPRING_OPTS="--spring.profiles.active=prod"
LOG_ENABLED="false"
LOG_RETENTION_DAYS=7
HEALTH_CHECK_METHOD="none"
LOG_KEYWORD="JVM running for"
HEALTH_CHECK_TCP_PORT=8888
HEALTH_CHECK_URL="http://localhost:8888/actuator/health"
GRACEFUL_SHUTDOWN_TIMEOUT=60
PATH=$PATH
EOF
```

**编辑systemd配置文件**

```shell
sudo tee /etc/systemd/system/spring-app.service <<"EOF"
[Unit]
Description=My Spring Boot Application Manager
After=network.target
[Service]
Type=forking
User=admin
Group=ateng
PrivateTmp=true
WorkingDirectory=/data/service/application
EnvironmentFile=-/data/service/application/spring-app.env
ExecStartPre=/data/service/application/spring-app.sh status
ExecStart=/data/service/application/spring-app.sh start
ExecStop=/data/service/application/spring-app.sh stop
Restart=on-failure
RestartSec=30
TimeoutStartSec=90
TimeoutStopSec=120
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```shell
sudo systemctl daemon-reload
sudo systemctl enable --now spring-app
```

**查看状态**

```shell
sudo journalctl -f -u spring-app
sudo systemctl status spring-app
```

