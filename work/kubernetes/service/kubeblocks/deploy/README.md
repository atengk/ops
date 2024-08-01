# 安装 KubeBlocks

KubeBlocks 是一个云原生数据库管理平台，以下步骤将指导您如何安装 KubeBlocks。

### 1. 准备工作

在开始安装之前，您需要下载并应用 KubeBlocks 的自定义资源定义（CRDs）。

#### 下载 KubeBlocks CRDs
首先，下载 KubeBlocks 的 CRDs 以便在 Kubernetes 集群中创建相应的资源类型。
```sh
wget https://github.com/apecloud/kubeblocks/releases/download/v0.9.0/kubeblocks_crds.yaml
```

#### 应用 KubeBlocks CRDs
使用 `kubectl` 命令创建这些自定义资源定义。
```sh
kubectl create -f kubeblocks_crds.yaml
```

### 2. 添加和更新 Helm 仓库

为了后续安装 KubeBlocks，您需要添加并更新 Helm 仓库。

#### 添加 KubeBlocks Helm 仓库
添加 KubeBlocks 的 Helm 仓库，以便后续可以从该仓库中拉取 Helm chart。
```sh
helm repo add kubeblocks https://apecloud.github.io/helm-charts
```

#### 更新 Helm 仓库
更新本地的 Helm 仓库缓存，以确保可以获取到最新的 Helm chart。
```sh
helm repo update
```

### 3. 搜索和下载 Helm chart

在安装 KubeBlocks 之前，您需要搜索并下载指定版本的 Helm chart。

#### 搜索 KubeBlocks Helm chart
搜索 KubeBlocks 的 Helm chart，并列出所有可用版本。
```sh
helm search repo kubeblocks/kubeblocks -l
```

#### 下载指定版本的 KubeBlocks Helm chart
下载 KubeBlocks 0.9.0 版本的 Helm chart 包。
```sh
helm pull kubeblocks/kubeblocks --version 0.9.0
```

### 4. 查看和修改配置

在安装之前，查看默认的 Helm chart 配置值，并根据需要进行修改。

#### 查看默认的 Helm chart 配置值
将下载的 Helm chart 包中的默认配置值导出到 `values.yaml` 文件，以便后续可以根据需要进行修改。
```sh
helm show values kubeblocks-0.9.0.tgz > values.yaml
```

### 5. 安装 KubeBlocks

使用 Helm 安装 KubeBlocks，并指定命名空间。

#### 安装 KubeBlocks
使用 Helm 安装 KubeBlocks，指定命名空间为 `kb-system`，并在安装过程中创建该命名空间。
```sh
helm install kubeblocks --namespace kb-system --create-namespace --set dataProtection.encryptionKey="Admin@123" kubeblocks-0.9.0.tgz
```

#### 检查 KubeBlocks 的 Pod
安装完成后，可以使用以下命令检查 `kb-system` 命名空间中的 Pod 状态，确保所有 Pod 都正常运行。
```sh
kubectl -n kb-system get pod
```

### 6. 安装并配置 `kbcli` 工具

`kbcli` 是 KubeBlocks 的命令行工具，以下步骤将指导您如何安装和配置 `kbcli`。

#### 下载并安装 `kbcli`
下载 `kbcli` 工具，并将其安装到系统的可执行路径。
```sh
wget https://jihulab.com/api/v4/projects/85948/packages/generic/kubeblocks/v0.9.0/kbcli-linux-amd64-v0.9.0.tar.gz
tar -zxvf kbcli-linux-amd64-v0.9.0.tar.gz
cp linux-amd64/kbcli /usr/local/bin/kbcli
rm -rf linux-amd64
```

#### 验证 `kbcli` 安装
检查 `kbcli` 的版本，确认安装成功。
```sh
kbcli version
```

#### 配置 `kbcli` 完成功能
为 `kbcli` 命令启用 bash 自动完成功能，并将其添加到系统的 bash 自动完成脚本中。
```sh
source <(kbcli completion bash)
kbcli completion bash > /etc/bash_completion.d/kbcli
```

---

以上章节将帮助您分步骤在 Kubernetes 集群中成功安装和配置 KubeBlocks，并完成 `kbcli` 工具的安装和配置。如果在安装过程中遇到任何问题，请参考 KubeBlocks 的[官方文档](https://github.com/apecloud/kubeblocks)获取更多信息。