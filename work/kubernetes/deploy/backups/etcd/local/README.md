# 备份etcd https的数据到本地

上传证书

> 将etcd的客户端证书上传到命名空间下

```
kubectl create -n kongyu secret generic etcd-certs \
  --from-file=ssl/ca.pem \
  --from-file=ssl/etcd-client-key.pem \
  --from-file=ssl/etcd-client.pem
```

编辑参数

```
vi backup-etcd-https-to-local.yaml
## 下列可以选择性修改的属性
## 0. 备份时间schedule，这里是每天0点
## 1. 选择存储数据的节点nodeSelector
## 2. 保存备份的天数BACKUP_SAVE_DAY
## 3. etcd的其中一个节点ETCDCTL_ENDPOINTS
## 4. 如果证书名称不一致，可以修改成相应的名称 
```

创建定时备份任务

```
kubectl apply -f backup-etcd-https-to-local.yaml
```

查看备份的数据

> 连接到**server00.lingo.local**节点，查看备份的数据

```
ll /data/backups/etcd/
```
