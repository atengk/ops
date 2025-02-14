## SpringBoot应用

使用Docker运行SpringBoot应用，动态指定运行参数和Jar文件。使用 **JAVA_OPTS** 环境变量设置 JVM 参数，使用 **SPRING_OPTS** 环境变量设置 Spring Boot 运行参数，使用 **JAR_FILE** 指定 JAR 文件。构建镜像部分参考：[构建镜像](/work/docker/dockerfile/java/debian/application/jdk8-auto/)



**创建目录**

```
sudo mkdir -p /data/container/java/springboot2-demo
sudo chown -R 1001:1001 /data/container/java/springboot2-demo
```

**拷贝Jar文件**

```
cp springboot2-demo-v1.0.jar /data/container/java/springboot2-demo 
```

**运行容器**

```shell
docker run -d --name ateng-springboot2-demo \
  -p 8888:8888 --restart=always \
  -v /data/container/java/springboot2-demo/springboot2-demo-v1.0.jar:/opt/app/springboot2-demo-v1.0.jar:ro \
  -e JAVA_OPTS="-XX:+UseG1GC -server -Xms128m -Xmx1024m -jar" \
  -e SPRING_OPTS="--server.port=8888" \
  -e JAR_FILE="/opt/app/springboot2-demo-v1.0.jar" \
  registry.lingo.local/service/java:debian-openjdk8-springboot2
```

**查看日志**

```
docker logs -f ateng-springboot2-demo
```

**使用服务**

```
Address: 192.168.1.12:8888
```

**删除服务**

停止服务

```
docker stop ateng-springboot2-demo
```

删除服务

```
docker rm ateng-springboot2-demo
```

删除目录

```
sudo rm -rf /data/container/java/springboot2-demo
```
