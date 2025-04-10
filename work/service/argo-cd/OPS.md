# Argo CD 使用文档



## 添加 Git 仓库（Repository）配置

Argo CD 支持通过 Kubernetes Secret 来声明 Git 仓库的认证信息。

🔐 示例：HTTPS + 用户名密码认证的 Git 仓库

```
apiVersion: v1
kind: Secret
metadata:
  name: my-git-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  url: http://gitlab.lingo.local/kongyu/springboot-demo.git
  username: devops
  password: Admin@123
```

🔑 示例：SSH 认证方式（更安全）

```
apiVersion: v1
kind: Secret
metadata:
  name: my-git-repo-ssh
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: git@github.com:your-org/your-repo.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
```

部署：

```
kubectl apply -f repo-secret.yaml
```