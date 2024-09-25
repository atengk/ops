# 安装MetalLB

MetalLB 是一个用于 Kubernetes 集群的**负载均衡解决方案**，专为在裸机（bare metal）环境下运行的集群设计。它提供类似云服务商（如 AWS、GCP）的**服务负载均衡功能**，解决了裸机 Kubernetes 集群缺乏内置负载均衡器的问题。

## 创建服务

**查看版本**

```shell
helm search repo bitnami/metallb -l
```

**下载chart**

```shell
helm pull bitnami/metallb --version 6.3.11
```

**修改配置**

根据环境做出相应的修改

```shell
cat values.yaml
```

**创建服务**

```shell
helm install metallb -n metallb-system --create-namespace -f values.yaml metallb-6.3.11.tgz
```

**查看服务**

```shell
kubectl get -n metallb-system pod,svc,pvc -l app.kubernetes.io/instance=metallb
kubectl logs -f -n metallb-system -l app.kubernetes.io/instance=metallb
```

## 使用服务

配置 IP 地址池（`IPAddressPool`）和L2 广播广告（`L2Advertisement`），主要用于分配和发布负载均衡 IP 地址。

```shell
cat > first-pool.yaml <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.100/32
  - 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF
kubectl apply -f first-pool.yaml
```

创建Nginx应用

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

创建服务，使用 `LoadBalancer` 服务类型，将该服务分配到 `first-pool` 中定义的 IP 地址池

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    metallb.universe.tf/address-pool: first-pool
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
    - name: http
      port: 80
      targetPort: 80
```

创建服务，使用 `LoadBalancer` 服务类型，允许共享同一个 IP，值为 `"service-192.168.1.250"`，表明多个服务可以共享这个特定的 IP 地址，但是端口不能冲突。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-shared-ip
  annotations:
    metallb.universe.tf/allow-shared-ip: "service-192.168.1.250"
spec:
  selector:
    app: nginx
  type: LoadBalancer
  loadBalancerIP: 192.168.1.250
  ports:
    - name: http
      port: 80
      targetPort: 80
```

查看服务

```shell
[root@k8s-master01 metallb]# kubectl get pod,svc
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-7c5ddbdf54-dmf67   1/1     Running   0          4m52s

NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
service/kubernetes        ClusterIP      10.101.0.1       <none>          443/TCP        6d22h
service/nginx             LoadBalancer   10.101.225.18    192.168.1.234   80:30617/TCP   4m52s
service/nginx-shared-ip   LoadBalancer   10.101.238.170   192.168.1.250   80:30579/TCP   4m52s
```

访问服务，通过 LoadBalancerIP 访问应用

```shell
[root@k8s-master01 metallb]# curl 192.168.1.250
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```



## 删除服务

**删除应用**

```
kubectl delete -f nginx.yaml
```

**删除 IPAddressPool 和 L2Advertisement**

```
kubectl delete -f first-pool.yaml
```

**删除服务**

```shell
helm uninstall -n metallb-system metallb
kubectl delete ns metallb-system
```

