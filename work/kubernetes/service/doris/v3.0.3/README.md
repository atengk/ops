# Doris3

Apache Doris是一个用于实时分析的现代数据仓库。它提供闪电般快速的实时数据分析。

Doris 存算一体架构包含两个主要模块：

1. **Frontend (FE)**：处理用户请求和管理元数据。
2. **Backend (BE)**：无状态计算节点，执行查询任务。

Doris 存算分离架构包含三个主要模块：

1. **Frontend (FE)**：处理用户请求和管理元数据。
2. **Backend (BE)**：无状态计算节点，执行查询任务。
3. **Meta Service (MS)**：管理元数据操作和数据回收。

参考链接：

- [官网地址](https://doris.apache.org/zh-CN/docs/3.0/compute-storage-decoupled/overview)
- [安装文档](https://doris.apache.org/zh-CN/docs/3.0/install/cluster-deployment/k8s-deploy/compute-storage-decoupled/install-quickstart#%E7%AC%AC3%E6%AD%A5%E9%83%A8%E7%BD%B2%E5%AD%98%E7%AE%97%E5%88%86%E7%A6%BB%E9%9B%86%E7%BE%A4)



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



## 创建存算分离集群

### 创建集群

**创建命名空间**

```
kubectl create ns ateng-doris-ddr
```

**创建节点用户密码信息**

创建节点用户，管理集群节点，后续修改这个用户密码也需要在改秘钥中对应修改（尽量不要动这个用户了）

```
kubectl create -n ateng-doris-ddr secret generic doris-auth \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=doris \
  --from-literal=password=Doris@2024
```

**修改配置**

可以根据需求适当修改 `ddc.yaml`

```
cat ddc.yaml
```

**创建集群**

```
kubectl apply -n ateng-doris-ddr -f ddc.yaml
```

### 访问集群

**查看集群**

```
kubectl get -n ateng-doris-ddr pod,svc,pvc
kubectl get -n ateng-doris-ddr ddc
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
mysql -uroot -P9030 -hdoris-cluster-fe.ateng-doris-ddr
```

查看计算组

```
mysql> SHOW COMPUTE GROUPS;
+------+-----------+-------+------------+
| Name | IsCurrent | Users | BackendNum |
+------+-----------+-------+------------+
| cg1  | TRUE      |       | 3          |
+------+-----------+-------+------------+
```

### 设置用户密码

设置root用户密码

> 3.0.3版本不要修改root密码，虽然我设置了 `DorisDisaggregatedCluster.spec.authSecret` ，但是不起作用，BE还是用的root用户，改了就会导致BE导致无法连接FE然后服务挂掉。等待后续版本解决这个问题。
>
> 经过排查，发现是计算组的服务没有将秘钥doris-auth挂载上去，而FE就挂载上了，并且存算一体的也挂载上了的，所以就是导致使用了默认的root用户作为节点用户。猜测应该是DorisDisaggregatedCluster这个API的问题，等待后续优化吧。
>
> 临时解决在computeGroups里面添加环境变量：USER=doris,PASSWD=Doris@2024

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

### 创建存储后端

创建 S3 Storage Vault

> Minio安装文档参考：[地址](/work/kubernetes/service/minio/v2024.11.7/distributed/)

```
CREATE STORAGE VAULT IF NOT EXISTS minio_vault
    PROPERTIES (
    "type"="S3",
    "s3.endpoint"="http://192.168.1.13:9000",
    "s3.access_key" = "admin",
    "s3.secret_key" = "Lingo@local_minio_9000",
    "s3.region" = "us-east-1",
    "s3.root.path" = "ateng-doris/",
    "s3.bucket" = "doris",
    "use_path_style" = "true",
    "provider" = "S3"
    );
```

设置默认 Storage Vault

```
SET minio_vault AS DEFAULT STORAGE VAULT;
```

查看 Storage Vault

```
SHOW STORAGE VAULTS\G;
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

### 删除存算分离集群

删除集群

```
kubectl delete -n ateng-doris-ddr -f ddc.yaml
```

删除数据

```
kubectl delete pvc -n ateng-doris-ddr -l app.doris.disaggregated.cluster=doris-cluster
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

