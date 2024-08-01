# 安装备份工具velero

https://velero.io/docs/v1.11/basic-install/

下载软件包

```
wget https://github.com/vmware-tanzu/velero/releases/download/v1.14.0/velero-v1.14.0-linux-amd64.tar.gz
wget https://github.com/vmware-tanzu/helm-charts/releases/download/velero-7.1.4/velero-7.1.4.tgz
```

解压安装软件包

```
tar -zxvf velero-v1.14.0-linux-amd64.tar.gz
cp velero-v1.14.0-linux-amd64/velero /usr/local/bin
rm -rf velero-v1.14.0-linux-amd64/
velero completion bash > /etc/bash_completion.d/velero
source <(velero completion bash)
```

编辑配置文件

```
## MinIO的地址s3Url
vi +56 values-velero-minio.yaml
## MinIO的账号密码credentials
vi +80 values-velero-minio.yaml
## MinIO的桶名bucket，请提前创建好
vi +45 values-velero-minio.yaml
```

镜像说明

> 将镜像上传到Harbor仓库

```
docker load -i images-velero_v1.14.0.tar.gz
```

使用helm创建

```
helm install velero -n velero --create-namespace -f values-velero-minio.yaml velero-7.1.4.tgz
```

查看velero

```
kubectl get -n velero pod,svc,bsl
```

备份命名空间

```
velero schedule create ns-kongyu-backup --schedule "0 13 * * *" --include-namespaces kongyu --default-volumes-to-fs-backup
velero backup create --from-schedule ns-kongyu-backup
```

查看备份

```
kubectl logs -f -n velero deploy/velero
velero backup get
```

![image-20240801220013016](./assets/image-20240801220013016.png ':size=40%')

备份恢复

```
velero restore create --from-backup test
velero restore get
```

备份恢复到其他命名空间

```
velero restore create --from-backup ns-lingo-service-dev-20231106001032 --namespace-mappings lingo-service-dev:kongyu-service02
```

