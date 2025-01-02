# 安装spark

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install spark -n kongyu -f values.yaml spark-8.1.7.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=spark
kubectl logs -f -n kongyu spark-master-0
```

使用服务

```
kubectl run --namespace kongyu spark-client --rm --tty -i --restart='Never' \
    --image registry.lingo.local/service/spark:3.5.0 \
    -- spark-submit --master spark://spark-master-svc:7077 \
    --class org.apache.spark.examples.SparkPi \
    --deploy-mode cluster \
    examples/jars/spark-examples_2.12-3.5.0.jar 10
```

删除服务以及数据

```
helm uninstall -n kongyu spark
```

