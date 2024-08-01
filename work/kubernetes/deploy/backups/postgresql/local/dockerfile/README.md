# 备份PostgreSQL镜像

## 构建镜像

```shell
docker build -t registry.lingo.local/service/postgresql:backup_to_local_v16 .
```

## 测试镜像

```
docker run --rm registry.lingo.local/service/postgresql:backup_to_local_v16
```

## 推送镜像

```shell
docker push registry.lingo.local/service/postgresql:backup_to_local_v16
```

