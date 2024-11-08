# JumpServer 

JumpServer 是广受欢迎的开源堡垒机，是符合 4A 规范的专业运维安全审计系统。JumpServer 帮助企业以更安全的方式管控和登录所有类型的资产，实现事前授权、事中监察、事后审计，满足等保合规要求。

![index_02](./assets/index_02.png)

JumpServer 堡垒机支持的资产类型包括：

- SSH (Linux / Unix / 网络设备 等)
- Windows (Web 方式连接 / 原生 RDP 连接)
- 数据库 (MySQL / MariaDB / Oracle / SQLServer / PostgreSQL / ClickHouse 等)
- NoSQL (Redis / MongoDB 等)
- GPT (ChatGPT 等)
- 云服务 (Kubernetes / VMware vSphere 等)
- Web 站点 (各类系统的 Web 管理后台)
- 应用 (通过 Remote App 连接各类应用)

参考链接：

- [官网](https://docs.jumpserver.org/zh/v4/)



**依赖服务**

- PostgreSQL
- Redis

**下载chart**

```
wget https://github.com/jumpserver/helm-charts/releases/download/jumpserver-v4.3.1/jumpserver-v4.3.1.tgz
```

**修改配置**

注意修改以下配置，其余配置按需修改：

- PostgreSQL相关信息
- Redis相关信息
- 镜像仓库：global.imageRegistry 和 global.imageOwner
- 存储类：global.storageClass
- core.env.DOMAINS：网站访问链接

```
cat values.yaml
```

**创建服务**

```
helm install jumpserver -n jumpserver --create-namespace -f values.yaml jumpserver-v4.3.1.tgz
```

**查看服务**

```
kubectl get -n jumpserver pod,svc,pvc
```

**查看服务端口**

```
kubectl get svc jumpserver-jms-web -n jumpserver -o jsonpath='{.spec.ports[0].nodePort}'
```

**使用服务**

> 登录后会提示修改密码

```
URL: http://192.168.1.10:30080/
Username: admin
Password: ChangeMe
```

**删除服务以及数据**

```
helm uninstall -n jumpserver jumpserver
kubectl delete pvc -n jumpserver -l app.kubernetes.io/instance=jumpserver
```

