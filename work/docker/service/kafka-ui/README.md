# Kafka UI

用于管理 Apache Kafka® 集群的多功能、快速且轻量级的 Web UI。

- [官网链接](https://github.com/provectus/kafka-ui)

**下载镜像**

```
docker pull provectuslabs/kafka-ui:v0.7.2
```

**推送到仓库**

```
docker tag provectuslabs/kafka-ui:v0.7.2 registry.lingo.local/service/kafka-ui:v0.7.2
docker push registry.lingo.local/service/kafka-ui:v0.7.2
```

**保存镜像**

```
docker save registry.lingo.local/service/kafka-ui:v0.7.2 | gzip -c > image-kafka-ui_v0.7.2.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/kafka-ui/config
```

**创建配置文件**

```
sudo tee /data/container/kafka-ui/config/dynamic_config.yaml <<"EOF"
kafka:
  clusters:
  - bootstrapServers: 192.168.1.114:20004
    name: local-kafka
EOF
sudo chown 100 -R /data/container/kafka-ui/config
```

**运行服务**

```
docker run -d --name ateng-kafka-ui \
  -p 20005:8080 --restart=always \
  -v /data/container/kafka-ui/config/dynamic_config.yaml:/etc/kafkaui/dynamic_config.yaml:rw\
  -e DYNAMIC_CONFIG_ENABLED=true \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/kafka-ui:v0.7.2
```

**查看日志**

```
docker logs -f ateng-kafka-ui
```

**使用服务**

```
URL: http://192.168.1.114:20005
```

**删除服务**

停止服务

```
docker stop ateng-kafka-ui
```

删除服务

```
docker rm ateng-kafka-ui
```

删除目录

```
sudo rm -rf /data/container/kafka-ui
```

