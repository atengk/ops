## 构建镜像

```shell
docker build -t registry.lingo.local/service/app:springboot2-demo-openjdk8-debian .
```



## 测试镜像

```shell
docker run --rm -p 8888:8888 registry.lingo.local/service/app:springboot2-demo-openjdk8-debian
```



## 推送镜像

```shell
docker push registry.lingo.local/service/app:springboot2-demo-openjdk8-debian
```

