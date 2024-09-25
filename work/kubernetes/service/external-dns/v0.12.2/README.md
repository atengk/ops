## 使用coredns

创建ETCD认证秘钥

```
kubectl create secret generic -n kube-system etcd-client-certs --from-file=ca.crt=/etc/ssl/etcd/ca.pem --from-file=cert.pem=/etc/ssl/etcd/etcd-client.pem --from-file=key.pem=/etc/ssl/etcd/etcd-client-key.pem
```

安装external-dns

```
helm install external-dns -n kube-system -f values-external-dns.yaml ./external-dns-6.11.0.tgz
```

查看

```
kubectl -n kube-system get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns"
```

查看dns记录

```
etcdctl get /skydns --prefix --keys-only
```

删除

```
helm uninstall external-dns -n kube-system
```

