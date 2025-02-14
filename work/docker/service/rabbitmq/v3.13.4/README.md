# RabbitMQ

RabbitMQ 是一个开源的消息中间件，基于 AMQP（高级消息队列协议）协议，提供可靠的消息传递、异步处理和分布式系统的解耦。它支持多种消息传输模式，如点对点、发布/订阅等，适用于分布式应用程序、微服务架构和高并发环境。RabbitMQ 提供了高可用性、消息确认、死信队列等功能，广泛应用于数据交换和任务调度。

- [官网链接](https://www.rabbitmq.com/)

**下载镜像**

```
docker pull bitnami/rabbitmq:3.13.4
```

**下载插件（可选）**

如果不安装插件可以跳过此步骤。

将下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。

```
mkdir plugins
wget -P plugins https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v3.13.0/rabbitmq_delayed_message_exchange-3.13.0.ez
```

**推送到仓库**

```
docker tag bitnami/rabbitmq:3.13.4 registry.lingo.local/bitnami/rabbitmq:3.13.4
docker push registry.lingo.local/bitnami/rabbitmq:3.13.4
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/rabbitmq:3.13.4 | gzip -c > image-rabbitmq_3.13.4.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/rabbitmq/data
sudo chown -R 1001 /data/container/rabbitmq
```

**运行服务**

普通模式

```
docker run -d --name ateng-rabbitmq \
  -p 20009:5672 -p 20010:15672 --restart=always \
  -v /data/container/rabbitmq/data:/bitnami/rabbitmq/mnesia \
  -e RABBITMQ_USERNAME=admin \
  -e RABBITMQ_PASSWORD=Admin@123 \
  -e RABBITMQ_MANAGEMENT_ALLOW_WEB_ACCESS=true \
  -e RABBITMQ_ERL_COOKIE=u8B1rlnzSckNvtkNr7kRAU4NVt8F6OtU \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/rabbitmq:3.13.4
```

插件模式

```
docker run -d --name ateng-rabbitmq \
  -p 20009:5672 -p 20010:15672 --restart=always \
  -v /data/container/rabbitmq/data:/bitnami/rabbitmq/mnesia \
  -e RABBITMQ_USERNAME=admin \
  -e RABBITMQ_PASSWORD=Admin@123 \
  -e RABBITMQ_MANAGEMENT_ALLOW_WEB_ACCESS=true \
  -e RABBITMQ_PLUGINS="rabbitmq_management, rabbitmq_web_stomp, rabbitmq_auth_backend_ldap, rabbitmq_delayed_message_exchange" \
  -e RABBITMQ_COMMUNITY_PLUGINS="http://miniserve.lingo.local/rabbitmq-plugins/rabbitmq_delayed_message_exchange-3.13.0.ez" \
  -e RABBITMQ_ERL_COOKIE=u8B1rlnzSckNvtkNr7kRAU4NVt8F6OtU \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/rabbitmq:3.13.4
```

**查看日志**

```
docker logs -f ateng-rabbitmq
```

**使用服务**

```
AMQP URL: 192.168.1.114:20009
Web URL: http://192.168.1.114:20010/
Username: admin
Password: Admin@123
```

**删除服务**

停止服务

```
docker stop ateng-rabbitmq
```

删除服务

```
docker rm ateng-rabbitmq
```

删除目录

```
sudo rm -rf /data/container/rabbitmq
```

