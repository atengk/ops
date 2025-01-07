# Spark APP使用文档

- [官网示例链接](https://github.com/kubeflow/spark-operator/tree/master/examples)



## SparkApp pi示例

**创建任务**

```
kubectl apply -n ateng-spark -f spark-pi.yaml
```

**查看任务**

```sh
sparkctl -n ateng-spark list
sparkctl -n ateng-spark status spark-pi
```

**查看任务**

```
kubectl logs -n ateng-spark --tail=200 spark-pi-driver
```

**删除任务**

```
kubectl delete -n ateng-spark -f spark-pi.yaml
kubectl delete -n ateng-spark pod spark-pi-driver
```



## Scheduled SparkApp pi示例

定时任务

**创建定时任务**

```
kubectl apply -n ateng-spark -f spark-pi-schedule.yaml
```

**查看定时任务**

```
kubectl get -n ateng-spark scheduledsparkapp
```

**查看任务**

```sh
sparkctl -n ateng-spark list
sparkctl -n ateng-spark status spark-pi-1735224120000724061
```

**查看任务日志**

```
kubectl logs -n ateng-spark --tail=200 spark-pi-1735224120000724061-driver
```

**删除定时任务**

```
kubectl delete -n ateng-spark -f spark-pi-schedule.yaml
kubectl delete -n ateng-spark pod -l app.kubernetes.io/name=spark-pi
```



