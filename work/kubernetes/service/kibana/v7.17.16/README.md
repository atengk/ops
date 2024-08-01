# 安装kibana

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass
>

```
cat values.yaml
```

创建服务

```shell
helm install kibana -n kongyu -f values.yaml kibana-10.6.7.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=kibana
kubectl logs -f -n kongyu deploy/kibana
```

使用服务

```
URL: http://192.168.1.10:20907/
```

删除服务以及数据

```
helm uninstall -n kongyu kibana
```

