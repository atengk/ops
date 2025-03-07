# SpringBoot应用



## JDK和JAR分离

JDK镜像制作参考文档：[构建JDK21容器镜像](/work/docker/dockerfile/java/debian/jdk21/)

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



## JDK和JAR一体

Springboot Jar镜像制作参考文档：[构建Jar容器镜像](/work/docker/dockerfile/java/debian/application/jdk21-cmd/)

**配置修改**

- 修改应用名称：全局替换`spring-app`
- `containers`容器的启动参数、resources、探针、亲和性等

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/spring-app="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy-integrated.yaml
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
kubectl delete -n kongyu -f deploy-integrated.yaml
```



## JDK和JAR(源码依赖分离)分离

开发文档参考：[源码依赖分离](https://kongyu666.github.io/dev/#/work/Ateng-Java/springboot3/doc/separate)

**上传到HTTP**

jar包 `springboot3-demo-v1.0.jar` 上传到HTTP服务器，最终路径为：`http://192.168.1.12:9000/test/spring/springboot3-demo-v1.0.jar`

依赖包 `lib.zip` 上传到HTTP服务器，最终路径为：`http://192.168.1.12:9000/test/spring/demo/lib.zip`

**配置修改**

- 修改应用名称：全局替换`spring-app`
- `initContainers`容器的下载jar包和依赖包命令根据环境修改

- `containers`容器的启动参数、resources、探针、亲和性等

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/spring-app="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy-separate.yaml
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
kubectl delete -n kongyu -f deploy-separate.yaml
```



