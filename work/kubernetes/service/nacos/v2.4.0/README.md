# K8S安装Nacos集群

https://nacos.io/docs/latest/what-is-nacos/

https://github.com/alibaba/nacos

一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。

**拉取镜像**

```
docker pull nacos/nacos-server:v2.4.0.1
docker pull nacos/nacos-peer-finder-plugin:1.1
```

**导入SQL**

使用MySQL数据库，创建名称为**nacos**的数据库，然后将**mysql-schema.sql**导入进去

```
curl -L -O https://raw.githubusercontent.com/alibaba/nacos/2.4.0/distribution/conf/mysql-schema.sql
```

**修改配置文件**

修改**deploy-nacos.yaml**配置文件中的**ConfigMap**，其中数据库相关的信息和JVM相关信息

如果需要修改**Service**的NodePort端口映射，那么需要保证server和client-rpc是加1000的关系

**安装**

可以直接伸缩节点

```
kubectl apply -n kongyu -f deploy-nacos.yaml
```

**查看**

```
kubectl get -n kongyu pod,svc
```

**访问**

> 第一次输入的密码为自定义密码

```
URL：http://192.168.1.101:30848/nacos
Username: nacos
Password: Admin@123
```

**删除**

```
kubectl delete -n kongyu -f deploy-nacos.yaml
```

