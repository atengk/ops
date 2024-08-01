修改存储类

```
export SC="juicefs"
sed -i "s#storageClassName:.*#storageClassName: ${SC}#" cfs-dbench.yaml
```

创建存储测试

```
kubectl apply -f cfs-dbench.yaml
```

查看输出信息

```
kubectl logs -f -l job-name=cfs-dbench
```

删除

```
kubectl delete -f cfs-dbench.yaml
```



