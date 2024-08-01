## 构建镜像

```shell
docker build -t registry.lingo.local/service/app:springboot2-demo-openjdk21-debian .
```



## 测试镜像

```shell
docker run --rm registry.lingo.local/service/app:springboot2-demo-openjdk21-debian
```



## 推送镜像

```shell
docker push registry.lingo.local/service/app:springboot2-demo-openjdk21-debian
```

