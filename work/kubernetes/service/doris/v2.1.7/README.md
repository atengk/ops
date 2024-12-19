# Doris2

Apache Doris 是一个用于实时分析的现代数据仓库。它可以对大规模实时数据进行闪电般的快速分析。

Apache Doris 的**整体架构**：

- **Frontend（FE）**：主要负责用户请求的接入、查询解析规划、元数据的管理、节点管理相关工作。
- **Backend（BE）**：主要负责数据存储、查询计划的执行。

这两类进程都是可以横向扩展的，单集群可以支持到数百台机器，数十 PB 的存储容量。并且这两类进程通过一致性协议来保证服务的高可用和数据的高可靠。这种高度集成的架构设计极大地降低了一款分布式系统的运维成本。

- [官网链接](https://doris.apache.org/zh-CN/docs/install/cluster-deployment/standard-deployment)



## 安装Operator

**下载配置文件**

- 下载crd：[下载地址](https://github.com/apache/doris-operator/blob/release-24.1.0/config/crd/bases/crds.yaml)
- 下载operator：[下载地址](https://github.com/apache/doris-operator/blob/release-24.1.0/config/operator/disaggregated-operator.yaml)

**安装CRD**

```
kubectl create -f crds.yaml
```

**安装Operator**

这里修改了以下配置

- 修改了镜像地址

```
kubectl apply -f disaggregated-operator.yaml
```

**查看Operator**

```
kubectl get -n doris pod
kubectl logs -f -n doris deploy/doris-operator
```



## 创建存算一体集群

### 创建集群

**创建标签，运行在标签节点上**

```
kubectl label nodes server02.lingo.local kubernetes.service/doris="true"
kubectl label nodes server03.lingo.local kubernetes.service/doris="true"
```

**创建命名空间**

```
kubectl create ns ateng-doris-dcr
```

**创建节点用户密码信息**

创建节点用户，管理集群节点，后续修改这个用户密码也需要在改秘钥中对应修改（尽量不要动这个用户了）

```
kubectl create -n ateng-doris-dcr secret generic doris-auth \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=doris \
  --from-literal=password=Doris@2024
```

**修改配置**

可以根据需求适当修改 `dcr.yaml`

- FE节点
    - doris-fe-configmap：FE的配置文件
    - DorisCluster.spec.fe.spec.replicas: 配置FE节点数量
    - DorisCluster.spec.fe.spec.limits requests: FE节点的资源配置
    - DorisCluster.spec.fe.spec.persistentVolumes: 存储类

- BE节点

    - doris-be-configmap：BE的配置文件

    - DorisCluster.spec.be.spec.replicas: 配置BE节点数量

    - DorisCluster.spec.be.spec.limits requests: BE节点的资源配置

    - DorisCluster.spec.be.spec.persistentVolumes: 存储类

```
cat dcr.yaml
```

**创建集群**

```
kubectl apply -n ateng-doris-dcr -f dcr.yaml
```

### 访问集群

**查看集群**

```
kubectl get -n ateng-doris-dcr pod,svc,pvc
kubectl get -n ateng-doris-dcr dcr
```

**访问服务**

进入mysql客户端

```
kubectl run mysql-client \
  --rm --tty -i --restart='Never' \
  --image  registry.lingo.local/service/mysql:8.4.3 \
  --command -- bash
```

进入Doris FE

```
mysql -uroot -P9030 -hdoris-cluster-fe-service.ateng-doris-dcr
```

查看节点

```
show frontends\G;
show backends\G;
```

### 设置用户密码

设置root用户密码

```
SET PASSWORD FOR 'root'@'%' = PASSWORD('Admin@123');
```

设置admin用户密码

```
SET PASSWORD FOR 'admin'@'%' = PASSWORD('Admin@123');
```

创建普通用户

```
create database kongyu;
create user kongyu identified by 'kongyu';
grant all on kongyu.* to kongyu;
```

查看所有用户权限

```
SHOW ALL GRANTS;
```

### 创建数据

创建表

```
CREATE TABLE IF NOT EXISTS kongyu.user_info (
    id INT NOT NULL,
    name STRING,
    age INT,
    city STRING
)
DISTRIBUTED BY HASH(id) BUCKETS 4
PROPERTIES (
    "replication_num" = "1"
);
```

插入数据

```
INSERT INTO kongyu.user_info (id, name, age, city) VALUES
    (2, 'Bob', 30, 'Shanghai'),
    (3, 'Charlie', 28, 'Guangzhou'),
    (4, 'David', 35, 'Shenzhen');
```

查询数据

```
SELECT * FROM kongyu.user_info;
```

### 使用服务

**使用HTTP**

端口是 `service/doris-cluster-fe-service` 的 8030 端口的nodePort

```
URL: http://192.168.1.10:36055
Username: admin
Password: Admin@123
```

**使用mysql协议**

端口是 `service/doris-cluster-fe-service` 的 9030 端口的nodePort

```
Address: 192.168.1.10:29291
Username: admin
Password: Admin@123
```

例如使用mysql客户端：`mysql -uadmin -pAdmin@123 -h192.168.1.10 -P29291`



## 删除服务

### 删除存算一体集群

删除集群

```
kubectl delete -n ateng-doris-dcr -f dcr.yaml
```

删除数据

```
kubectl delete pvc -n ateng-doris-dcr -l app.kubernetes.io/component=be
kubectl delete pvc -n ateng-doris-dcr -l app.kubernetes.io/component=fe
```

### 删除Operator

删除Operator

```
kubectl delete -f disaggregated-operator.yaml
```

删除CRD

```
kubectl delete -f crds.yaml
```

