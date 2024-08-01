安装

```
tar -zxvf helm-v3.9.4-linux-amd64.tar.gz /usr/local/bin
```

查看

```
helm version
```

添加仓库

```
helm repo add bitnami https://charts.bitnami.com/bitnami/
helm repo update
helm repo list
```

配置命令补全

```
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

