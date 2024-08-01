# JuiceFS CSI

JuiceFS CSI 驱动遵循 CSI 规范，实现了容器编排系统与 JuiceFS 文件系统之间的接口。在 Kubernetes 下，JuiceFS 可以用持久卷（PersistentVolume）的形式提供给 Pod 使用。(官方文档)[https://juicefs.com/docs/zh/csi/introduction/]



下载Helm

```
wget https://github.com/juicedata/charts/releases/download/helm-chart-juicefs-csi-driver-0.20.6/juicefs-csi-driver-0.20.6.tgz
```

自定义values.yaml

```
helm show values juicefs-csi-driver-0.20.6.tgz > values.yaml
```

创建存储

```
helm install juicefs-csi-driver -n juicefs --create-namespace -f values.yaml juicefs-csi-driver-0.20.6.tgz
```

查看存储

```
kubectl get pod,svc -n juicefs -o wide
```

访问dashboard

```
http://192.168.1.101:30276/
```

创建pod测试存储

```
kubectl apply -f pod-volume.yaml
```

查看测试存储

```
kubectl get pod,pvc
kubectl logs -f busybox-test
```

卸载存储

```
kubectl delete -f pod-volume.yaml
helm uninstall juicefs-csi-driver -n juicefs
```

