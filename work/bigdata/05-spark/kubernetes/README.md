# 安装Spark3



## 基础环境配置

解压软件包

```
tar -zxvf spark-3.5.0-bin-hadoop3.tgz -C /usr/local/software/
ln -s /usr/local/software/spark-3.5.0-bin-hadoop3 /usr/local/software/spark
```

配置环境变量

```
cat >> ~/.bash_profile <<"EOF"
## SPARK_HOME
export SPARK_HOME=/usr/local/software/spark
export PATH=$PATH:$SPARK_HOME/bin
EOF
source ~/.bash_profile
```

查看版本

```
spark-shell --version
```



## Spark on Kubernetes

> Spark 可以在 Kubernetes 管理的集群上运行。此功能利用已添加到 Spark 的本机 Kubernetes 调度程序。
>
> https://spark.apache.org/docs/latest/running-on-kubernetes.html

### 创建kubeconfig

创建rbac

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: lingo-bigdata-sa
  namespace: lingo-bigdata
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: lingo-bigdata-cluster-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: lingo-bigdata-cluster-role-binding
subjects:
- kind: ServiceAccount
  name: lingo-bigdata-sa
  namespace: lingo-bigdata
roleRef:
  kind: ClusterRole
  name: lingo-bigdata-cluster-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

创建kubeconfig

```
k8s_lingo_bigdata_secret=$(kubectl get serviceaccount lingo-bigdata-sa -n lingo-bigdata -o jsonpath='{.secrets[0].name}')
k8s_lingo_bigdata_token=$(kubectl get -n lingo-bigdata secret ${k8s_lingo_bigdata_secret} -n lingo-bigdata -o jsonpath='{.data.token}' | base64 -d)
k8s_lingo_bigdata_ca=$(kubectl get secrets -n lingo-bigdata ${k8s_lingo_bigdata_secret} -o "jsonpath={.data['ca\.crt']}")
cat > kubeconfig-lingo-bigdata.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_lingo_bigdata_ca}
    server: https://apiserver.k8s.local:6443
  name: lingo-bigdata
contexts:
- context:
    cluster: lingo-bigdata
    user: lingo-bigdata-sa
    namespace: lingo-bigdata
  name: lingo-bigdata-sa@lingo-bigdata
current-context: lingo-bigdata-sa@lingo-bigdata
preferences: {}
users:
- name: lingo-bigdata-sa
  user:
    token: ${k8s_lingo_bigdata_token}
EOF
```

拷贝kubeconfig和kubectl

> 注意权限

```
ssh admin@192.168.1.131 mkdir -p /home/admin/.kube/
scp kubeconfig-lingo-bigdata.yaml admin@192.168.1.131:/home/admin/.kube/config
scp /usr/bin/kubectl root@192.168.1.131:/usr/bin/kubectl
```

添加hosts映射

```
sudo sh -c 'cat >> /etc/hosts <<EOF
192.168.1.19 apiserver.k8s.local
EOF'
```

查看权限

```
kubectl config get-contexts
```



### 启动应用

spark提交任务到k8s

```
spark-submit \
    --master k8s://https://apiserver.k8s.local:6443 \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.network.timeout=300 \
    --conf spark.kubernetes.driverEnv.myEnv=ateng \
    --conf spark.executorEnv.myEnv=ateng \
    --conf spark.executor.instances=3 \
    --conf spark.driver.cores=2 \
    --conf spark.executor.cores=2 \
    --conf spark.driver.memory=1024m \
    --conf spark.executor.memory=2048m \
    --conf spark.kubernetes.driver.request.cores=100m \
    --conf spark.kubernetes.driver.limit.cores=2 \
    --conf spark.kubernetes.executor.request.cores=100m \
    --conf spark.kubernetes.executor.limit.cores=2 \
    --conf spark.kubernetes.namespace=lingo-bigdata \
    --conf spark.kubernetes.container.image.pullPolicy=IfNotPresent \
    --conf spark.kubernetes.container.image=spark:3.5.0 \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=lingo-bigdata-sa \
    --conf spark.kubernetes.authenticate.executor.serviceAccountName=lingo-bigdata-sa \
    --conf spark.driver.extraJavaOptions="-Dio.netty.tryReflectionSetAccessible=true" \
    --conf spark.executor.extraJavaOptions="-Dio.netty.tryReflectionSetAccessible=true" \
    local:///opt/spark/examples/jars/spark-examples_2.12-3.5.0.jar 10000
```

查看任务状态

```
spark-submit --status lingo-bigdata:spark-pi* --master  k8s://https://apiserver.k8s.local:6443
```

删除任务

```
spark-submit --kill lingo-bigdata:spark-pi* --master  k8s://https://apiserver.k8s.local:6443
```


