# Cilium

Cilium 是一个基于 eBPF 技术的网络和安全工具，用于在 Kubernetes 集群中提供高效、可扩展的网络连接和安全策略。Cilium 能够为微服务和容器提供透明的网络流量控制、负载均衡、以及网络安全策略。它使用 eBPF（Extended Berkeley Packet Filter）直接在 Linux 内核中运行，实现了低延迟、高性能的网络处理，适用于大规模云原生环境。

Cilium 的官网地址是：[https://cilium.io/](https://cilium.io/)

**要求：**

- Kubernetes 必须配置为使用 CNI（请参阅[网络插件要求](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements)）
- Linux 内核 >= 5.4

**查看版本**

```
helm search repo bitnami/cilium -l
```

**下载chart**

```
helm pull bitnami/cilium --version 1.2.5
```

**修改配置**

根据环境做出相应的修改

```
cat values.yaml
```

**删除kube-proxy**

```
kubectl get  -n kube-system daemonsets.apps kube-proxy -oyaml > kube-proxy.yaml
kubectl delete  -n kube-system daemonsets.apps kube-proxy
```

**创建服务**

```
helm install cilium --create-namespace -n cilium -f values.yaml cilium-1.2.5.tgz
```

**查看服务**

```
kubectl get -n cilium pod,svc -l app.kubernetes.io/instance=cilium
kubectl logs -f -n cilium deploy/cilium-operator
```

**使用服务**

```

```

**删除服务以及数据**

删除相关的资源

```
helm uninstall -n cilium cilium
```

删除相关的文件

> 所有节点

```
rm -f /etc/cni/net.d/05-cilium.conflist
```

删除网络设备

> 所有节点

```
for net in $(ifconfig | egrep "lxc|cilium_host|cilium_vxlan" | awk -F: '{print $1}');do ifconfig $net down && ip link delete $net;done
```

重启kubelet

> 所有节点

```
systemctl restart kubelet
```

重启所有pod

```
kubectl delete pod --all --all-namespaces
```

查看pod状态

```
kubectl get pod -A -o wide
```



