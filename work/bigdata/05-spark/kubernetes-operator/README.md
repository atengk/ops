# 使用Kubernetes安装Spark Operator

本指南将向您展示如何在Kubernetes集群中安装和配置Spark Operator，以便运行Apache Spark作业。

## 准备工作

在开始之前，请确保您已经：

1. 安装并配置了Kubernetes集群。
2. 安装了Helm（Kubernetes的包管理工具）。
3. 拥有集群的管理权限。

## 安装Spark Operator

我们将使用Helm来安装Spark Operator。首先，下载Spark Operator的Helm chart包。

```sh
wget https://github.com/kubeflow/spark-operator/releases/download/spark-operator-chart-1.4.6/spark-operator-1.4.6.tgz
```

然后，通过以下命令安装Spark Operator：

```sh
helm install spark-operator \
    -n spark-operator --create-namespace \
    --set image.repository=registry.lingo.local/service/spark-operator \
    --set image.tag=v1beta2-1.6.2-3.5.0 \
    --set image.pullPolicy=IfNotPresent \
    --set webhook.enable=true \
    spark-operator-1.4.6.tgz
```

以上命令解释：

- `helm install spark-operator`：使用Helm安装Spark Operator。
- `-n spark-operator --create-namespace`：在名为`spark-operator`的命名空间中创建并安装Spark Operator。
- `--set image.repository=registry.lingo.local/service/spark-operator`：指定Spark Operator镜像的仓库地址。
- `--set image.tag=v1beta2-1.6.2-3.5.0`：指定Spark Operator镜像的标签。
- `--set image.pullPolicy=IfNotPresent`：设置镜像的拉取策略为`IfNotPresent`。
- `--set webhook.enable=true`：启用webhook。

安装完成后，您可以通过以下命令查看Spark Operator的Pod和服务：

```sh
kubectl get pod,svc -n spark-operator
```

**创建命名空间和serviceacount**

```
# 创建namespace
kubectl create ns spark
# 创建serviceaccount
kubectl create -n spark serviceaccount spark-service-account
kubectl create clusterrolebinding spark-role-binding-spark --clusterrole=edit --serviceaccount=spark:spark-service-account
```

## 部署Spark应用

接下来，我们将部署一个简单的Spark应用（例如，Spark的Pi计算示例）。首先，确保您有一个名为`spark-pi.yaml`的YAML文件，其内容如下：

```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi
  namespace: default
spec:
  type: Scala
  mode: cluster
  image: spark:latest
  imagePullPolicy: Always
  mainClass: org.apache.spark.examples.SparkPi
  mainApplicationFile: local:///opt/spark/examples/jars/spark-examples_2.12-3.0.1.jar
  sparkVersion: 3.0.1
  restartPolicy:
    type: Never
  driver:
    cores: 1
    memory: 512m
    serviceAccount: spark
  executor:
    cores: 1
    instances: 2
    memory: 512m
```

通过以下命令应用该配置：

```sh
kubectl apply -f spark-pi.yaml
```

这将部署并运行Spark Pi应用。您可以通过以下命令查看应用的状态：

```sh
kubectl get sparkapplications -n default
```

以及查看Pod的状态：

```sh
kubectl get pods -n default
```

## 参考资料

- [Spark Operator GitHub 仓库](https://github.com/kubeflow/spark-operator)
- [Kubeflow Spark Operator 入门指南](https://www.kubeflow.org/docs/components/spark-operator/getting-started/)

通过以上步骤，您应该已经成功地在Kubernetes集群中安装并运行了Spark Operator和一个简单的Spark应用。