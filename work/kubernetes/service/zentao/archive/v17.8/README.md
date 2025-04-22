创建

```
kubectl apply -f zentao.yaml
```

查看

```
kubectl get -n kongyu pod,svc,pvc -l app=zentao
```

登录

```
URL: http://192.168.1.210:20103
```

删除

```
kubectl delete -f zentao.yaml
kubectl delete -n kongyu pvc data-zentao-data-zentao-0 data-zentao-mysql-zentao-0
```

