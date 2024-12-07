# SpringBoot应用

**上传到HTTP**

例如jar包 `springboot3-demo-v1.0.jar` 上传到HTTP服务器，最终路径为：`http://192.168.1.12:9000/test/spring/springboot3-demo-v1.0.jar`

**配置修改**

- 修改应用名称：全局替换`spring-app`
- `initContainers`容器的下载jar包命令根据环境修改

- `containers`容器的启动参数、resources、探针、亲和性等

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/spring-app="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=spring-app
kubectl logs -n kongyu -f --tail=200 deploy/spring-app
```

**访问服务**

```
Address: http://192.168.1.10:30808
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```



