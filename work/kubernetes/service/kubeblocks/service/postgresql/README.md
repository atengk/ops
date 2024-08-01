# 使用 KubeBlocks 管理 PostgreSQL 服务

以下步骤将指导您如何使用 KubeBlocks 和 `kbcli` 工具来管理 PostgreSQL 服务。

https://cn.kubeblocks.io/docs/preview/user-docs/kubeblocks-for-postgresql/cluster-management/create-and-connect-a-pg-cluster

### 1. 查看服务版本

要查看当前 PostgreSQL 服务的版本信息，使用以下命令：
```sh
kbcli clusterversion list --cluster-definition=postgresql
```

### 2. 创建服务

使用 Kubernetes 配置文件创建 PostgreSQL 服务。确保 `cluster.yaml` 文件已正确配置。
```sh
kubectl apply -f cluster.yaml
```

设置时区

```
kbcli cluster -n kongyu configure pg-cluster \
  --set=timezone=Asia/Shanghai
```

### 3. 查看服务状态

#### 查看日志
查看 PostgreSQL 服务的实时日志：
```sh
kbcli cluster -n kongyu logs -f pg-cluster
```

#### 列出服务
列出 PostgreSQL 集群的所有服务：
```sh
kbcli cluster -n kongyu list pg-cluster
```

#### 描述服务
获取 PostgreSQL 集群的详细信息：
```sh
kbcli cluster -n kongyu describe pg-cluster
```

#### 查看资源
查看指定命名空间下的 Pod、服务和 PVC 的详细信息：

> 连接使用端口是**6432(tcp-pgbouncer)**

```sh
kubectl get -n kongyu pod,svc,pvc -o wide
```

### 4. 创建用户

https://cn.kubeblocks.io/docs/preview/user-docs/user-management/manage-user-accounts

获取 PostgreSQL 服务的连接密码，使用以下命令：
```sh
kbcli cluster -n kongyu connect --show-example --client=java --show-password pg-cluster
```

创建账户

```
kbcli cluster -n kongyu create-account pg-cluster --name kongyu --password Admin@123
```

授予角色

```
kbcli cluster -n kongyu grant-role pg-cluster --name dba --role Superuser
kbcli cluster -n kongyu grant-role pg-cluster --name kongyu --role ReadWrite
kbcli cluster -n kongyu grant-role pg-cluster --name anonymous --role ReadOnly
```

列出所有账户

```
kbcli cluster -n kongyu list-accounts pg-cluster
```



### 5. 访问服务

使用 `kbcli` 连接到 PostgreSQL 服务：
```sh
kbcli cluster -n kongyu connect pg-cluster
```

### 6. 管理服务

#### 重启服务
重启 PostgreSQL 服务：
```sh
kbcli cluster -n kongyu restart pg-cluster
```

#### 停止服务
停止 PostgreSQL 服务：
```sh
kbcli cluster -n kongyu stop pg-cluster
```

#### 启动服务
启动已停止的 PostgreSQL 服务：
```sh
kbcli cluster -n kongyu start pg-cluster
```

#### 删除服务
删除 PostgreSQL 服务：
```sh
kbcli cluster -n kongyu delete pg-cluster
```
删除数据：
```sh
kubectl delete -n kongyu pvc -l app.kubernetes.io/component=postgresql
```

---

以上步骤将帮助您使用 KubeBlocks 和 `kbcli` 工具来创建、管理和访问 PostgreSQL 服务。如果在使用过程中遇到任何问题，请参考 KubeBlocks 的[官方文档](https://cn.kubeblocks.io/docs/preview/user-docs/kubeblocks-for-postgresql/apecloud-postgresql-intro/)获取更多信息。