# 安装postgresql

查看版本

```
helm search repo bitnami/postgresql-ha -l
```

下载chart

```
helm pull bitnami/postgresql-ha --version 14.2.11
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install postgresql -n kongyu -f values.yaml postgresql-ha-14.2.11.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=postgresql
kubectl logs -f -n kongyu postgresql-postgresql-0
```

使用服务

```
kubectl run postgresql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/postgresql-repmgr:16.3.0 --namespace kongyu --env="PGPASSWORD=Admin@123" --command -- psql --host postgresql-pgpool -U postgres -d postgres -p 5432
## 查看所有配置
SELECT name, setting FROM pg_settings
## 查看主从
SELECT * FROM pg_stat_replication;
```

删除服务以及数据

```
helm uninstall -n kongyu postgresql
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=postgresql
```

