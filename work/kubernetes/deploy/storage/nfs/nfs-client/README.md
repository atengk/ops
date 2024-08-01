# 安装NFS

安装nfs服务端

```
yum -y install nfs-utils rpcbind
systemctl enable --now nfs-server
```

创建数据目录

```
mkdir -p /data/nfs
mkdir -p /data/nfs/kubernetes/sc
chown -R nfsnobody:nfsnobody /data/nfs
```

编辑配置文件

```
echo "/data/nfs *(rw,sync,all_squash)" >> /etc/exports
# sync async
```

重新加载配置

```
exportfs -rv
```



# 创建nfs-client-provisioner

创建

```
helm install nfs-client-provisioner -n kube-system -f values-nfs-client.yaml ./nfs-client-provisioner-4.0.16.tgz
```

查看

```
kubectl get -n kube-system pod -l app=nfs-subdir-external-provisioner
```

删除

```
helm uninstall -n kube-system nfs-client-provisioner
```

