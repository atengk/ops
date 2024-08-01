# 备份ETCD镜像

## 构建镜像

```shell
docker build -t registry.lingo.local/service/etcd:backup_to_local_v3.5.1 .
```

## 测试镜像

```
docker run --rm registry.lingo.local/service/etcd:backup_to_local_v3.5.1
```

## 推送镜像

```shell
docker push registry.lingo.local/service/etcd:backup_to_local_v3.5.1
```

