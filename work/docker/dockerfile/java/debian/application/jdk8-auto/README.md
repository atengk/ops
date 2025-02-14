## SpringBoot应用

使用Dockerfile构建SpringBoot应用，使用 **JAVA_OPTS** 环境变量设置 JVM 参数，使用 **SPRING_OPTS** 环境变量设置 Spring Boot 运行参数，使用 **JAR_FILE** 指定 JAR 文件，详情见 `docker-entrypoint.sh` 文件。



**构建镜像**

```shell
docker build -t registry.lingo.local/service/java:debian-openjdk8-springboot2 .
```

**测试镜像**

创建目录

```
sudo mkdir -p /data/container/java/springboot2-demo
sudo chown -R 1001:1001 /data/container/java/springboot2-demo
```

拷贝Jar文件

```
cp springboot2-demo-v1.0.jar /data/container/java/springboot2-demo 
```

运行测试

```shell
docker run --name ateng-springboot2-demo \
  --rm -p 8888:8888 \
  -v /data/container/java/springboot2-demo/springboot2-demo-v1.0.jar:/opt/app/springboot2-demo-v1.0.jar:ro \
  -e JAVA_OPTS="-XX:+UseG1GC -server -Xms128m -Xmx1024m -jar" \
  -e SPRING_OPTS="--server.port=8888" \
  -e JAR_FILE="/opt/app/springboot2-demo-v1.0.jar" \
  registry.lingo.local/service/java:debian-openjdk8-springboot2
```

**推送镜像**

```shell
docker push registry.lingo.local/service/java:debian-openjdk8-springboot2
```

**保存镜像**

```
docker save registry.lingo.local/service/java:debian-openjdk8-springboot2 \
  | gzip -c > image-java_debian-openjdk8-springboot2.tar.gz
```

