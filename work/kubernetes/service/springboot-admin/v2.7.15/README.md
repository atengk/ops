# 安装SpringBoot Admin

创建服务

```
kubectl apply -n kongyu -f deploy.yaml
```

查看服务

```
kubectl get -n kongyu pod,svc -l app=springboot-admin
kubectl logs -f -n kongyu deploy/springboot-admin
```

使用服务

```
URL: http://192.168.1.10:34646/admin/
Username: admin
Password: Admin@123
```

删除服务以及数据

```
kubectl delete -n kongyu -f deploy.yaml
```

