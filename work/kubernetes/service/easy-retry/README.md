# 安装Easy Retry

创建数据库并导入SQL

```
easy_retry_mysql.sql
```

创建服务

```
kubectl apply -n kongyu -f deploy.yaml
```

查看服务

```
kubectl get -n kongyu pod,svc -l app=powerjob-server
kubectl logs -f -n kongyu deploy/powerjob-server
```

使用服务

```
URL: http://192.168.1.10:32781/easy-retry/
Username: admin
Password: admin
```

删除服务以及数据

```
kubectl delete -n kongyu -f deploy.yaml
```

