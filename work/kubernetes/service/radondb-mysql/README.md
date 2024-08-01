# RadonDB MySQL



## 安装Operator

安装

```
helm install radondb-mysql-operator -n radondb --create-namespace -f values-operator.yaml mysql-operator-v3.0.0.tgz
```

查看

```
kubectl get pod,svc -n radondb
kubectl get crd | grep mysql.radondb.com
```



## 安装MySQL Cluster

安装

```
kubectl apply -n kongyu -f mysql-cluster.yaml
```

查看信息

> RadonDB MySQL 提供 leader 服务和 follower 服务用于分别访问主从节点。leader 服务始终指向主节点（读写），follower 服务始终指向从节点（只读）。

```
kubectl get -n kongyu pod,svc,pvc
```

查看集群

```
kubectl get mysqlclusters -A
```

访问服务

```
kubectl exec -it -n kongyu cluster-mysql-0 -c mysql -- mysql -hcluster-leader -ukongyu -pAdmin@123
```



## 创建用户

创建用户

> 创建了一个普通用户**normal_user**和管理员**super_user**

```
kubectl apply -n kongyu -f mysql-user.yaml
```

查看用户

```
kubectl get -n kongyu mysqluser -o wide  
```

登录用户

```
kubectl exec -it -n kongyu cluster-mysql-0 -c mysql -- mysql -hcluster-leader -usuper_user -pAdmin@123
```



## S3备份

创建Secret

```
kubectl create secret generic mysql-backup-secret \
  --from-literal=s3-endpoint=http://dev.minio.lingo.local \
  --from-literal=s3-access-key=admin \
  --from-literal=s3-secret-key=Admin@123 \
  --from-literal=s3-bucket=mysql-backups \
  --namespace=kongyu
```

将 Secret 配置到 Operator 集群

>  将备份 Secret 名称添加到 mysql cluster 中

```
spec:
  replicas: 3
  backupSecretName: mysql-backup-secret
  ...
```

重新应用mysql cluster

```
kubectl apply -n kongyu -f mysql-cluster-backup.yaml
```

启动备份

```
kubectl apply -n kongyu -f mysql-backup.yaml
```

查看备份

```
kubectl get -n kongyu backups.mysql.radondb.com -o wide
```



## 删除

删除用户

```
kubectl delete -n kongyu mysqluser normal-user super-user
```

删除备份

```
kubectl delete -n kongyu -f mysql-backup.yaml
```

删除MySQL Cluster

```
kubectl delete -n kongyu -f mysql-cluster.yaml
```

删除Operator

```
helm uninstall radondb-mysql-operator -n radondb
kubectl delete ns radondb
```

删除自定义资源

```
kubectl delete customresourcedefinitions.apiextensions.k8s.io mysqlclusters.mysql.radondb.com
kubectl delete customresourcedefinitions.apiextensions.k8s.io mysqlusers.mysql.radondb.com
kubectl delete customresourcedefinitions.apiextensions.k8s.io backups.mysql.radondb.com
```

