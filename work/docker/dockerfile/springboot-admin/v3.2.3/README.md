## 构建镜像

```shell
docker build -t registry.lingo.local/service/springboot-admin:3.2.3 .
```



## 测试镜像

```shell
docker run --rm registry.lingo.local/service/springboot-admin:3.2.3
```



## 推送镜像

```shell
docker push registry.lingo.local/service/springboot-admin:3.2.3
```

