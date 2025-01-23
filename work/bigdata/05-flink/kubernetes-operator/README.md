# Flink Operator

`flink-kubernetes-operator` 是一个 Kubernetes Operator，用于自动化管理 Apache Flink 作业和集群。通过自定义资源（CR），它简化了 Flink 作业的部署、监控、扩展和恢复。该工具提供声明式 API，支持高可用性、动态资源调整和自动故障恢复，使 Flink 在 Kubernetes 环境中的管理更加高效和可靠。

- [官网链接](https://github.com/apache/flink-kubernetes-operator)



## 前提条件

- 已经安装 `cert-manager`，参考[链接](/work/kubernetes/service/cert-manager/v1.16.2/)

## 安装operator

**下载并解压软件包**

```bash
wget https://github.com/apache/flink-kubernetes-operator/archive/refs/tags/release-1.10.0.tar.gz
tar -zxf flink-kubernetes-operator-release-1.10.0.tar.gz
```

**打包Chart**

```bash
helm package flink-kubernetes-operator-release-1.10.0/helm/flink-kubernetes-operator/
rm -rf flink-kubernetes-operator-release-1.10.0/
```

**安装operator**

```bash
helm install flink-kubernetes-operator \
    -n flink-operator --create-namespace \
    --set image.repository=registry.lingo.local/service/flink-kubernetes-operator \
    --set image.tag=1.10.0 \
    --set image.pullPolicy=IfNotPresent \
    flink-kubernetes-operator-1.10.0.tgz
```

**查看operator**

```bash
kubectl get -n flink-operator pod -o wide
```

**查看日志**

```bash
kubectl logs -n flink-operator -f --tail=200 deploy/flink-kubernetes-operator
```



## 创建服务账户

创建后续应用任务的命名空间，都运行在该命名空间下

**创建命名空间**

```
kubectl create ns ateng-flink
```

**创建serviceacount**

```
kubectl create -n ateng-flink serviceaccount flink
kubectl create clusterrolebinding crb-ateng-flink --clusterrole=edit --serviceaccount=ateng-flink:flink
```



## 创建任务

**创建任务**

```bash
kubectl apply -f - <<EOF
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  name: flink-basic
  namespace: ateng-flink
spec:
  image: registry.lingo.local/service/flink:1.19-java8
  flinkVersion: v1_19
  flinkConfiguration:
    taskmanager.numberOfTaskSlots: "2"
  serviceAccount: flink
  jobManager:
    resource:
      memory: "2048m"
      cpu: 1
  taskManager:
    resource:
      memory: "2048m"
      cpu: 1
  job:
    jarURI: local:///opt/flink/examples/streaming/TopSpeedWindowing.jar
    entryClass: org.apache.flink.streaming.examples.windowing.TopSpeedWindowing
    parallelism: 2
EOF
```

**查看应用**

查看应用

```bash
kubectl get -n ateng-flink flinkdep flink-basic
```

查看pod

```bash
kubectl get -n ateng-flink pod,svc -l app=flink-basic
kubectl logs -n ateng-flink -f --tail=200 -l app=flink-basic
```

**删除应用**

```bash
kubectl delete -n ateng-flink flinkdep flink-basic
```



## 删除服务

**删除operator**

```bash
helm uninstall -n flink-operator flink-kubernetes-operator
```

