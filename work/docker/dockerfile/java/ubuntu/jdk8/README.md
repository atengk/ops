## 构建镜像

```shell
docker build -t registry.lingo.local/service/java:ubuntu24_temurin_openjdk-jdk8-jre .
```



## 测试镜像

```shell
docker run --rm registry.lingo.local/service/java:ubuntu24_temurin_openjdk-jdk8-jre
```



## 推送镜像

```shell
docker push registry.lingo.local/service/java:ubuntu24_temurin_openjdk-jdk8-jre
```

