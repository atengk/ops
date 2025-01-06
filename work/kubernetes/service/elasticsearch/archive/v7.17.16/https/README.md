# 安装ElasticSearch集群

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

下载证书

```
# 1. 获取 Base64 编码的证书内容
kubectl get secret elasticsearch-coordinating-crt -n kongyu -o jsonpath='{.data.tls\.crt}' | base64 -d > tls.crt

# 2. 下载私钥文件
kubectl get secret elasticsearch-coordinating-crt -n kongyu -o jsonpath='{.data.tls\.key}' | base64 -d > tls.key

# 3. 下载 CA 证书文件
kubectl get secret elasticsearch-coordinating-crt -n kongyu -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 4. 查看证书运行访问的域名
openssl x509 -in tls.crt -text -noout | grep -i dns
```

使用服务

```
curl \
    --cacert ca.crt \
    -u elastic:Admin@123 \
    https://elasticsearch.kongyu.svc.cluster.local:9200
```

删除服务以及数据

```
helm uninstall -n kongyu elasticsearch
kubectl delete -n kongyu pvc data-elasticsearch-data-{0..1} data-elasticsearch-master-{0..1}
```

