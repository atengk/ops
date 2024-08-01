# 安装mongodb

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install mongodb -n kongyu -f values.yaml mongodb-14.4.2.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mongodb
kubectl logs -f -n kongyu mongodb-0
```

使用服务

```
kubectl run mongodb-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mongodb:7.0.4 --namespace kongyu --command -- mongosh admin --host "mongodb-0.mongodb-headless.kongyu.svc.cluster.local:27017,mongodb-1.mongodb-headless.kongyu.svc.cluster.local:27017,mongodb-2.mongodb-headless.kongyu.svc.cluster.local:27017" --authenticationDatabase admin -u root -p Admin@123 --eval "rs.status()"
```

删除服务以及数据

```
helm uninstall -n kongyu mongodb
kubectl delete -n kongyu pvc datadir-mongodb-{0..2}
```

