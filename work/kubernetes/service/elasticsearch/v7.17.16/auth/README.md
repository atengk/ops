# 安装ElasticSearch集群

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass
>
> [插件下载地址](https://artifacts.elastic.co/downloads/elasticsearch-plugins)

```
cat values.yaml
```

创建服务

```shell
helm install elasticsearch -n kongyu -f values.yaml elasticsearch-19.13.14.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=elasticsearch
kubectl logs -f -n kongyu elasticsearch-coordinating-0
```

使用服务

```
curl -u elastic:Admin@123 http://192.168.1.19:22492/
```

删除服务以及数据

```
helm uninstall -n kongyu elasticsearch
kubectl delete -n kongyu pvc data-elasticsearch-data-{0..1} data-elasticsearch-master-{0..1}
```

