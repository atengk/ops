# 创建服务

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install redis -n kongyu -f values.yaml redis-19.6.0.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=redis
kubectl logs -f -n kongyu redis-master-0 redis
```

使用服务

```
kubectl run redis-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/redis:7.2.5 --namespace kongyu --env REDISCLI_AUTH=Admin@123 --command -- redis-cli -h redis-master-0.redis-headless.kongyu.svc.cluster.local info server
```

# 基于KubeSphere创建ServiceMonitor

## 查看pometheus的label

> 查看KubeSphere的Pometheus的标签，后续创建ServiceMonitor会用到

```shell
kubectl get prometheus -n kubesphere-monitoring-system k8s -o jsonpath="{.metadata.labels}"
```

> 例如，输出以下内容{"app.kubernetes.io/component":"prometheus","app.kubernetes.io/instance":"k8s","app.kubernetes.io/name":"prometheus","app.kubernetes.io/part-of":"kube-prometheus","app.kubernetes.io/version":"2.39.1"}

## 查看metrics的label

> 查看redis的svc的metrics的标签，后续创建ServiceMonitor会用到

```shell
kubectl get svc -n kongyu redis-metrics -o jsonpath="{.metadata.labels}"
```

> 例如，输出以下内容{"app.kubernetes.io/component":"metrics","app.kubernetes.io/instance":"redis","app.kubernetes.io/managed-by":"Helm","app.kubernetes.io/name":"redis","helm.sh/chart":"redis-16.13.2"}

## 创建ServiceMonitor

```shell
kubectl apply -f servicemonitor.yaml
```

## 查看Targets

> 登录prometheus的web，进入http://192.168.1.10:15082/targets，查看是否有创建的ServiceMonitor

```shell
kubectl get svc -n kubesphere-monitoring-system prometheus-k8s
```

# 删除服务以及数据

```
kubectl delete -f servicemonitor.yaml
helm uninstall -n kongyu redis
kubectl delete -n kongyu pvc redis-data-redis-master-0
```

# 
