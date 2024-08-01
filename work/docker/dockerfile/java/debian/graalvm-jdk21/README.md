## 构建镜像

```shell
docker build -t registry.lingo.local/service/java:debian12_graalvm_openjdk-jdk-21 .
```



## 测试镜像

```shell
docker run --rm registry.lingo.local/service/java:debian12_graalvm_openjdk-jdk-21
```



## 推送镜像

```shell
docker push registry.lingo.local/service/java:debian12_graalvm_openjdk-jdk-21
```

