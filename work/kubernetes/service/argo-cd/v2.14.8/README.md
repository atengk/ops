# Argo CD

Argo CD 是一个开源的 Kubernetes 原生持续交付（CD）工具，用于自动化管理和部署应用。它基于声明式配置，允许开发者通过 GitOps 工作流管理 Kubernetes 应用。Argo CD 监控 Git 仓库中的应用定义，自动将其同步到目标 Kubernetes 集群，确保应用状态与 Git 中的定义一致。它提供强大的 Web UI、CLI 和 API 支持，适合大规模、复杂环境下的持续交付需求。

- [官网链接](https://argo-cd.readthedocs.io/)



**查看版本**

```
helm search repo bitnami/argo-cd -l
```

**下载chart**

```
helm pull bitnami/argo-cd --version 7.3.1
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/argo-cd="true"
```

**创建服务**

```
helm install argo-cd -n kongyu -f values.yaml argo-cd-7.3.1.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=argo-cd
kubectl logs -f -n kongyu deploy/argo-cd
```

**使用服务**

访问Web地址

> service/argo-cd 的 3000

```
URL: http://192.168.1.10:18764
```

**删除服务以及数据**

```
helm uninstall -n kongyu argo-cd
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=argo-cd
```

