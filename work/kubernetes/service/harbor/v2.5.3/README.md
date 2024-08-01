安装

```
## http
helm install harbor -n kongyu -f values-harbor-http.yaml ./harbor-15.2.1.tgz
## https
helm install harbor -n kongyu -f values-harbor-https.yaml ./harbor-15.2.1.tgz
```

查看

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=harbor
```

删除

```
helm uninstall -n kongyu harbor
kubectl delete -n kongyu pvc data-harbor-trivy-0 harbor-chartmuseum  harbor-jobservice harbor-registry data-harbor-postgresql-0 redis-data-harbor-redis-master-0
```