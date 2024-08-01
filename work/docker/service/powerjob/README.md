# PowerJob

> [官方文档](http://www.powerjob.tech/)



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```



## 启动容器

创建数据库并导入SQL

```
powerjob-mysql.sql
```

启动服务


```
docker run -d \
    --restart=always \
    --name kongyu-powerjob-server \
    -p 7700:7700 -p 10086:10086 -p 10010:10010 \
    -e TZ="Asia/Shanghai" \
    -e JVMOPTIONS="-Xmx512m -Xms256m" \
    -e PARAMS="--spring.profiles.active=product --spring.datasource.core.jdbc-url=jdbc:mysql://192.168.1.10:35725/ateng_powerjob?useUnicode=true&characterEncoding=UTF-8 --spring.datasource.core.username=root --spring.datasource.core.password=Admin@123 --oms.mongodb.enable=false" \
       registry.lingo.local/service/powerjob-server:4.3.6
docker logs -f kongyu-powerjob-server
```



## 访问服务

登录服务查看

```
URL: http://192.168.1.12:7700/
```



## 删除服务

删除容器


```
docker rm -f kongyu-powerjob-server
```

