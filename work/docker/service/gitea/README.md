# gitea 1.20.5



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/gitea/data
chown -R 1001 /data/service/gitea
```



## 启动容器

gitea需要postgresql数据库，首先创建数据库

```
docker run -it --rm --network kongyu --env PGPASSWORD=Admin@123 registry.lingo.local/service/postgresql:15.3.0 psql --host kongyu-postgresql -U postgres -d kongyu -p 5432 -c "CREATE DATABASE gitea;"
```

- 使用docker run的方式


```
docker run -d --name kongyu-gitea --network kongyu \
  -p 20002:3000 --restart=always \
  -v /data/service/gitea/data:/bitnami/gitea \
  -e GITEA_ADMIN_USER=root \
  -e GITEA_ADMIN_PASSWORD=Admin@123 \
  -e GITEA_ADMIN_EMAIL=2385569970@qq.com \
  -e GITEA_DATABASE_HOST=kongyu-postgresql \
  -e GITEA_DATABASE_NAME=gitea \
  -e GITEA_DATABASE_USERNAME=postgres \
  -e GITEA_DATABASE_PASSWORD=Admin@123 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/gitea:1.20.5_bitnami
docker logs -f kongyu-gitea
```

- 使用docker-compose的方式


```
cat > /data/service/gitea/docker-compose.yaml <<"EOF"
version: '3'

services:
  gitea:
    image: registry.lingo.local/service/gitea:1.20.5_bitnami
    container_name: kongyu-gitea
    depends_on:
      - kongyu-postgresql
    networks:
      - kongyu
    ports:
      - "20002:3000"
    restart: always
    volumes:
      - /data/service/gitea/data:/bitnami/gitea
    environment:
      - GITEA_ADMIN_USER=root
      - GITEA_ADMIN_PASSWORD=Admin@123
      - GITEA_ADMIN_EMAIL=2385569970@qq.com
      - GITEA_DATABASE_HOST=kongyu-postgresql
      - GITEA_DATABASE_NAME=gitea
      - GITEA_DATABASE_USERNAME=postgres
      - GITEA_DATABASE_PASSWORD=Admin@123
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/gitea/docker-compose.yaml up -d 
docker-compose -f /data/service/gitea/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
http://192.168.1.101:20002/user/login
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-gitea
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/gitea/docker-compose.yaml down
```

删除数据

```
rm -rf /data/service/gitea
docker run -it --rm --network kongyu --env PGPASSWORD=Admin@123 registry.lingo.local/service/postgresql:15.3.0 psql --host kongyu-postgresql -U postgres -d kongyu -p 5432 -c "DROP DATABASE gitea;"
```

