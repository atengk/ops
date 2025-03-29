# Docker使用文档





## 镜像多阶段构建

以 Springboot 项目为例，构建镜像

**下载项目**

https://start.spring.io/

![image-20250324151013072](./assets/image-20250324151013072.png)

**解压软件包**

```
unzip spring-demo.zip
```

**编辑Dockerfile**

```
FROM maven:3.9.6 AS builder
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

