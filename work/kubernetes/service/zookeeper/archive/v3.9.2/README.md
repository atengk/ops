# 安装zookeeper

查看版本

```
helm search repo bitnami/zookeeper -l
```

下载chart

```
helm pull bitnami/zookeeper --version 13.4.7
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install zookeeper -n kongyu -f values.yaml zookeeper-13.4.7.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=zookeeper
kubectl logs -f -n kongyu zookeeper-0
```

使用服务

```
kubectl run zookeeper-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/zookeeper:3.9.2 --namespace kongyu --command -- zkCli.sh -server zookeeper:2181
```

删除服务以及数据

```
helm uninstall -n kongyu zookeeper
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=zookeeper
```

