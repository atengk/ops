# 安装Doris

Apache Doris是一个用于实时分析的现代数据仓库。
它提供闪电般快速的实时数据分析。

https://doris.apache.org/zh-CN/docs/get-starting/quick-start/

https://doris.apache.org/zh-CN/docs/install/cluster-deployment/k8s-deploy/install-doris-cluster?_highlight=helm#%E4%BD%BF%E7%94%A8-helm-%E9%83%A8%E7%BD%B2

https://artifacthub.io/packages/helm/doris/doris

FE（Frontend）：FE 是 Apache Doris 的前端服务，负责接收用户的查询请求，解析和优化查询语句，并将查询任务分发给后端的 BE（Backend） 服务执行。

BE（Backend）：BE 是 Apache Doris 的后端服务，负责实际执行查询任务和计算任务，读取数据并返回结果给 FE。BE 负责与存储引擎交互，执行查询计划。

CN（Coordinator Node）：CN 是 Apache Doris 的协调节点，负责协调整个集群的元数据管理，包括元数据的存储和维护、负载均衡、集群拓扑的管理等。

Broker：Broker 是 Apache Doris 的代理节点，负责查询请求的路由和负载均衡。Broker 接收 FE 发来的查询请求，并根据集群状态和负载情况将请求路由到对应的 BE 服务节点上执行。

## 下载Chart

添加存储库

```
helm repo add doris-repo https://charts.selectdb.com
helm repo update doris-repo
```

查看版本

```
helm search repo doris
```

下载Chart

```
helm pull doris-repo/doris --version 1.6.0
helm pull doris-repo/doris-operator --version 1.6.0
```



## 安装Operator

创建服务

> 安装doris-operator(在名为doris的名称空间中使用默认配置)

```
helm install doris-operator -n doris --create-namespace -f values-operator.yaml doris-operator-1.6.0.tgz
```

查看服务

```
kubectl get -n doris pod
```



## 安装Doris

修改配置

> values-doris.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values-doris.yaml
```

创建服务

```
helm install doris -n kongyu -f values-doris.yaml doris-1.6.0.tgz
```

查看服务

```
kubectl get -n kongyu pod -l app=doris
kubectl logs -f -n kongyu doris-fe-0
```

查看集群

```
kubectl get DorisCluster -A
```

访问服务

```
export CLUSTER_IP="$(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')"
export SERVICE_HTTP_PORT="$(kubectl get service doris-fe-service -n kongyu -o=jsonpath='{.spec.ports[?(@.name=="http-port")].nodePort}')"
export SERVICE_QUERY_PORT="$(kubectl get service doris-fe-service -n kongyu -o=jsonpath='{.spec.ports[?(@.name=="query-port")].nodePort}')"
```

```
echo "Http Address: http://${CLUSTER_IP}:${SERVICE_HTTP_PORT}"
echo "SQL Query Address: ${CLUSTER_IP}:${SERVICE_QUERY_PORT}"
echo "Username: root"
echo "Password: Admin@123"
```



## 修改密码

> 如果需要修改root密码，进入FE修改完后需要重新修改配置，最后更新服务
>
> 不需要修改root密码就跳过此步骤

进入FE

```
kubectl exec -it -n kongyu doris-fe-0 -- mysql -h127.0.0.1 -P9030 -uroot
```

修改root密码

```
# 设置root用户密码
SET PASSWORD FOR 'root'@'%' = PASSWORD('Admin@12345');

# 设置admin用户密码
SET PASSWORD FOR 'admin'@'%' = PASSWORD('Admin@12345');

# 创建普通用户
create database kongyu;
create user kongyu identified by 'kongyu';
grant all on kongyu.* to kongyu;

# 查看所有用户权限
SHOW ALL GRANTS;
```

更新服务

```
helm upgrade doris -n kongyu \
    -f values-doris.yaml \
    --set dorisCluster.adminUser.name=root \
    --set dorisCluster.adminUser.password=Admin@12345 \
    doris-1.6.0.tgz
```

查看服务

```
kubectl get -n kongyu pod -l app=doris
kubectl logs -f -n kongyu doris-fe-0
kubectl logs -f -n kongyu doris-be-0
```



## 删除Doris

删除应用

```
helm uninstall doris -n kongyu
```

删除pvc

```
kubectl delete pvc -n kongyu -l app.kubernetes.io/component=fe
kubectl delete pvc -n kongyu -l app.kubernetes.io/component=be
```

删除operator

```
helm uninstall doris-operator -n doris
```

