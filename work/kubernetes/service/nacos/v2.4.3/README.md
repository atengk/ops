# Nacos

Nacos（"Dynamic Naming and Configuration Service"）是一个开源的动态服务发现、配置管理和服务管理平台，主要用于云原生应用和微服务架构中。它由阿里巴巴开源，旨在帮助开发者构建灵活、高可用的分布式系统。

Nacos通常与微服务架构中的其他组件一起使用，像是 Spring Cloud、Dubbo 等，成为分布式系统中服务治理和配置管理的重要一环。

- [官方文档](https://nacos.io/docs/v2.4/overview/)

- [GitHub](https://github.com/alibaba/nacos)



**导入SQL**

下载SQL文件，将SQL导入MySQL中。

```
curl -L -O https://raw.githubusercontent.com/alibaba/nacos/2.4.3/distribution/conf/mysql-schema.sql
```

**自定义配置**

修改deploy.yaml配置文件

- 资源配置：StatefulSet中的resources相关参数
- 配置文件：ConfigMap中的数据库和JVM等相关信息
- 服务端口：如果需要修改**Service**的NodePort端口映射，那么需要保证server和client-rpc是加1000的关系


- 其他：其他配置按照具体环境修改

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/nacos="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=nacos
```

**查看日志**

```java
kubectl logs -f --tail=200 -n kongyu nacos-0
```

**访问服务**

```
URL：http://192.168.1.10:30648/nacos
Username: nacos
Password: Admin@123
```

输入自定义密码

![image-20250307150322629](./assets/image-20250307150322629.png)

**服务扩缩容**

```
kubectl scale statefulset nacos --replicas=3 -n kongyu
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```

