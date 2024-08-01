# Nacos

一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。



## 导入SQL

使用MySQL数据库，创建名称为**nacos**的数据库，然后将**mysql-schema.sql**导入进去



## 修改配置文件

修改**deploy-nacos.yaml**配置文件中的**ConfigMap**，其中数据库相关的信息和JVM相关信息

如果需要修改**Service**的端口映射，那么需要保证server和client-rpc是加1000的关系



## 安装

安装在**kongyu**命名空间

> 可以直接伸缩节点

```
kubectl apply -f deploy-nacos.yaml
```



## 查看

```
URL：http://192.168.1.101:30848/nacos
Username: nacos
Password: nacos
```

