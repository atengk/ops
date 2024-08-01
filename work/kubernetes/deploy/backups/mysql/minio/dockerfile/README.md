# 备份MySQL镜像

## 构建镜像

```shell
docker build -t registry.lingo.local/service/mysql:backup_to_minio_v8 .
```

## 测试镜像

```
docker run --rm registry.lingo.local/service/mysql:backup_to_minio_v8
```

## 推送镜像

```shell
docker push registry.lingo.local/service/mysql:backup_to_minio_v8
```

