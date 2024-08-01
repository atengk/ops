# 安装Gitea

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

> 需要在外部的PostgreSQL创建gitea数据库

```shell
helm install gitea -n kongyu -f values.yaml gitea-1.2.9.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=gitea
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=gitea
```

使用服务

```
URL: http://192.168.1.10:40366/
Username: root
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n kongyu gitea
```

