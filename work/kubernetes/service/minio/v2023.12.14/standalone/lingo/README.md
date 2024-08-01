# 创建MinIO

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install minio -n lingo-bigdata -f values.yaml minio-12.10.10.tgz
```

查看服务

```shell
kubectl get -n lingo-bigdata pod,svc,pvc -l app.kubernetes.io/instance=minio
kubectl logs -f -n lingo-bigdata -l app.kubernetes.io/instance=minio
```

使用服务

```
URL: http://192.168.1.19:48887/
Username: admin
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n lingo-bigdata minio
```

