# 安装ExternalDNS

ExternalDNS 是一个 Kubernetes 控制器，负责在外部 DNS 提供商（如 AWS Route 53、Google Cloud DNS、Cloudflare 等）上动态管理 DNS 记录，将 Kubernetes 服务的外部 IP 或主机名自动同步到外部 DNS 中。

它解决了微服务架构中应用的动态伸缩和变化带来的 DNS 更新问题，简化了将 Kubernetes 服务暴露给外部的过程。

## 创建服务

**查看版本**

```shell
helm search repo bitnami/external-dns -l
```

**下载chart**

```shell
helm pull bitnami/external-dns --version 8.3.8
```

**修改配置**

根据环境做出相应的修改

```shell
cat values.yaml
```

**创建ETCD认证秘钥**

创建Kubernetes集群的ETCD的秘钥，`values.yaml`修改ETCD的地址

```shell
kubectl create secret generic \
    -n kube-system etcd-client-certs \
    --from-file=ca.crt=/etc/ssl/etcd/ssl/ca.pem \
    --from-file=cert.pem=/etc/ssl/etcd/ssl/admin-k8s-master01.pem \
    --from-file=key.pem=/etc/ssl/etcd/ssl/admin-k8s-master01-key.pem
```

**创建服务**

```shell
helm install external-dns -n kube-system -f values.yaml external-dns-8.3.8.tgz
```

**查看服务**

```shell
kubectl get -n kube-system pod,svc,pvc -l app.kubernetes.io/instance=external-dns
kubectl logs -f -n kube-system -l app.kubernetes.io/instance=external-dns
```

## 使用服务

创建Ingress，生成映射数据

```
cat > nginx.yaml <<EOF
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
        - image: nginx
          name: nginx
          ports:
            - containerPort: 80
              name: http
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: ClusterIP
  selector:
    app: nginx
---
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: nginx
spec:
  rules:
    - host: nginx.ateng.local
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: http
                port:
                  number: 80
EOF
kubectl apply -f nginx.yaml
```

查看external-dns日志，已在ETCD生成映射

```
[root@k8s-master01 external-dns]# kubectl logs --tail=200 -f -n kube-system -l app.kubernetes.io/instance=external-dns
time="2024-09-23T15:54:07+08:00" level=info msg="All records are already up to date"
time="2024-09-23T15:55:08+08:00" level=info msg="Generating new prefix: (7a5ac87f)"
time="2024-09-23T15:55:08+08:00" level=info msg="Delete key /skydns/local/ateng/nginx/default"
time="2024-09-23T15:55:08+08:00" level=info msg="Add/set key /skydns/local/ateng/nginx/7a5ac87f to Host=192.168.1.234, Text=\"heritage=external-dns,external-dns/owner=default,external-dns/resource=ingress/default/nginx\", TTL=0"
time="2024-09-23T15:55:08+08:00" level=info msg="Add/set key /skydns/local/ateng/a-nginx/52cece18 to Host=, Text=\"heritage=external-dns,external-dns/owner=default,external-dns/resource=ingress/default/nginx\", TTL=0"
time="2024-09-23T15:56:09+08:00" level=info msg="All records are already up to date"
```

查看ETCD的数据

```
etcdctl get /skydns --prefix --keys-only
```

使用CoreDNS获取ExternalDNS的配置

[参考文档](https://kongyu666.github.io/work/#/work/service/coredns/)



## 删除服务

**删除应用**

```
kubectl delete -f nginx.yaml
```

**删除服务**

```shell
helm uninstall -n kube-system external-dns
kubectl delete ns external-dns-system
```

