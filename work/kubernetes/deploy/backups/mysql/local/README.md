# 备份MySQL数据到本地

编辑参数

```
vi backup-etcd-https-to-local.yaml
## 下列可以选择性修改的属性
## 0. 备份时间schedule，这里是每天0点
## 1. 选择存储数据的节点nodeSelector
## 2. 保存备份的天数BACKUP_SAVE_DAY
## 3. MySQL相关的信息MYSQL_*
```

创建定时备份任务

```
kubectl apply -f backup-mysql-to-local.yaml
```

查看备份的数据

> 连接到**server00.lingo.local**节点，查看备份的数据

```
ll /data/backups/mysql/
```

