# 安装DolphinScheduler

环境准备

```
postgresql和dolphinscheduler数据库
minio，和dolphinscheduler桶
zookeeper
k8s的存储类，还需要包含一个支持ReadWriteMany模式的
```

创建服务

```
helm install dolphinscheduler -n lingo-bigdata -f values.yaml dolphinscheduler-helm-3.2.0.tgz
```

查看服务

```
kubectl get -n lingo-bigdata pod,svc,pvc -l app.kubernetes.io/instance=dolphinscheduler
```

访问服务

```
URL: http://192.168.1.10:31882/dolphinscheduler/
Username: admin
Password: dolphinscheduler123
```

删除服务

```
helm uninstall -n lingo-bigdata dolphinscheduler
kubectl delete pvc -n lingo-bigdata -l app.kubernetes.io/instance=dolphinscheduler
```

