# 安装postgresql

查看版本

```
helm search repo bitnami/postgresql -l
```

下载chart

```
helm pull bitnami/postgresql --version 15.5.14
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/postgresql="true"
```

创建服务

```shell
helm install postgresql -n kongyu -f values.yaml postgresql-15.5.14.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=postgresql
kubectl logs -f -n kongyu postgresql-0
```

使用服务

```
kubectl run postgresql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/postgresql:16.3.0 --namespace kongyu --env="PGPASSWORD=Admin@123" --command -- psql --host postgresql -U postgres -d postgres -p 5432
## 查看所有配置
\l
SELECT name, setting FROM pg_settings;
```

删除服务以及数据

```
helm uninstall -n kongyu postgresql
kubectl delete -n kongyu pvc data-postgresql-0
```

