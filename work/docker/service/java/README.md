# Java应用

使用Docker运行Java应用

- [构建镜像](/work/docker/dockerfile/java/)



## 原生镜像

**创建目录**

```
sudo mkdir -p /data/container/java/springboot3-demo
sudo chown -R 1001:1001 /data/container/java/springboot3-demo
```

**拷贝Jar文件**

```
cp springboot3-demo-v1.0.jar /data/container/java/springboot3-demo 
```

**运行容器**

```shell
docker run -d --restart=always \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -v /data/container/java/springboot3-demo/springboot3-demo-v1.0.jar:/opt/app/app.jar:ro \
    registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre \
    -server \
    -Xms128m -Xmx1024m \
    -jar app.jar \
    --server.port=8080 \
    --spring.profiles.active=prod
```

**查看日志**

```
docker logs -f ateng-springboot3-demo
```

**使用服务**

```
Address: 192.168.1.12:18080
```

**删除服务**

停止服务

```
docker stop ateng-springboot3-demo
```

删除服务

```
docker rm ateng-springboot3-demo
```

删除目录

```
sudo rm -rf /data/container/java/springboot3-demo
```



## 应用和镜像一体

**创建目录**

```
sudo mkdir -p /data/container/java/springboot3-demo
sudo chown -R 1001:1001 /data/container/java/springboot3-demo
```

**运行容器**

```shell
docker run -d --restart=always \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m -jar /opt/app/app.jar" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/java-app-integrated:debian12_temurin_openjdk-jdk-21-jre
```

**查看日志**

```
docker logs -f ateng-springboot3-demo
```

**使用服务**

```
Address: 192.168.1.12:18080
```

**删除服务**

停止服务

```
docker stop ateng-springboot3-demo
```

删除服务

```
docker rm ateng-springboot3-demo
```

删除目录

```
sudo rm -rf /data/container/java/springboot3-demo
```



## 应用和镜像分离

**创建目录**

```
sudo mkdir -p /data/container/java/springboot3-demo
sudo chown -R 1001:1001 /data/container/java/springboot3-demo
```

**拷贝Jar文件**

```
cp springboot3-demo-v1.0.jar /data/container/java/springboot3-demo 
```

**运行容器**

```shell
docker run -d --restart=always \
    --name ateng-springboot3-demo \
    -p 18080:8080 \
    -v /data/container/java/springboot3-demo/springboot3-demo-v1.0.jar:/opt/app/app.jar:ro \
    -e JAVA_OPTS="-server -Xms128m -Xmx1024m -jar /opt/app/app.jar" \
    -e SPRING_OPTS="--server.port=8080 --spring.profiles.active=prod" \
    registry.lingo.local/service/java-app-separate:debian12_temurin_openjdk-jdk-21-jre
```

**查看日志**

```
docker logs -f ateng-springboot3-demo
```

**使用服务**

```
Address: 192.168.1.12:18080
```

**删除服务**

停止服务

```
docker stop ateng-springboot3-demo
```

删除服务

```
docker rm ateng-springboot3-demo
```

删除目录

```
sudo rm -rf /data/container/java/springboot3-demo
```

