# Java应用

使用Kubernetes运行Java应用

- [构建镜像](/work/docker/dockerfile/java/)



## 原生镜像

使用JDK镜像，然后将Jar文件放到HTTP服务器上，通过busybox初始化容器下载到emptyDir中，最后自定义运行参数实现动态容器化Java应用的运行。

**上传到HTTP**

例如jar包 `springboot3-demo-v1.0.jar` 上传到HTTP服务器，最终路径为：`http://192.168.1.12:9000/test/spring/demo/integrated/springboot3-demo-v1.0.jar`

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
kubectl apply -n kongyu -f deploy-native.yaml
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
kubectl delete -n kongyu -f deploy-native.yaml
```



## 应用和镜像一体-命令

使用JDK镜像，并且Java应用在镜像中，通过设置运行参数实现动态容器化Java应用的运行。

**配置修改**

- 修改应用名称：全局替换`spring-app`
- `containers`容器的环境变量、resources、探针、亲和性等

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/spring-app="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy-integrated-cmd.yaml
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
kubectl delete -n kongyu -f deploy-integrated-cmd.yaml
```



## 应用和镜像一体-脚本

使用JDK镜像，并且Java应用在镜像中，通过设置环境变量自定义运行参数实现容器化Java应用的运行。

**配置修改**

- 修改应用名称：全局替换`spring-app`
- `containers`容器的环境变量、resources、探针、亲和性等

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/spring-app="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy-integrated-shell.yaml
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
kubectl delete -n kongyu -f deploy-integrated-shell.yaml
```



## 应用和镜像分离

使用JDK镜像使用脚本 `docker-entrypoint.sh` 启动应用。将Jar文件挂载到容器内部，设置环境变量自定义运行参数实现动态容器化Java应用的运行。

**上传到HTTP**

例如jar包 `springboot3-demo-v1.0.jar` 上传到HTTP服务器，最终路径为：`http://192.168.1.12:9000/test/spring/demo/integrated/springboot3-demo-v1.0.jar`

**配置修改**

- 修改应用名称：全局替换`spring-app`
- `initContainers`容器的下载jar包命令根据环境修改

- `containers`容器的环境变量、resources、探针、亲和性等

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



## 应用和镜像(源码依赖分离)分离

开发文档参考：[源码依赖分离](https://atengk.github.io/dev/#/work/Ateng-Java/springboot3/doc/separate)

使用JDK镜像，然后将Jar文件和依赖放到HTTP服务器上，通过busybox初始化容器下载到PVC中，最后自定义运行参数实现动态容器化Java应用的运行。

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
kubectl apply -n kongyu -f deploy-separate-lib.yaml
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
kubectl delete -n kongyu -f deploy-separate-lib.yaml
```



