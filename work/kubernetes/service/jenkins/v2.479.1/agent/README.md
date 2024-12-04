# Jenkins

Jenkins 是一个开源的自动化服务器，广泛用于实现持续集成（CI）和持续交付（CD）。它支持通过插件扩展，能够自动化构建、测试、部署等软件开发流程。Jenkins 提供了图形化的用户界面、分布式构建功能、丰富的插件生态以及强大的集成能力，帮助开发团队提高开发效率和交付速度。

- [官网链接](https://www.jenkins.io)

**查看版本**

```
helm search repo bitnami/jenkins -l
```

**下载chart**

```
helm pull bitnami/jenkins --version 13.4.27
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 副本数量：replicaCount
- 镜像地址：image.registry
- 认证配置：jenkinsUser jenkinsPassword
- 堆内存：javaOpts
- 存储配置：根据需求调整persistence.size的值
- 其他配置：...

```
cat values.yaml
```

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/jenkins="true"
kubectl label nodes server03.lingo.local kubernetes.service/jenkins="true"
```

**创建服务**

```
helm install jenkins -n kongyu -f values.yaml jenkins-13.4.27.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=jenkins
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=jenkins
```

**使用服务**

访问Web

```
URL: http://192.168.1.10:42327/
Username: admin
Password: Admin@123
```

**删除服务以及数据**

```
helm uninstall -n kongyu jenkins
```

