# PostgreSQL 15.3.0



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/postgresql/data
chown -R 1001 /data/service/postgresql
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-postgresql --network kongyu \
  -p 20001:5432 --restart=always \
  -v /data/service/postgresql/data:/bitnami/postgresql \
  -e POSTGRESQL_POSTGRES_PASSWORD=Admin@123 \
  -e POSTGRESQL_USERNAME=kongyu \
  -e POSTGRESQL_PASSWORD=kongyu \
  -e POSTGRESQL_DATABASE=kongyu \
  -e POSTGRESQL_TIMEZONE=Asia/Shanghai \
  -e POSTGRESQL_LOG_TIMEZONE=Asia/Shanghai \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/postgresql:15.3.0
docker logs -f kongyu-postgresql
```

- 使用docker-compose的方式


```
cat > /data/service/postgresql/docker-compose.yaml <<"EOF"
version: '3'

services:
  postgresql:
    image: registry.lingo.local/service/postgresql:15.3.0
    container_name: kongyu-postgresql
    networks:
      - kongyu
    ports:
      - "20001:5432"
    restart: always
    volumes:
      - /data/service/postgresql/data:/bitnami/postgresql
    environment:
      - POSTGRESQL_POSTGRES_PASSWORD=Admin@123
      - POSTGRESQL_USERNAME=kongyu
      - POSTGRESQL_PASSWORD=kongyu
      - POSTGRESQL_DATABASE=kongyu
      - POSTGRESQL_TIMEZONE=Asia/Shanghai
      - POSTGRESQL_LOG_TIMEZONE=Asia/Shanghai
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/postgresql/docker-compose.yaml up -d 
docker-compose -f /data/service/postgresql/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
docker run -it --rm --network kongyu --env PGPASSWORD=Admin@123 registry.lingo.local/service/postgresql:15.3.0 psql --host kongyu-postgresql -U postgres -d kongyu -p 5432 -c "\l"
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-postgresql
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/postgresql/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/postgresql
```

