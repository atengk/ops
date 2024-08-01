创建

```
kubectl apply -f kadalu-operator.yaml
kubectl apply -f csi-nodeplugin.yaml
```

查看

```
kubectl get pod -n kadalu
```

创建存储类

```
kubectl apply -f kadalu-replica1.yaml
kubectl apply -f kadalu-replica3.yaml
kubectl get sc kadalu.kadalu-replica1 kadalu.kadalu-replica3
```

