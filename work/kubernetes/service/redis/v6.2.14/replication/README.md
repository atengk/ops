修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```
helm install redis -n kongyu -f values.yaml redis-16.13.2.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=redis
```

使用服务

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:6.2.7 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -h redis-master-0.redis-headless.kongyu.svc.cluster.local info server
```

删除服务以及数据

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc redis-data-redis-master-0 redis-data-redis-replicas-{0..2}
```

