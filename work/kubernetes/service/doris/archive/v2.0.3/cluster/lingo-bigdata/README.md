# 安装Doris

Apache Doris是一个用于实时分析的现代数据仓库。
它提供闪电般快速的实时数据分析。

https://doris.apache.org/zh-CN/docs/get-starting/quick-start/

FE（Frontend）：FE 是 Apache Doris 的前端服务，负责接收用户的查询请求，解析和优化查询语句，并将查询任务分发给后端的 BE（Backend） 服务执行。

BE（Backend）：BE 是 Apache Doris 的后端服务，负责实际执行查询任务和计算任务，读取数据并返回结果给 FE。BE 负责与存储引擎交互，执行查询计划。

CN（Coordinator Node）：CN 是 Apache Doris 的协调节点，负责协调整个集群的元数据管理，包括元数据的存储和维护、负载均衡、集群拓扑的管理等。

Broker：Broker 是 Apache Doris 的代理节点，负责查询请求的路由和负载均衡。Broker 接收 FE 发来的查询请求，并根据集群状态和负载情况将请求路由到对应的 BE 服务节点上执行。



## 安装operator

创建服务

```
kubectl apply -f doris-crd.yaml
kubectl apply -f doris-operator.yaml
```

查看服务

```
kubectl get -n doris pod
kubectl get DorisCluster -A
```



## 安装Doris

修改配置

> values-doris.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values-doris.yaml
```

创建服务

```
helm install doris -n lingo-bigdata -f values-doris.yaml doris-1.4.0.tgz
```

查看服务

```
kubectl get -n lingo-bigdata pod -l app=doris
kubectl logs -f -n lingo-bigdata doris-fe-0
```

访问服务

```
export CLUSTER_IP="$(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')"
export SERVICE_HTTP_PORT="$(kubectl get service doris-fe-service -n lingo-bigdata -o=jsonpath='{.spec.ports[?(@.name=="http-port")].nodePort}')"
export SERVICE_QUERY_PORT="$(kubectl get service doris-fe-service -n lingo-bigdata -o=jsonpath='{.spec.ports[?(@.name=="query-port")].nodePort}')"
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
kubectl exec -it -n lingo-bigdata doris-fe-0 -- mysql -h127.0.0.1 -P9030 -uroot
```

修改root密码

```
# 设置root用户密码
SET PASSWORD FOR 'root'@'%' = PASSWORD('Admin@12345');

# 设置admin用户密码
SET PASSWORD FOR 'admin'@'%' = PASSWORD('Admin@12345');

# 创建普通用户
create database lingo-bigdata;
create user lingo-bigdata identified by 'lingo-bigdata';
grant all on lingo-bigdata.* to lingo-bigdata;

# 查看所有用户权限
SHOW ALL GRANTS;
```

更新服务

```
helm upgrade doris -n lingo-bigdata \
    -f values-doris.yaml \
    --set dorisCluster.adminUser.name=root \
    --set dorisCluster.adminUser.password=Admin@12345 \
    doris-1.4.0.tgz
```

查看服务

```
kubectl get -n lingo-bigdata pod -l app=doris
kubectl logs -f -n lingo-bigdata doris-fe-0
kubectl logs -f -n lingo-bigdata doris-be-0
```



## 删除Doris

删除应用

```
helm uninstall doris -n lingo-bigdata
```

删除pvc

```
kubectl delete pvc -n lingo-bigdata fe-meta-doris-fe-{0..2} be-storage-doris-be-{0..2}
```

删除operator

```
kubectl delete -f doris-operator.yaml
kubectl delete -f doris-crd.yaml
```

