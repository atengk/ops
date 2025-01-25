# Spark Operator

Spark Operator 是一个 Kubernetes 控制器，用于简化 Apache Spark 应用的部署与管理。它支持通过 Kubernetes 自定义资源 (CRDs) 定义和管理 Spark 应用生命周期，自动处理集群资源调度、监控和故障恢复。Spark Operator 是 Kubeflow 的一部分，适用于大数据和机器学习任务。

- [Spark Operator GitHub 仓库](https://github.com/kubeflow/spark-operator)
- [Kubeflow Spark Operator 入门指南](https://www.kubeflow.org/docs/components/spark-operator/getting-started/)



## 安装Operator

**下载chart**

```sh
wget https://github.com/kubeflow/spark-operator/releases/download/v2.1.0/spark-operator-2.1.0.tgz
```

**创建命名空间**

创建一个命名空间，后续的spark应用都运行在该命名空间

```
kubectl create ns ateng-spark
```

**安装Operator**

修改values.yaml

修改以下配置：

- image.*: 镜像信息
- spark.jobNamespaces: spark作业命名空间，命名空间需要存在

```
cat values.yaml
```

安装Operator

```sh
helm install spark-operator \
    -n spark-operator --create-namespace \
    -f values.yaml \
    spark-operator-2.1.0.tgz
```

**查看服务**

```sh
kubectl get pod,svc -n spark-operator
```

**查看日志**

```
kubectl logs -f -n spark-operator deploy/spark-operator-controller
kubectl logs -f -n spark-operator deploy/spark-operator-webhook
```

**删除operator**

```
helm uninstall spark-operator -n spark-operator
```

## 安装sparkctl

`sparkctl` 是用于在 Kubernetes 上管理 Spark 作业的命令行工具，简化提交、监控、日志和管理操作。

**下载软件包**

```
wget https://github.com/kubeflow/spark-operator/releases/download/v2.1.0/sparkctl-2.1.0-linux-amd64.tgz
```

**安装软件**

```
tar -zxvf sparkctl-2.1.0-linux-amd64.tgz -C /usr/bin/
```

**配置命令补全**

```
sparkctl completion bash > /etc/bash_completion.d/sparkctl
source <(sparkctl completion bash)
```

## 创建Spark应用

**创建应用**

部署一个简单的Spark应用（例如，Spark的Pi计算示例），注意cores是应用的资源，coreLimit和coreRequest是k8s的设置。

```yaml
kubectl apply -f - <<"EOF"
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi
  namespace: ateng-spark
spec:
  type: Scala
  mode: cluster
  image: registry.lingo.local/service/spark:3.5.4
  imagePullPolicy: Always
  mainClass: org.apache.spark.examples.SparkPi
  arguments:
  - "5000"
  mainApplicationFile: local:///opt/spark/examples/jars/spark-examples.jar
  sparkVersion: 3.5.4
  sparkUIOptions:
    serviceType: NodePort
  restartPolicy:
    type: Never
  driver:
    serviceAccount: spark-operator-spark
    cores: 2
    coreLimit: "2"
    coreRequest: "1"
    memory: "2g"
  executor:
    cores: 2
    coreLimit: "2"
    coreRequest: "1"
    memory: "4g"
    instances: 2
EOF
```

**查看应用**

```sh
kubectl get -n ateng-spark sparkapp spark-pi
sparkctl -n ateng-spark list
```

**查看pod**

```sh
kubectl get -n ateng-spark pods
```

**查看日志**

```
kubectl logs -n ateng-spark --tail=200 spark-pi-driver
```

**删除应用**

```
kubectl delete -n ateng-spark sparkapp spark-pi
kubectl delete -n ateng-spark pod spark-pi-driver
```

