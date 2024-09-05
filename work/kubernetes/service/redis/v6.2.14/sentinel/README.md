# 安装Redis Sentinel

查看版本

```
helm search repo bitnami/redis -l
```

下载chart

```
helm pull bitnami/redis --version 16.13.2
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
helm install redis -n kongyu -f values.yaml redis-16.13.2.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-node-0 sentinel
```

使用服务

> sentinel只支持k8s集群内部访问，或者通过ExternalDNS

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:6.2.7 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -h redis.kongyu -p 26379 info server
```

删除服务以及数据

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

