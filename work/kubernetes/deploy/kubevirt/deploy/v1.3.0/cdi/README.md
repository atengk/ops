# 安装 Containerized Data Importer (CDI)

CDI (Containerized Data Importer) 是一个用于 Kubernetes 的工具，可以帮助从不同的数据源导入 VM 磁盘映像。本教程将指导你如何安装 CDI。

### 步骤 1: 设置版本

首先，定义要安装的 CDI 版本。我们将使用 `v1.59.0` 版本。你可以根据需要调整这个版本号。

```sh
export VERSION=v1.59.0
```

### 步骤 2: 下载 CDI Operator 和 Custom Resource (CR) 文件

接下来，下载 CDI Operator 和 CR 的 YAML 文件。这些文件定义了 CDI 的安装和配置。

```sh
curl -L -O https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
curl -L -O https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
```

### 步骤 3: 应用 CDI Operator 和 CR

使用 `kubectl` 命令来创建 CDI Operator 和 CR。

```sh
kubectl create -f cdi-operator.yaml
kubectl create -f cdi-cr.yaml
```

### 步骤 4: 验证 CDI 安装

你可以通过以下命令来验证 CDI 是否已成功安装并运行。

```sh
kubectl get cdi cdi -n cdi
kubectl get pods -n cdi
```

这两个命令将分别显示 CDI 的状态和 CDI 命名空间中的 Pod 列表。如果所有 Pod 都处于 `Running` 状态，则表示 CDI 安装成功。

### 参考资料

更多详细信息和高级配置选项，请参考 [CDI 官方文档](https://kubevirt.io/labs/kubernetes/lab2.html)。

---

通过以上步骤，你应该能够成功在 Kubernetes 集群中安装和配置 CDI。如果遇到任何问题，请查阅官方文档或寻求社区支持。