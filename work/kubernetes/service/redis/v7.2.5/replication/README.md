# 安装Redis主从

查看版本

```
helm search repo bitnami/redis -l
```

下载chart

```
helm pull bitnami/redis --version 19.6.0
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
kubectl label nodes server03.lingo.local kubernetes.service/redis="true"
```

创建服务

```
helm install redis -n kongyu -f values.yaml redis-19.6.0.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=redis
```

使用服务

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -h redis-master info server replication
```

删除服务以及数据

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

