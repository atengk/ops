# 安装Nginx

查看版本

```
helm search repo bitnami/haproxy -l
```

下载chart

```
helm pull bitnami/haproxy --version 2.0.9
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install haproxy -n kongyu -f values-haproxy.yaml haproxy-2.0.9.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=haproxy
```

使用服务

```

```

删除服务以及数据

```
helm uninstall -n kongyu haproxy
```

