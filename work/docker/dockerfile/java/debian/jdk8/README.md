# 生产环境镜像

构建镜像

```shell
docker build -f Dockerfile -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre .
```

测试镜像

```shell
docker run --rm registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre
```

推送镜像

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre
```



# 开发环境镜像

构建镜像

```shell
docker build -f Dockerfile-dev -t registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev .
```

测试镜像

```shell
docker run --rm registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev
```

推送镜像

```shell
docker push registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre_dev
```

