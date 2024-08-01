# 安装OpenSearch

查看版本

```
helm search repo bitnami/opensearch -l
```

下载chart

```
helm pull bitnami/opensearch --version 1.2.9
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install opensearch -n kongyu -f values.yaml opensearch-1.2.9.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=opensearch
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=opensearch
```

使用服务

```
curl http://192.168.1.10:18536/
curl http://192.168.1.10:18536/_cat/nodes?v
```

删除服务以及数据

```
helm uninstall -n kongyu opensearch
kubectl delete -n kongyu pvc -l app.kubernetes.io/instance=opensearch
```

