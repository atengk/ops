# Argo CD

Argo CD 是一个开源的 Kubernetes 原生持续交付（CD）工具，用于自动化管理和部署应用。它基于声明式配置，允许开发者通过 GitOps 工作流管理 Kubernetes 应用。Argo CD 监控 Git 仓库中的应用定义，自动将其同步到目标 Kubernetes 集群，确保应用状态与 Git 中的定义一致。它提供强大的 Web UI、CLI 和 API 支持，适合大规模、复杂环境下的持续交付需求。

- [官网链接](https://argo-cd.readthedocs.io/)



## 安装Argo CD

### helm安装

参考文档：[helm安装Argo CD](/work/kubernetes/service/argo-cd/v2.14.8/)