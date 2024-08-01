修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```
helm install redis -n kongyu -f values.yaml redis-19.6.0.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-node-0 sentinel
```

使用服务

> sentinel只支持k8s集群内部访问，或者通过ExternalDNS

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -h redis -p 26379 info server sentinel masters
```

删除服务以及数据

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

