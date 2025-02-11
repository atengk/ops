# Snail Job

🚀 灵活，可靠和快速的分布式任务重试和分布式任务调度平台

参考链接：

- [官网](https://snailjob.opensnail.com/)
- [DockerHub](https://hub.docker.com/r/opensnail/snail-job)



**下载SQL**

[更多sql下载地址](https://gitee.com/aizuda/snail-job/tree/master/doc/sql)

- MySQL：https://gitee.com/aizuda/snail-job/raw/master/doc/sql/snail_job_mysql.sql
- PostgreSQL：https://gitee.com/aizuda/snail-job/raw/master/doc/sql/snail_job_postgre.sql

**导入SQL**

将下载后的SQL导入到对应的数据库中

**自定义配置**

修改deploy.yaml配置文件

- 数据库配置：修改环境变量PARAMS为实际的数据库信息


- 其他：其他配置按照具体环境修改

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=snail-job
```

**查看日志**

```
kubectl logs -n kongyu -f --tail=100 deploy/snail-job
```

**查看服务端口**

```
kubectl get svc snail-job -n kongyu -o jsonpath='{.spec.ports[0].nodePort}'
```

**访问服务**

```
Netty: 192.168.1.10:32682
URL: http://192.168.1.10:32681/snail-job/
Username: admin
Password: admin
```

进入后输入初始的账号密码，然后再修改

![image-20241119112716727](./assets/image-20241119112716727.png)

![image-20241119112800806](./assets/image-20241119112800806.png)

**高可用配置**

可以动态扩缩容来实现服务的高可用性

```
kubectl scale -n kongyu deployment snail-job --replicas=3
```

![image-20241119113407521](./assets/image-20241119113407521.png)

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```

