# 安装备份工具velero

编辑配置文件

```
vi +60 values-velero-minio.yaml
## MinIO的地址s3Url
## MinIO的账号密码credentials
## MinIO的桶名bucket，请提前创建好
```

镜像说明

> 将镜像上传到Harbor仓库

```
docker load -i image-velero-1.9.0.tar.gz
```

使用helm创建

```
helm install velero -n velero --create-namespace -f values-velero-minio.yaml velero-2.30.0.tgz
```

安装velero软件包

```
tar -zxvf velero-v1.8.1-binary.tar.gz -C /usr/bin
## 配置命令自动补全
velero completion bash > /etc/bash_completion.d/velero
source <(velero completion bash)
```

查看velero

```
kubectl get -n velero pod,svc,bsl
```

备份命名空间

```
velero schedule create ns-kongyu-backup --schedule "0 13 * * *" --include-namespaces kongyu --default-volumes-to-restic
velero backup create --from-schedule ns-kongyu-backup
```

