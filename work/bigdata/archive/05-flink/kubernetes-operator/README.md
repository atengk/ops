
# 使用Kubernetes安装Flink Kubernetes Operator 1.9.0

## 前提条件

- 已经安装 `cert-manager`

## 步骤一：下载并解压Flink Kubernetes Operator

首先，我们需要下载并解压Flink Kubernetes Operator的安装包。

```bash
wget https://github.com/apache/flink-kubernetes-operator/archive/refs/tags/release-1.9.0.tar.gz
tar -zxf flink-kubernetes-operator-release-1.9.0.tar.gz
```

**说明：**

- `wget` 命令用于从指定的URL下载文件。
- `tar -zxf` 命令用于解压下载的tar.gz文件。

## 步骤二：使用Helm打包并安装Flink Kubernetes Operator

接下来，我们使用Helm打包并安装Flink Kubernetes Operator。

```bash
helm package flink-kubernetes-operator-release-1.9.0/helm/flink-kubernetes-operator/
helm install flink-kubernetes-operator \
    -n flink --create-namespace \
    --set image.repository=registry.lingo.local/service/flink-kubernetes-operator \
    --set image.tag=1.9.0 \
    --set image.pullPolicy=IfNotPresent \
    flink-kubernetes-operator-1.9.0.tgz
```

**说明：**

- `helm package` 命令用于将Flink Kubernetes Operator的Helm chart打包成tgz文件。
- `helm install` 命令用于在Kubernetes集群中安装Helm chart。
- `-n flink --create-namespace` 参数用于在名为`flink`的命名空间中安装，并在需要时创建该命名空间。
- `--set` 参数用于覆盖Helm chart中的默认值，例如镜像仓库、标签和拉取策略。

安装完成后，可以通过以下命令查看Pod的状态：

```bash
kubectl get -n flink pod -o wide
```

## 步骤三：部署一个基本的Flink任务

接下来，我们创建一个基本的Flink任务配置文件，并在Kubernetes中部署。

```bash
cat > flink-basic.yaml <<EOF
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  name: flink-basic
  namespace: flink
spec:
  image: registry.lingo.local/service/flink:1.18
  flinkVersion: v1_18
  flinkConfiguration:
    taskmanager.numberOfTaskSlots: "2"
  serviceAccount: flink
  jobManager:
    resource:
      memory: "2048m"
      cpu: 1
  taskManager:
    resource:
      memory: "2048m"
      cpu: 1
  job:
    jarURI: local:///opt/flink/examples/streaming/TopSpeedWindowing.jar
    parallelism: 2
EOF
kubectl apply -f flink-basic.yaml
```

**说明：**

- `cat > flink-basic.yaml <<EOF ... EOF` 命令用于创建一个新的yaml文件并写入内容。
- `kubectl apply -f flink-basic.yaml` 命令用于在Kubernetes中应用该配置文件。

查看并跟踪Pod日志：

```bash
kubectl get pod -n flink -l app=flink-basic
kubectl logs -f -n flink -l app=flink-basic
```

## 步骤四：部署支持检查点的Flink任务

如果需要部署一个支持检查点和保存点的Flink任务，可以使用以下配置文件：

```bash
cat > flink-basic-checkpoints.yaml <<EOF
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  name: flink-basic-checkpoints
  namespace: flink
spec:
  image: registry.lingo.local/service/flink:1.18
  flinkVersion: v1_18
  flinkConfiguration:
    taskmanager.numberOfTaskSlots: "2"
    state.savepoints.dir: file:///flink-data/savepoints
    state.checkpoints.dir: file:///flink-data/checkpoints
  serviceAccount: flink
  jobManager:
    resource:
      memory: "2048m"
      cpu: 1
  taskManager:
    resource:
      memory: "2048m"
      cpu: 1
  job:
    jarURI: local:///opt/flink/examples/streaming/TopSpeedWindowing.jar
    parallelism: 2
    upgradeMode: savepoint
    state: running
    checkpointTriggerNonce: 30
    savepointTriggerNonce: 30
  podTemplate:
    spec:
      containers:
        - name: flink-main-container
          volumeMounts:
          - mountPath: /flink-data
            name: flink-volume
      volumes:
      - name: flink-volume
        hostPath:
          path: /tmp/flink
          type: DirectoryOrCreate
EOF
kubectl apply -f flink-basic-checkpoints.yaml
```

**说明：**

- 该配置文件与基本的Flink任务配置类似，但添加了检查点和保存点的配置。
- `state.savepoints.dir` 和 `state.checkpoints.dir` 指定了保存点和检查点的存储路径。
- `checkpointTriggerNonce` 和 `savepointTriggerNonce` 用于手动触发检查点和保存点。

同样，查看并跟踪Pod日志：

```bash
kubectl get pod -n flink -l app=flink-basic-checkpoints
kubectl logs -f -n flink -l app=flink-basic-checkpoints
```



