# OpenEBS创建本地存储



**创建provisioner-localpv**

可以修改文件中**OPENEBS_IO_BASE_PATH**来修改存储的路径

```
kubectl -n kube-system -f localpv-provisioner.yaml
```

