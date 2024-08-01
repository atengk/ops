# 安装Sentinel

拉取镜像

```
docker pull bladex/sentinel-dashboard:1.8.7
```

推送到本地仓库

```
docker tag m.daocloud.io/docker.io/bladex/sentinel-dashboard:1.8.7 registry.lingo.local/service/sentinel-dashboard:1.8.7
docker push registry.lingo.local/service/sentinel-dashboard:1.8.7
```

创建服务

```
kubectl apply -n lingo-service-dev -f deploy.yaml
```

查看服务

```
kubectl get -n lingo-service-dev pod,svc -l app=sentinel-dashboard
kubectl logs -f -n lingo-service-dev deploy/sentinel-dashboard
```

使用服务

```
URL: http://192.168.1.10:32781/
Username: sentinel
Password: sentinel
```

删除服务以及数据

```
kubectl delete -n lingo-service-dev -f deploy.yaml
```

