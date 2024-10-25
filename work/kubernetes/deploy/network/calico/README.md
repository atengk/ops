# Calico

Calico 是 Kubernetes 中广泛使用的网络插件，提供高性能的容器网络解决方案。它通过基于 IP 的路由机制实现 Pod 间通信，支持多种模式，如 IPIP（IP in IP）、VXLAN 和直接路由。IPIP 模式用于跨节点通信，将 Pod 流量封装在额外的 IP 层中，解决不同子网间的连通性问题。Calico 还支持网络策略来控制流量的访问，能够集成 Linux 内核的路由功能，适用于多云和混合云环境中的 Kubernetes 集群网络管理。

**下载chart**

```
wget https://github.com/projectcalico/calico/releases/download/v3.28.2/tigera-operator-v3.28.2.tgz
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

```
cat values.yaml
```

**创建服务**

```
helm install calico --create-namespace -n tigera-operator -f values.yaml tigera-operator-v3.28.2.tgz
```

**查看服务**

```
kubectl get pods --all-namespaces | grep -E "^(tigera-operator|calico-system|calico-apiserver)"
kubectl logs -f -n calico-system deploy/calico-kube-controllers
```

**查看应用**

```
kubectl get pod -A -o wide
```

![image-20241025135840530](./assets/image-20241025135840530.png)

**使用calicoctl**

下载并安装

```
wget https://github.com/projectcalico/calico/releases/download/v3.28.2/calicoctl-linux-amd64
chmod +x calicoctl-linux-amd64
cp calicoctl-linux-amd64 /usr/local/bin/calicoctl
```

配置环境变量

```
cat >> ~/.bash_profile <<EOF
## CALICO
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config
EOF
source ~/.bash_profile
```

使用

```
calicoctl get workloadendpoints
calicoctl get nodes
calicoctl get ipPool --output wide
```

**删除服务以及数据**

删除tigera

```
helm uninstall calico -n tigera-operator
```

删除Calico相关的文件

> 所有节点

```
rm -rf /var/lib/cni/
rm -f /etc/cni/net.d/{10-calico.conflist,calico-kubeconfig}
rm -rf /var/lib/calico/
```

重启kubelet

> 所有节点

```
systemctl restart kubelet
```

重启所有pod

```
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod
```

查看pod状态

```
kubectl get pod -A -o wide
```

![image-20241025141225207](./assets/image-20241025141225207.png)