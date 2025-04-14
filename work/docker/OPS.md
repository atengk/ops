# Docker使用文档



## 镜像多阶段构建

### Springboot

**下载项目**

访问 https://start.spring.io/ 网站填写相关参数下载Springboot源码。也可以通过这里设置好的参数直接下载：[链接](https://start.spring.io/starter.zip?type=maven-project&language=java&bootVersion=3.4.4&baseDir=springboot-demo&groupId=local.ateng.demo&artifactId=springboot-demo&name=springboot-demo&description=Demo project for Spring Boot&packageName=local.ateng.demo.springboot-demo&packaging=jar&javaVersion=21&dependencies=web)

**解压软件包**

```
unzip spring-demo.zip
```

**编辑Dockerfile**

```
FROM maven:3.9.9 AS builder
WORKDIR /app
COPY spring-demo/ spring-demo/
RUN cd spring-demo && \
    mvn clean package -DskipTests=true

FROM eclipse-temurin:21
WORKDIR /app
COPY --from=builder /app/target/spring-demo-0.0.1-SNAPSHOT.jar .
CMD ["java", "-jar", "/app/target/spring-demo-0.0.1-SNAPSHOT.jar"]
```

**构建镜像**

```
docker build -t ateng-spring:demo .
```

