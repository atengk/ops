# Helm

Helm 是 Kubernetes 的包管理工具，用于简化应用的部署和管理。通过 Helm，可以打包、分享和配置 Kubernetes 应用，使用 Chart 文件定义应用的所有资源，支持版本控制和回滚操作。Helm 提供标准化的模板语法，使应用的安装和升级更灵活高效，适合 DevOps 场景中快速管理复杂的 Kubernetes 部署。

- [官网链接](https://helm.sh/zh/)

**下载软件包**

```
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
```

**安装**

```
tar -zxvf helm-v3.16.2-linux-amd64.tar.gz
cp linux-amd64/helm /usr/bin
rm -rf linux-amd64/
```

**查看**

```
helm version
```

**添加仓库**

```
helm repo add bitnami https://charts.bitnami.com/bitnami/
helm repo update
helm repo list
```

**配置命令补全**

```
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

**关于下载Chart**

如果在某些网络环境下，无法下载Chart，可以直接使用官网链接下载

例如这样，无法下载

```
helm pull bitnami/gitea --version 3.2.3
```

输出

```
Error: failed to do request: Head "https://registry-1.docker.io/v2/bitnamicharts/gitea/manifests/3.2.3": dial tcp 107.181.166.244:443: i/o timeout
```

直接使用官网链接下载

```
wget https://charts.bitnami.com/bitnami/gitea-3.2.3.tgz
```

