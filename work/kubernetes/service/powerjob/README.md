# 安装PowerJob Server

创建数据库并导入SQL

```
powerjob-mysql.sql
```

创建服务

> JVMOPTIONS参数中的地址端口请修改为Service暴露后的地址后端口

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
URL: http://192.168.1.10:41889/
```

删除服务以及数据

```
kubectl delete -n kongyu -f deploy.yaml
```

