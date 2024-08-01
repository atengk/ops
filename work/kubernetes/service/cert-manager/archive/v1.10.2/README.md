创建

```
helm install cert-manager -n cert-manager --create-namespace -f ./values-cert-manager.yaml cert-manager-0.8.11.tgz
```

查看

```
kubectl get -n cert-manager pod,svc
kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
```

删除

```
helm uninstall -n cert-manager cert-manager
```

