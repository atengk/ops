# elasticsearch-head 

ElasticSearch 的web前端

- [官网链接](https://github.com/mobz/elasticsearch-head/tree/master)

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app=elasticsearch-head
kubectl logs -n kongyu -f deploy/elasticsearch-head
```

**访问服务**

详情参考：[官方文档](https://github.com/mobz/elasticsearch-head/tree/master?tab=readme-ov-file#url-parameters)

无认证的访问：

http://192.168.1.10:23204/?base_uri=http://192.168.1.10:26793/&dashboard=cluster

有认证的访问：

http://192.168.1.10:23204/?base_uri=http://dev.es.lingo.local/&auth_user=elastic&auth_password=Admin@123

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```

