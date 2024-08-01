## 构建镜像

```shell
docker build -t registry.lingo.local/service/builder-devops-kongyu:jdk21 .
```

## 测试镜像

```shell
docker run --rm registry.lingo.local/service/builder-devops-kongyu:jdk21
```

## 推送镜像

```shell
docker push registry.lingo.local/service/builder-devops-kongyu:jdk21
```





