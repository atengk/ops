# 安装Flink 1.18.1



## 基础环境配置

解压软件包

```
tar -zxvf flink-1.18.1-bin-scala_2.12.tgz -C /usr/local/software/
ln -s /usr/local/software/flink-1.18.1 /usr/local/software/flink
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## FLINK_HOME
export FLINK_HOME=/usr/local/software/flink
export PATH=$PATH:$FLINK_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
flink --version
```



## YARN查看进程信息

**查看应用列表：**

```
yarn application -list
```

**查看应用状态：** 

```
yarn application -status <application_id>
```

**取消应用**

```
yarn application -kill <application_id>
```

**查看日志**

```
yarn logs -applicationId <application ID>
```

**查看应用资源信息**

```
yarn top
```



# Flink On K8S

## Application 模式

> [官方文档](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/deployment/resource-providers/native_kubernetes/)

1. **前提条件准备运行**

当前运行的环境保护kubectl命令和kubeconfig，且kubeconfig有相应的权限

**创建命名空间和serviceacount**

```
# 创建namespace
kubectl create ns flink
# 创建serviceaccount
kubectl create -n flink serviceaccount flink-service-account
kubectl create clusterrolebinding flink-role-binding-flink --clusterrole=edit --serviceaccount=flink:flink-service-account
```

2. **运行在k8s上**

> [配置参数](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/deployment/config/#kubernetes)

**普通运行模式**

```
flink run-application -t kubernetes-application \
    -Dkubernetes.cluster-id=my-first-application-cluster \
    -Dkubernetes.container.image=registry.lingo.local/kongyu/flink-on-k8s-demo:latest \
    -Dkubernetes.namespace=flink \
    -Dkubernetes.rest-service.exposed.type=NodePort \
    -Dkubernetes.container.image.pull-policy=Always \
    -Dkubernetes.jobmanager.service-account=flink-service-account \
    -Dkubernetes.jobmanager.replicas=1 \
    -Dkubernetes.jobmanager.cpu.amount=1.0 \
    -Dkubernetes.jobmanager.cpu.limit-factor=2.0 \
    -Dkubernetes.jobmanager.memory.limit-factor=2.0 \
    -c local.kongyu.datastream.datastream01 local:///opt/flink/jobs/flink-on-k8s.jar
```

**高可用运行模式**

```
flink run-application -t kubernetes-application \
    -Dkubernetes.cluster-id=my-first-application-cluster \
    -Dkubernetes.jobmanager.replicas=3 \
    -Dkubernetes.container.image=registry.lingo.local/kongyu/flink-on-k8s-demo:latest \
    -Dkubernetes.namespace=flink \
    -Dkubernetes.jobmanager.service-account=flink-service-account \
    -Dkubernetes.taskmanager.service-account=flink-service-account \
    -Dkubernetes.rest-service.exposed.type=NodePort \
    -Dkubernetes.container.image.pull-policy=Always \
    -Dhigh-availability.type=KUBERNETES \
    -Dhigh-availability.cluster-id=my-first-application-cluster \
    -Dhigh-availability.storageDir=/tmp \
    -c local.kongyu.datastream.datastream01 local:///opt/flink/jobs/flink-on-k8s.jar
```

> 运行完后，有一个Web的连接

3. **在k8s中查看**

```
kubectl get -n flink all
```

4. **停止任务**

```
1. 进入web控制台 Cancel Job
2. kubectl -n flink delete deployments.apps my-first-application-cluster
以上两种方法执行后都会清除所有相关配置
```

