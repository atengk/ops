# 安装kibana

查看版本

```
helm search repo bitnami/kibana -l
```

下载chart

```
helm pull bitnami/kibana --version 11.2.12
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass
>

```
cat values.yaml
```

创建服务

```shell
helm install kibana -n kongyu -f values.yaml kibana-11.2.12.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kibana
kubectl logs -f -n kongyu deploy/kibana
```

使用服务

```
URL: http://192.168.1.10:36981/
```

删除服务以及数据

```
helm uninstall -n kongyu kibana
```

