# RabbitMQ 3.11.2



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/rabbitmq/data
chown -R 1001 /data/service/rabbitmq
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-rabbitmq --network kongyu \
    -p 20001:5672 -p 20002:15672 --restart=always \
    -v /data/service/rabbitmq/data:/bitnami/rabbitmq/mnesia \
    -e RABBITMQ_VHOST=/ \
    -e RABBITMQ_USERNAME=admin \
    -e RABBITMQ_PASSWORD=Admin@123 \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/rabbitmq:3.11.2
docker logs -f kongyu-rabbitmq
```

- 使用docker-compose的方式


```
cat > /data/service/rabbitmq/docker-compose.yaml <<"EOF"
version: '3'

services:
  rabbitmq:
    image: registry.lingo.local/service/rabbitmq:3.11.2
    container_name: kongyu-rabbitmq
    networks:
      - kongyu
    ports:
      - "20001:5672"
      - "20002:15672"
    restart: always
    volumes:
      - /data/service/rabbitmq/data:/bitnami/rabbitmq/mnesia
    environment:
      - RABBITMQ_VHOST=/
      - RABBITMQ_USERNAME=admin
      - RABBITMQ_PASSWORD=Admin@123
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/rabbitmq/docker-compose.yaml up -d 
docker-compose -f /data/service/rabbitmq/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
URL: http://192.168.1.101:20002/
Username: admin
Password: Admin@123
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-rabbitmq
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/rabbitmq/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/rabbitmq
```

