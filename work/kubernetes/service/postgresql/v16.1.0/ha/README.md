# 安装postgresql

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install postgresql -n kongyu -f values.yaml postgresql-ha-12.3.2.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=postgresql
kubectl logs -f -n kongyu postgresql-postgresql-0
```

使用服务

```
kubectl run postgresql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/postgresql-repmgr:16.1.0 --namespace kongyu --env="PGPASSWORD=Admin@123" --command -- psql --host postgresql-pgpool -U postgres -d postgres -p 5432 -c "\l"
## 查看所有配置
SELECT name, setting FROM pg_settings
```

删除服务以及数据

```
helm uninstall -n kongyu postgresql
kubectl delete -n kongyu pvc data-postgresql-postgresql-{0..2}
```

