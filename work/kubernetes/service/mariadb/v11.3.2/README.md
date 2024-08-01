# 安装Mariadb Galera集群

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install mariadb-galera -n kongyu -f values.yaml mariadb-galera-13.2.5.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mariadb-galera
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mariadb-galera
```

使用服务

```
kubectl run mariadb-galera-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mariadb-galera:11.3.2 --namespace kongyu --command -- mysql -hmariadb-galera -uroot -pAdmin@123 -e "select * from mysql.wsrep_cluster_members"
```

删除服务以及数据

```
helm uninstall -n kongyu mariadb-galera
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=mariadb-galera
```

