创建

```
helm install sonarqube -n kongyu -f ./values-sonarqube.yaml ./sonarqube-2.0.3.tgz
```

查看

```
kubectl get -n kongyu pod,svc,pvc
```

访问

```

```

删除

```
helm uninstall -n kongyu sonarqube
kubectl delete pvc -n kongyu data-sonarqube-postgresql-0
```

