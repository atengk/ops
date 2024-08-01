# 创建MinIO

查看版本

```
helm search repo bitnami/minio -l
```

下载chart

```
helm pull bitnami/minio --version 14.6.22
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install minio -n kongyu -f values.yaml minio-14.6.22.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=minio
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=minio
```

使用服务

```
URL: http://192.168.1.19:19683/
Username: admin
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n kongyu minio
```

