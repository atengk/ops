# 安装Mariadb

查看版本

```
helm search repo bitnami/mariadb -l
```

下载chart

```
helm pull bitnami/mariadb --version 18.2.6
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/mariadb="true"
```

创建服务

```shell
helm install mariadb -n kongyu -f values.yaml mariadb-18.2.6.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=mariadb
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=mariadb
```

使用服务

```

```

删除服务以及数据

```shell
helm uninstall -n kongyu mariadb
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=mariadb
```

