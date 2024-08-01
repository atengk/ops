# 安装MySQL单机

查看版本

```
helm search repo bitnami/mysql -l
```

下载chart

```
helm pull bitnami/mysql --version 10.2.1
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install mysql -n kongyu -f values.yaml mysql-10.2.1.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mysql
kubectl logs -f -n kongyu mysql-0 mysql
```

使用服务

```
kubectl run mysql-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/mysql:8.0.36 --namespace kongyu --command -- mysqladmin status -hmysql -uroot -pAdmin@123
```

# 基于KubeSphere创建ServiceMonitor

## 查看pometheus的label

查看KubeSphere的Pometheus的标签，后续创建ServiceMonitor会用到

```shell
kubectl get prometheus -n kubesphere-monitoring-system k8s -o jsonpath="{.metadata.labels}"
```

> 例如，输出以下内容{"app.kubernetes.io/component":"prometheus","app.kubernetes.io/instance":"k8s","app.kubernetes.io/name":"prometheus","app.kubernetes.io/part-of":"kube-prometheus","app.kubernetes.io/version":"2.39.1"}

## 查看metrics的label

查看mysql的svc的metrics的标签，后续创建ServiceMonitor会用到

```shell
kubectl get svc -n kongyu mysql-metrics -o jsonpath="{.metadata.labels}"
```

> 例如，输出以下内容{"app.kubernetes.io/component":"metrics","app.kubernetes.io/instance":"mysql","app.kubernetes.io/managed-by":"Helm","app.kubernetes.io/name":"mysql","app.kubernetes.io/version":"8.0.34","helm.sh/chart":"mysql-9.12.3"}

## 创建ServiceMonitor

将上面两项的信息配置到servicemonitor.yaml文件中

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
helm uninstall -n kongyu mysql
kubectl delete -n kongyu pvc data-mysql-0
```

# 
