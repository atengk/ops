# Kubernetes 使用文档



## 重启应用

**删除 Pod**

```
kubectl delete pod -l app=myapp
```

**滚动重启**

```
kubectl rollout restart <deployment|statefulset|daemonset> <name>
```

**修改 annotation**

```
kubectl patch deployment <deployment-name> \
  -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"kubectl.kubernetes.io/restartedAt\":\"$(date +%Y-%m-%dT%H:%M:%S)\"}}}}}"
```



## 用户和kubeconfig



### 创建普通用户并导出kubeconfig

#### K8s 1.24 +

Kubernetes 1.24及以上的方式

- K8S_UserName: 设置账户名称
- K8S_ClusterName: 设置集群名称，用于区分多个集群的名称
- K8S_API：设置集群地址
- K8S_NameSpace：设置账户所在的命名空间

```shell
export K8S_UserName=ateng-kongyu
export K8S_ClusterName=kubernetes.lingo.aliyun
export K8S_API=https://47.108.39.131:6443
export K8S_NameSpace=ateng-kongyu

kubectl create ns ${K8S_NameSpace}
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
subjects:
- kind: ServiceAccount
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
roleRef:
  kind: Role
  name: ${K8S_UserName}
  apiGroup: rbac.authorization.k8s.io
EOF
k8s_token=$(kubectl create token --duration=8760h -n ${K8S_NameSpace} ${K8S_UserName})
k8s_ca=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
cat > kubeconfig-${K8S_UserName}.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_ca}
    server: ${K8S_API}
  name: ${K8S_ClusterName}
contexts:
- context:
    cluster: ${K8S_ClusterName}
    user: ${K8S_UserName}
    namespace: ${K8S_NameSpace}
  name: ${K8S_UserName}@${K8S_ClusterName}
current-context: ${K8S_UserName}@${K8S_ClusterName}
preferences: {}
users:
- name: ${K8S_UserName}
  user:
    token: ${k8s_token}
EOF
```

#### K8s 1.24 -

Kubernetes 1.24以下的方式

- K8S_UserName: 设置账户名称
- K8S_ClusterName: 设置集群名称，用于区分多个集群的名称
- K8S_API：设置集群地址
- K8S_NameSpace：设置账户所在的命名空间

```shell
export K8S_UserName=ateng-kongyu
export K8S_ClusterName=kubernetes.lingo.local
export K8S_API=https://192.168.1.18:6443
export K8S_NameSpace=ateng-kongyu

kubectl create ns ${K8S_NameSpace}
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${K8S_UserName}-binding
  namespace: ${K8S_NameSpace}
subjects:
- kind: ServiceAccount
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
roleRef:
  kind: Role
  name: ${K8S_UserName}
  apiGroup: rbac.authorization.k8s.io
EOF
k8s_secret=$(kubectl get serviceaccount ${K8S_UserName} -n ${K8S_NameSpace} -o jsonpath='{.secrets[0].name}')
k8s_token=$(kubectl get -n ${K8S_NameSpace} secret ${k8s_secret} -n ${K8S_NameSpace} -o jsonpath='{.data.token}' | base64 -d)
k8s_ca=$(kubectl get secrets -n ${K8S_NameSpace} ${k8s_secret} -o "jsonpath={.data['ca\.crt']}")
cat > kubeconfig-${K8S_UserName}.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_ca}
    server: ${K8S_API}
  name: ${K8S_ClusterName}
contexts:
- context:
    cluster: ${K8S_ClusterName}
    user: ${K8S_UserName}
    namespace: ${K8S_NameSpace}
  name: ${K8S_UserName}@${K8S_ClusterName}
current-context: ${K8S_UserName}@${K8S_ClusterName}
preferences: {}
users:
- name: ${K8S_UserName}
  user:
    token: ${k8s_token}
EOF
```

#### 使用kubeconfig

**使用环境变量**

配置kubeconfig

```
export KUBECONFIG=kubeconfig-${K8S_UserName}.yaml
kubectl config view
```

查看资源

```
kubectl get pod
```

**使用命令行参数**

配置kubeconfig

```
kubectl --kubeconfig=kubeconfig-${K8S_UserName}.yaml config view
```

查看资源

```
kubectl --kubeconfig=kubeconfig-${K8S_UserName}.yaml get pod
```



### 创建admin用户并导出kubeconfig

#### K8s 1.24 +

Kubernetes 1.24及以上的方式

- K8S_UserName: 设置账户名称
- K8S_ClusterName: 设置集群名称，用于区分多个集群的名称
- K8S_API：设置集群地址
- K8S_NameSpace：设置账户所在的命名空间，对于admin用户不需要修改这个配置

```shell
export K8S_UserName=ateng-admin
export K8S_ClusterName=kubernetes.lingo.aliyun
export K8S_API=https://47.108.39.131:6443
export K8S_NameSpace=kube-system

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${K8S_UserName}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${K8S_UserName}
subjects:
- kind: ServiceAccount
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
roleRef:
  kind: ClusterRole
  name: ${K8S_UserName}
  apiGroup: rbac.authorization.k8s.io
EOF
k8s_token=$(kubectl create token --duration=8760h -n ${K8S_NameSpace} ${K8S_UserName})
k8s_ca=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
cat > kubeconfig-${K8S_UserName}.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_ca}
    server: ${K8S_API}
  name: ${K8S_ClusterName}
contexts:
- context:
    cluster: ${K8S_ClusterName}
    user: ${K8S_UserName}
    namespace: ${K8S_NameSpace}
  name: ${K8S_UserName}@${K8S_ClusterName}
current-context: ${K8S_UserName}@${K8S_ClusterName}
preferences: {}
users:
- name: ${K8S_UserName}
  user:
    token: ${k8s_token}
EOF
```

#### K8s 1.24 -

Kubernetes 1.24以下的方式

- K8S_UserName: 设置账户名称
- K8S_ClusterName: 设置集群名称，用于区分多个集群的名称
- K8S_API：设置集群地址
- K8S_NameSpace：设置账户所在的命名空间，对于admin用户不需要修改这个配置

```shell
export K8S_UserName=ateng-admin
export K8S_ClusterName=kubernetes.lingo.local
export K8S_API=https://192.168.1.18:6443
export K8S_NameSpace=kube-system

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${K8S_UserName}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${K8S_UserName}-binding
subjects:
- kind: ServiceAccount
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
roleRef:
  kind: ClusterRole
  name: ${K8S_UserName}
  apiGroup: rbac.authorization.k8s.io
EOF
k8s_secret=$(kubectl get serviceaccount ${K8S_UserName} -n ${K8S_NameSpace} -o jsonpath='{.secrets[0].name}')
k8s_token=$(kubectl get -n ${K8S_NameSpace} secret ${k8s_secret} -n ${K8S_NameSpace} -o jsonpath='{.data.token}' | base64 -d)
k8s_ca=$(kubectl get secrets -n ${K8S_NameSpace} ${k8s_secret} -o "jsonpath={.data['ca\.crt']}")
cat > kubeconfig-${K8S_UserName}.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_ca}
    server: ${K8S_API}
  name: ${K8S_ClusterName}
contexts:
- context:
    cluster: ${K8S_ClusterName}
    user: ${K8S_UserName}
    namespace: ${K8S_NameSpace}
  name: ${K8S_UserName}@${K8S_ClusterName}
current-context: ${K8S_UserName}@${K8S_ClusterName}
preferences: {}
users:
- name: ${K8S_UserName}
  user:
    token: ${k8s_token}
EOF
```

#### 使用kubeconfig

**使用环境变量**

配置kubeconfig

```
export KUBECONFIG=kubeconfig-${K8S_UserName}.yaml
kubectl config view
```

查看资源

```
kubectl get pod
```

**使用命令行参数**

配置kubeconfig

```
kubectl --kubeconfig=kubeconfig-${K8S_UserName}.yaml config view
```

查看资源

```
kubectl --kubeconfig=kubeconfig-${K8S_UserName}.yaml get pod
```



### 常用规则

#### ✅ 获取所有权限（全资源通配符）：

```yaml
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

------

#### ✅ 管理 Pod 的权限：

```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
```

------

#### ✅ 管理 Deployment 的权限：

```yaml
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
```

------

#### ✅ 管理 ConfigMap 和 Secret：

```yaml
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "delete"]
```

------

#### ✅ 管理 Service、Endpoints、Ingress：

```yaml
rules:
- apiGroups: [""]
  resources: ["services", "endpoints"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "create", "update", "delete"]
```

------

#### ✅ 只读权限（适合查看资源）：

```yaml
rules:
- apiGroups: ["", "apps", "batch", "extensions"]
  resources: ["pods", "deployments", "services", "jobs", "cronjobs"]
  verbs: ["get", "list", "watch"]
```

------

#### ✅ 日志访问权限（通过 pod/log）：

```yaml
rules:
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
```

------

#### ✅ 管理命名空间资源（谨慎使用）：

```yaml
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list", "create", "update", "delete"]
```



## 证书过期处理（Kubelet证书过期）

节点的kubelet证书过期处理，需要从控制节点重新生成kubelet.conf配置文件，然后分发到相关节点

假如这里是 k8s-master01 节点的kubelet证书过期，需要按照以下步骤完成证书的更新

**kubelet服务日志现状**

使用命令 `journalctl -f -u kubelet` 查看kubelet，发现有大量的错误日志：

- User \"system:anonymous\" cannot ...
- tls: failed to verify certificate: x509: certificate signed by unknown authority

这些日志说明kubelet证书已过期或者集群的CA证书已更换，这几种情况都可以通过以下步骤完成证书的更新

**查看证书有效期**

从这里可以看到kubelet证书已过期

```
[root@k8s-master01 ~]# openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates
notBefore=Apr  1 00:31:04 2025 GMT
notAfter=Apr  1 00:36:04 2026 GMT
[root@k8s-master01 ~]# date
Fri May  1 12:02:51 AM CST 2026
```

**重新生成kubelet.conf**

在控制节点重新生成kubelet.conf配置文件，--node-name参数需要指定需要更新配置文件的节点名称

```
kubeadm init phase kubeconfig kubelet --node-name k8s-master01 --kubeconfig-dir /tmp
```

分发kubelet.conf

```
scp /tmp/kubelet.conf k8s-master01:/tmp
rm -f /tmp/kubelet.conf
```

**更新kubelet.conf**

在kubelet证书过期的节点更新证书

备份kubelet.conf配置文件

```
mkdir -p /data/backups/kubernetes/config
cp -a /etc/kubernetes/kubelet.conf /data/backups/kubernetes/config/kubelet.conf_$(date +"%Y-%m-%d")
```

在证书过期的节点更新该配置文件

```
mv /tmp/kubelet.conf /etc/kubernetes/kubelet.conf
rm -f /var/lib/kubelet/pki/kubelet-client-current.pem
```

**重新kubelet**

查看现有kubelet证书

```
[root@k8s-master01 ~]# ll /var/lib/kubelet/pki/
total 12
-rw------- 1 root root 2830 Apr  1  2025 kubelet-client-2025-04-01-08-36-09.pem
-rw-r--r-- 1 root root 2295 Apr  1  2025 kubelet.crt
-rw------- 1 root root 1679 Apr  1  2025 kubelet.key
```

重启kubelet服务后，会根据/etc/kubernetes/kubelet.conf配置文件重新生成证书文件

```
systemctl restart kubelet
```

查看现有kubelet证书，重启服务后发现已更新证书

```
[root@k8s-master01 ~]# ll /var/lib/kubelet/pki/
total 20
-rw------- 1 root root 2830 Apr  1  2025 kubelet-client-2025-04-01-08-36-09.pem
-rw------- 1 root root 1118 May  1 00:14 kubelet-client-2026-05-01-00-14-51.pem
lrwxrwxrwx 1 root root   59 May  1 00:14 kubelet-client-current.pem -> /var/lib/kubelet/pki/kubelet-client-2026-05-01-00-14-51.pem
-rw-r--r-- 1 root root 2295 Apr  1  2025 kubelet.crt
-rw------- 1 root root 1679 Apr  1  2025 kubelet.key
```

查看证书有效期，可以看到kubelet证书已续期成功

```
[root@k8s-master01 ~]# openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates
notBefore=Apr 30 16:09:51 2026 GMT
notAfter=Mar 30 00:36:04 2035 GMT
```

**查看日志**

观察日志

```
journalctl -f -u kubelet
```



## 证书过期处理（控制节点证书过期）

在Kubernetes集群中，默认的CA证书是10年有效期，其他服务端和客户端证书的有效期是1年

假如现在控制节点的证书过期了，需要按照以下步骤续期证书

**查看证书有效期**

可以看到证书已过期

```
[root@k8s-master01 ~]# kubeadm certs check-expiration --config=/etc/kubernetes/kubeadm-config.yaml
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver                  Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver-kubelet-client   Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
controller-manager.conf    Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
front-proxy-client         Apr 01, 2026 01:26 UTC   <invalid>       front-proxy-ca          no
scheduler.conf             Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
super-admin.conf           Apr 01, 2026 01:26 UTC   <invalid>       ca                      no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Mar 30, 2035 01:26 UTC   8y              no
front-proxy-ca          Mar 30, 2035 01:26 UTC   8y              no
```

**备份证书**

```
mkdir -p /data/backups/kubernetes/config
cp -a /etc/kubernetes/pki /data/backups/kubernetes/config/pki_$(date +"%Y-%m-%d")
```

**重新生成CA证书（可选）**

如果CA证书也过期了需要执行该步骤重新生成证书

删除旧的证书

```
rm -f /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key
rm -f /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key
```

重新生成 CA 证书

```
kubeadm init phase certs ca
kubeadm init phase certs front-proxy-ca
```

查看 CA 证书，RESIDUAL TIME是9y表示已经重新生成了CA证书

```
[root@k8s-master01 ~]# kubeadm certs check-expiration --config=/etc/kubernetes/kubeadm-config.yaml
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver                  Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver-kubelet-client   Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
controller-manager.conf    Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
front-proxy-client         Apr 01, 2026 01:26 UTC   <invalid>       front-proxy-ca          no
scheduler.conf             Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
super-admin.conf           Apr 01, 2026 01:26 UTC   <invalid>       ca                      no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      May 28, 2036 16:04 UTC   9y              no
front-proxy-ca          May 28, 2036 16:04 UTC   9y              no
```

如果是多个控制节点的集群，需要将 CA 证书分发到其他控制节点上

```
scp /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key k8s-master02:/etc/kubernetes/pki
```

更新 CA 证书到工作节点，更新了CA证书需要将证书同步到其他工作节点上，不然kubelet会报错证书验证失败

```
scp /etc/kubernetes/pki/ca.crt k8s-worker01:/etc/kubernetes/pki
scp /etc/kubernetes/pki/ca.crt k8s-worker02:/etc/kubernetes/pki
```

工作节点更新 CA 证书后需要重启kubelet服务

```
systemctl restart kubelet
journalctl -f -u kubelet
```

如果安装了，需要重启kube-proxy

```
kubectl -n kube-system rollout restart daemonset kube-proxy
```

更新了CA证书后出现的问题可能会有点多，注意查看集群的pod，主要查看kube-proxy和calico-node(网络)等的日志，一般来说重启相关应用就可以了

**手动更新证书**

在控制节点更新服务证书

```
kubeadm certs renew all --config=/etc/kubernetes/kubeadm-config.yaml
```

如果是多个控制节点的集群，需要将 CA 证书分发到其他控制节点上

```
scp /etc/kubernetes/pki/* k8s-master02:/etc/kubernetes/pki
```

**查看证书**

```
kubeadm certs check-expiration --config=/etc/kubernetes/kubeadm-config.yaml
```

**更新用户凭证**

```
rm -rf /root/.kube
mkdir -p /root/.kube && cp -f /etc/kubernetes/admin.conf /root/.kube/config
```

**重启相关服务**

在所有控制节点都需要重启这些服务

```
docker ps -af 'name=k8s_POD_(kube-apiserver|kube-controller-manager|kube-scheduler|etcd)-*' -q | xargs docker rm -f
systemctl restart kubelet
```

**查看日志**

查看kubelet日志

```
sudo journalctl -u kubelet -f
```

查看kube-apiserver日志

> 一般来说 kube-apiserver 能正常启动其他的服务基本上没啥问题
>
> 如果ETCD证书也过期了需要重新生成证书或续期

```
docker ps | grep kube-apiserver
docker logs -f k8s_kube-apiserver_kube-apiserver-k8s-master01_kube-system_e3a07e2b1472dc53e3c339c9aec936e8_22
```

**查看证书过期时间**

```
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout | grep "Not After"
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep "Not After"
openssl x509 -in /etc/kubernetes/pki/apiserver-kubelet-client.crt -text -noout | grep "Not After"
```

**检查pod**

查看pod

```
kubectl get pod -A
```

将异常的pod删除

```
kubectl get pod -A | grep -E "CreateContainerError|CrashLoopBackOff" | awk '{print $1, $2}' | xargs -n 2 kubectl delete pod -n
```

