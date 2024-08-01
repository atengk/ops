# 安装JuiceFS文件系统

需要提前准备好MinIO集群和etcd集群（http+认证）



## 安装JuiceFS

安装软件包

```
tar -zxvf juicefs-v1.1.1-binary.tar.gz -C /usr/bin/
```

创建文件系统

> 使用http模式+用户认证的etcd集群

```
juicefs format \
    --storage minio  \
    --bucket http://192.168.1.101:9000/juicefs \
    --access-key admin \
    --secret-key Admin@123 \
    etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs \
    juicefs-minio
```

查看文件系统

```
juicefs status etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs
```

挂载文件系统

```
juicefs mount \
    --background \
    --cache-dir /var/jfsCache/ \
    --cache-size 51200 \
    --update-fstab \
    --max-uploads=50 \
    --writeback \
    etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs /mnt
```

验证文件系统

```
juicefs bench /mnt
```

卸载文件系统

```
juicefs umount /mnt
## 强制卸载
juicefs umount --force mnt
```

销毁文件系统

```
## 查看UUID
juicefs status etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs
juicefs destroy etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs a8c9ab85-c871-4094-98b3-24c940fd12b8
```



## 管理JuiceFS

https://juicefs.com/docs/zh/community/command_reference/#config-management-options

显示当前配置

```
juicefs config etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs
```

改变目录的配额

```
juicefs config etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs --inodes 10000000 --capacity 1048576
```

更改回收站中文件可被保留的最长天数

```
juicefs config etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs --trash-days 7
```

限制允许连接的客户端版本

```
juicefs config etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs --min-client-version 1.0.0 --max-client-version 1.1.0
```

设置上传/下载带宽限制

```
juicefs config etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs --upload-limit 40960 --download-limit 40960
```

开启目录统计

```
juicefs config etcd://root:Admin@123@192.168.1.101:2379,192.168.1.102:2379,192.168.1.103:2379/jfs --dir-stats true
```

