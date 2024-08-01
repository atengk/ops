

# 1.14.5 -> 1.15.1

在1.15.1的版本下执行升级命令

```
helm upgrade cert-manager -n cert-manager -f values.yaml cert-manager-1.3.11.tgz
```

查看服务

```shell
kubectl get -n cert-manager pod,svc
kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges -A
```

