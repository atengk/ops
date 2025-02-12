# PowerJob

全新一代分布式任务调度与计算框架

参考：[官方文档](http://www.powerjob.tech/)



**自定义配置**

修改deploy.yaml配置文件

- 配置文件修改：ConfigMap中的application.yml根据实际需求修改，最好使用MySQL数据库
- 资源配置：Deployment中的resources相关参数
- args参数：其中powerjob.network.external.*的配置要为实际访问的地址信息


- 其他：其他配置按照具体环境修改

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/powerjob-server="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=powerjob-server
```

**查看日志**

```
kubectl logs -f --tail=200 -n kongyu deploy/powerjob-server
```

**访问服务**

```
akka: 192.168.1.10:32122
URL: http://192.168.1.10:32121
Username: ADMIN
Password: powerjob_admin
```

**高可用配置**

可以动态扩缩容来实现服务的高可用性

```
kubectl scale -n kongyu deployment powerjob-server --replicas=3
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```

