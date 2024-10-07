# Kubernetes



## 用户权限

### 创建用户并导出kubeconfig

**创建 cloud-qijiang-admin.sh 脚本并执行**

Kubernetes 1.24及以上的方式

```shell
# 设置账户名称
export K8S_UserName=cloud-qijiang-admin
# 设置集群名称
export K8S_ClusterName=aliyun.com
# 设置集群地址
export K8S_API=https://47.108.39.131:6443
# 设置账户所在的命名空间
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

Kubernetes 1.24以下的方式

```shell
# 设置账户名称
export K8S_UserName=local-ateng-admin
# 设置集群名称
export K8S_ClusterName=lingo.local
# 设置集群地址
export K8S_API=https://192.168.1.18:6443
# 设置账户所在的命名空间
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

**使用kubeconfig**

```
kubectl --kubeconfig=kubeconfig-cloud-qijiang-admin.yaml get pods
```

