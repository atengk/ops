# 安装Redis Cluster

## 开发环境

> 使用LoadBalancer将集群暴露到集群外部访问

查看版本

```
helm search repo bitnami/redis-cluster -l
```

下载chart

```
helm pull bitnami/redis-cluster --version 7.6.4
```

修改配置

> values-dev.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values-dev.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
kubectl label nodes server03.lingo.local kubernetes.service/redis="true"
```

创建服务

```
helm install redis -n kongyu -f values-dev.yaml redis-cluster-7.6.4.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-0
```

使用服务

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:6.2.7 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -c -h redis-0.redis-headless.kongyu info server
```

删除服务以及数据

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```



## 生产环境

> 只能在k8s集群内部访问

查看版本

```
helm search repo bitnami/redis-cluster -l
```

下载chart

```
helm pull bitnami/redis-cluster --version 7.6.4
```

修改配置

> values-prod.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values-prod.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/redis="true"
kubectl label nodes server03.lingo.local kubernetes.service/redis="true"
```

创建服务

```
helm install redis -n kongyu -f values-prod.yaml redis-cluster-7.6.4.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-0
```

使用服务

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:6.2.7 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -c -h redis-0.redis-headless.kongyu info server
```

删除服务以及数据

```
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=redis
```

