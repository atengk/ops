# 安装flink

查看版本

```
helm search repo bitnami/flink -l
```

下载chart

```
helm pull bitnami/flink --version 1.0.0
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install flink -n kongyu -f values.yaml flink-1.0.0.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=flink
kubectl logs -f -n kongyu deploy/flink-jobmanager
```

使用服务

```
## 进入容器
kubectl exec -it -n kongyu deploy/flink-jobmanager -- bash

## 批处理任务
flink run $FLINK_HOME/examples/batch/WordCount.jar
## 流处理任务
flink run -d $FLINK_HOME/examples/streaming/TopSpeedWindowing.jar

查看作业
flink list

取消作业
flink cancel 93c9d2c202225fc583d1daeda6aa2942
```

删除服务以及数据

```
helm uninstall -n kongyu flink
```

