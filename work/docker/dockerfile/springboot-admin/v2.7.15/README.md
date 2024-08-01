## 构建镜像

```shell
docker build -t registry.lingo.local/service/springboot-admin:2.7.15 .
```



## 测试镜像

```shell
docker run --rm registry.lingo.local/service/springboot-admin:2.7.15
```



## 推送镜像

```shell
docker push registry.lingo.local/service/springboot-admin:2.7.15
```

