## 构建镜像

```shell
docker build -t registry.lingo.local/service/app:spring-native-debian .
```



## 测试镜像

```shell
docker run --rm registry.lingo.local/service/app:spring-native-debian
```



## 推送镜像

```shell
docker push registry.lingo.local/service/app:spring-native-debian
```

