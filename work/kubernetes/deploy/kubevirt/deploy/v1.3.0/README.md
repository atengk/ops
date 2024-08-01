# KubeVirt 安装与配置指南

## 介绍

KubeVirt 是一个开源的 Kubernetes 扩展，使用户能够在 Kubernetes 集群中运行和管理虚拟机 (VM)。本文档详细介绍了如何在 Kubernetes 集群上安装 KubeVirt，并配置软件模拟模式以支持无硬件虚拟化的节点。

## 安装 KubeVirt

### 1. 设置版本号

首先，定义您要安装的 KubeVirt 版本。本文档使用 `v1.3.0` 作为示例版本。

```bash
export VERSION=v1.3.0
```

### 2. 下载 KubeVirt Operator 和 CR 定义文件

使用 `curl` 下载 KubeVirt Operator 和 Custom Resource (CR) 定义文件。

```bash
curl -L -O https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
curl -L -O https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
```

### 3. 部署 KubeVirt Operator

使用 `kubectl` 部署 KubeVirt Operator。使用高版本内核，不然vm无法启动。

```bash
kubectl create -f kubevirt-operator.yaml
```

### 4. 部署 KubeVirt CR

继续使用 `kubectl` 部署 KubeVirt Custom Resource。

```bash
kubectl create -f kubevirt-cr.yaml
```

## 配置软件模拟模式

如果您的节点不支持硬件虚拟化，可以通过编辑 KubeVirt Custom Resource 来开启软件模拟模式。请执行以下步骤：

1. 使用 `kubectl edit` 编辑 KubeVirt 配置：

    ```bash
    kubectl edit -n kubevirt kubevirt kubevirt
    ```

2. 在打开的编辑器中找到 `spec` 节点，并添加或修改以下配置以启用软件模拟模式：

    ```yaml
    spec:
      ...
      configuration:
        developerConfiguration:
          useEmulation: true
    ```

3. 保存并退出编辑器。

## 验证安装

要确认 KubeVirt 是否正确安装并运行，您可以检查 `kubevirt` 命名空间中的 Pod 状态。

```bash
kubectl get pods -n kubevirt -o wide
```

## 创建虚拟机 (VM)

### 1. 定义虚拟机 YAML 文件

在创建虚拟机之前，您需要准备一个虚拟机定义的 YAML 文件（例如 `vm-centos7.9.yaml`）。该文件包含虚拟机的配置，包括操作系统镜像、资源分配等。

### 2. 部署虚拟机

使用 `kubectl` 命令创建虚拟机实例：

```bash
kubectl apply -f vm-centos7.9.yaml
```

查看vm

```
kubectl get pod,vmi
kubectl get vmi vmi-centos7.9 -o jsonpath="{.status.interfaces[0].ipAddresses[0]}"
```

## 安装工具

安装virtctl

```
chmod +x virtctl-v1.3.0-linux-amd64
cp virtctl-v1.3.0-linux-amd64 /usr/local/bin/virtctl
virtctl completion bash > /etc/bash_completion.d/virtctl
source <(virtctl completion bash)
```

安装vnc

```
kubectl apply -f virtvnc.yaml
kubectl get pod -n kubevirt
```



## 总结

通过以上步骤，您已经在 Kubernetes 集群中成功安装并配置了 KubeVirt，并且创建了一个虚拟机实例。您可以根据需要进一步自定义和管理您的虚拟机。

如需更多信息或详细配置，请参考 [KubeVirt 官方文档](https://kubevirt.io/)。