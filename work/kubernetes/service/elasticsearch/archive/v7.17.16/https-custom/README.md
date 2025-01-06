# 安装ElasticSearch集群

创建证书

```
## openssl方式
kubectl -n kongyu create secret generic tls-openssl-elasticsearch \
  --from-file=ca.crt=tls-openssl-ca.crt \
  --from-file=tls.crt=tls-openssl-elasticsearch-server.crt \
  --from-file=tls.key=tls-openssl-elasticsearch-server.key
kubectl -n kongyu describe secret tls-openssl-elasticsearch

## cfssl方式
kubectl -n kongyu create secret generic tls-cfssl-elasticsearch \
  --from-file=ca.crt=tls-cfssl-ca.pem \
  --from-file=tls.crt=tls-cfssl-elasticsearch-server.pem \
  --from-file=tls.key=tls-cfssl-elasticsearch-server-key.pem
kubectl -n kongyu describe secret tls-cfssl-elasticsearch
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass
>
> [插件下载地址](https://artifacts.elastic.co/downloads/elasticsearch-plugins)

```
cat values.yaml
```

创建标签，运行在标签节点上

```
kubectl label nodes server02.lingo.local kubernetes.service/elasticsearch="true"
kubectl label nodes server03.lingo.local kubernetes.service/elasticsearch="true"
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
## openssl方式
curl \
    --cacert tls-openssl-ca.crt \
    -u elastic:Admin@123 \
    https://192.168.1.10:31509

## cfssl方式
curl \
    --cacert tls-cfssl-ca.pem \
    -u elastic:Admin@123 \
    https://192.168.1.10:25454
```

删除服务以及数据

```
helm uninstall -n kongyu elasticsearch
kubectl delete -n kongyu pvc data-elasticsearch-data-{0..1} data-elasticsearch-master-{0..1}
```

