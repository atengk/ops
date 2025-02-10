# **Elasticvue** 

Elasticvue是一个免费的开源elasticsearch gui

- [官网链接](https://elasticvue.com/)

**下载镜像**

```
docker pull cars10/elasticvue:1.4.0
```

**推送到仓库**

```
docker tag cars10/elasticvue:1.4.0 registry.lingo.local/service/elasticvue:1.4.0
docker push registry.lingo.local/service/elasticvue:1.4.0
```

**保存镜像**

```
docker save registry.lingo.local/service/elasticvue:1.4.0 | gzip -c > image-elasticvue_1.4.0.tar.gz
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app=elasticvue
kubectl logs -n kongyu -f deploy/elasticvue
```

**访问服务**

```
URL: http://192.168.1.10:28948/
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```

