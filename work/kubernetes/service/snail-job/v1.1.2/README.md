# 安装Snail Job

拉取镜像

```
docker pull opensnail/snail-job:1.1.2
```

推送到本地仓库

```
docker tag opensnail/snail-job:1.1.2 registry.lingo.local/service/snail-job:1.1.2
docker push registry.lingo.local/service/snail-job:1.1.2
```

创建数据库并导入SQL

```
https://github.com/aizuda/snail-job/raw/vsj1.1.2/doc/sql/snail_job_mysql.sql
https://github.com/aizuda/snail-job/raw/vsj1.1.2/doc/sql/snail_job_postgre.sql
```

创建服务

```
kubectl apply -n lingo-service-dev -f deploy.yaml
```

查看服务

```
kubectl get -n lingo-service-dev pod,svc -l app=snail-job
kubectl logs -f -n lingo-service-dev deploy/snail-job
```

使用服务

```
URL: http://192.168.1.10:32781/snail-job/
Username: admin
Password: admin
```

删除服务以及数据

```
kubectl delete -n lingo-service-dev -f deploy.yaml
```

