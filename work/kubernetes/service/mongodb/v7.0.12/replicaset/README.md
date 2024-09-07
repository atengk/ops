# 安装mongodb

查看版本

```
helm search repo bitnami/mongodb -l
```

下载chart

```
helm pull bitnami/mongodb --version 15.6.12
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/mongodb="true"
kubectl label nodes server03.lingo.local kubernetes.service/mongodb="true"
```

创建服务

```shell
helm install mongodb -n kongyu -f values.yaml mongodb-15.6.12.tgz
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
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=mongodb
```

