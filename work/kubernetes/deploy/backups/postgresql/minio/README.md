# 备份MySQL数据到MinIO

编辑参数

```
vi backup-etcd-https-to-local.yaml
## 下列可以选择性修改的属性
## 0. 备份时间schedule，这里是每天0点
## 1. 保存备份的天数BACKUP_SAVE_DAY
## 2. MySQL相关的信息MYSQL_*
## 3. MinIO相关的信息MINIO_SERVER_*
```

创建定时备份任务

```
kubectl apply -f backup-mysql-to-minio.yaml
```

查看备份的数据

> 查看**MinIO**备份的数据，例如：

```
mcli ls minio/service-backups/mysql
```

