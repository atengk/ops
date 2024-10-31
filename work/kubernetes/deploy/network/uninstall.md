# 卸载网络组件



## Kubekey安装的Calico

删除Calico相关的资源

```
kubectl delete -n kube-system daemonsets.apps calico-node
kubectl delete -n kube-system deployments.apps calico-kube-controllers
kubectl get crds | grep 'calico' | awk '{print $1}' | xargs kubectl delete crd
```

删除Calico相关的文件

> 所有节点

```
rm -rf /var/lib/cni/
rm -f /etc/cni/net.d/{10-calico.conflist,calico-kubeconfig}
rm -rf /var/lib/calico/
```

删除网络设备

> 所有节点

```
for net in $(ifconfig | egrep "tunl|vxlan.calico|cali" | awk -F: '{print $1}');do ifconfig $net down && ip link delete $net;done
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

![image-20241025103804949](./assets/image-20241025103804949.png)



## Helm安装的Calico

删除Calico相关的资源

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

删除网络设备

> 所有节点

```
for net in $(ifconfig | egrep "tunl|vxlan.calico|cali" | awk -F: '{print $1}');do ifconfig $net down && ip link delete $net;done
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

![image-20241025103804949](./assets/image-20241025103804949.png)



## Helm安装的Cilium

删除相关的资源

```
helm uninstall cilium  -n kube-system
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
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod
```

查看pod状态

```
kubectl get pod -A -o wide
```

![image-20241030150042884](./assets/image-20241030150042884.png)



## Helm安装的Flannel

删除相关的资源

```
helm uninstall flannel -n kube-system
```

删除相关的文件

> 所有节点

```
rm -rf /var/lib/cni/ /run/flannel /run/xtables.lock
rm -f /etc/cni/net.d/10-flannel.conflist
```

删除网络设备

> 所有节点

```
for net in $(ifconfig | egrep "tunl|cni|flannel|veth" | awk -F: '{print $1}');do ifconfig $net down && ip link delete $net;done
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

![image-20241030162639272](./assets/image-20241030162639272.png)

