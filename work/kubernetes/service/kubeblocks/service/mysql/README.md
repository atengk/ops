# 使用 KubeBlocks 管理 MySQL 服务

以下步骤将指导您如何使用 KubeBlocks 和 `kbcli` 工具来管理 MySQL 服务。

https://cn.kubeblocks.io/docs/preview/user-docs/kubeblocks-for-mysql/apecloud-mysql-intro/

### 1. 查看服务版本

要查看当前 MySQL 服务的版本信息，使用以下命令：
```sh
kbcli clusterversion list --cluster-definition=apecloud-mysql
```

### 2. 创建服务

使用 Kubernetes 配置文件创建 MySQL 服务。确保 `cluster.yaml` 文件已正确配置。
```sh
kubectl apply -f cluster.yaml
```

### 3. 查看服务状态

#### 查看日志
查看 MySQL 服务的实时日志：
```sh
kbcli cluster -n kongyu logs -f mysql-cluster
```

#### 列出服务
列出 MySQL 集群的所有服务：
```sh
kbcli cluster -n kongyu list mysql-cluster
```

#### 描述服务
获取 MySQL 集群的详细信息：
```sh
kbcli cluster -n kongyu describe mysql-cluster
```

#### 查看资源
查看指定命名空间下的 Pod、服务和 PVC 的详细信息：
```sh
kubectl get -n kongyu pod,svc,pvc -o wide
```

### 4. 查看密码

获取 MySQL 服务的连接密码，使用以下命令：
```sh
kbcli cluster -n kongyu connect --show-example --client=cli --show-password mysql-cluster
```

### 5. 访问服务

使用 `kbcli` 连接到 MySQL 服务：
```sh
kbcli cluster -n kongyu connect mysql-cluster
```

### 6. 管理服务

#### 重启服务
重启 MySQL 服务：
```sh
kbcli cluster -n kongyu restart mysql-cluster
```

#### 停止服务
停止 MySQL 服务：
```sh
kbcli cluster -n kongyu stop mysql-cluster
```

#### 启动服务
启动已停止的 MySQL 服务：
```sh
kbcli cluster -n kongyu start mysql-cluster
```

#### 删除服务
删除 MySQL 服务：
```sh
kbcli cluster -n kongyu delete mysql-cluster
```
删除数据：
```sh
kubectl delete -n kongyu pvc -l app.kubernetes.io/component=mysql
```

---

以上步骤将帮助您使用 KubeBlocks 和 `kbcli` 工具来创建、管理和访问 MySQL 服务。如果在使用过程中遇到任何问题，请参考 KubeBlocks 的[官方文档](https://cn.kubeblocks.io/docs/preview/user-docs/kubeblocks-for-mysql/apecloud-mysql-intro/)获取更多信息。