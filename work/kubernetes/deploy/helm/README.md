## Helm

Helm 是 Kubernetes 的包管理工具，用于简化应用的部署和管理。通过 Helm，可以打包、分享和配置 Kubernetes 应用，使用 Chart 文件定义应用的所有资源，支持版本控制和回滚操作。Helm 提供标准化的模板语法，使应用的安装和升级更灵活高效，适合 DevOps 场景中快速管理复杂的 Kubernetes 部署。

https://helm.sh/zh/

**下载软件包**

```
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
```

**安装**

```
tar -zxvf helm-v3.16.2-linux-amd64.tar.gz /usr/local/bin
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

