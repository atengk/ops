# 创建jenkins

查看版本

```
helm search repo bitnami/jenkins -l
```

下载chart

```
helm pull bitnami/jenkins --version 13.4.9
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install jenkins -n kongyu -f values.yaml jenkins-13.4.9.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=jenkins
kubectl logs -f -n kongyu deploy/jenkins -c jenkins
```

使用服务

```
URL: http://192.168.1.10:48887/
Username: admin
Password: Admin@123
```

删除服务以及数据

```
helm uninstall -n kongyu jenkins
```

