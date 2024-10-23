# SonarQube 

SonarQube 是一个开源的代码质量和安全管理平台，用于自动化分析代码的质量和检测潜在的安全漏洞。它支持多种编程语言，并能集成到持续集成/持续交付 (CI/CD) 流程中。

**查看版本**

```
helm search repo bitnami/sonarqube -l
```

**下载chart**

```
helm pull bitnami/sonarqube --version 6.0.0
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/sonarqube="true"
```

**创建服务**

```shell
helm install sonarqube -n kongyu -f values.yaml sonarqube-6.0.0.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=sonarqube
kubectl logs -f -n kongyu deploy/sonarqube
```

**使用服务**

```
Url: http://192.168.1.10:24252
Username: admin
Password: Admin@123
```

**删除服务以及数据**

```
helm uninstall -n kongyu sonarqube
```

