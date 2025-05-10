# Ceph

Ceph 是一个开源的分布式存储系统，支持对象存储、块存储和文件系统三种接口，具有高可用性、高扩展性和强一致性。它通过 CRUSH 算法实现去中心化数据分布，无需专用硬件即可构建大规模可靠存储集群，广泛应用于云计算和大数据场景。

- [官网文档](https://docs.ceph.com/en/latest/releases/)
- [安装文档](https://docs.ceph.com/en/latest/cephadm/install/#cephadm-deploying-new-cluster)

- [Github](https://github.com/ceph/ceph/tree/quincy/src/cephadm)

## 前置条件

- 需要 Python3，安装文档参考：[链接](/work/service/python/v3.13.3/)
- 需要 Docker，安装文档参考：[链接](/work/docker/deploy/v27.3.1/)

版本说明

| Ceph 版本号 | 对应版本名称 |
| ----------- | ------------ |
| 19.x        | Squid        |
| 18.x        | Reef         |
| 17.x        | Quincy *     |
| 16.x        | Pacific      |

## 基础配置

安装依赖

```
yum install -y curl chrony lvm2
```

下载cephadm

```
curl --silent --remote-name https://raw.githubusercontent.com/ceph/ceph/quincy/src/cephadm/cephadm
chmod +x cephadm
sudo mv cephadm /usr/bin
```

## 创建服务

**初始化**

如果操作系统不支持，可以修改 `cephadm` 文件将操作系统加入进去，以 OpenEuler 为例：`'openeuler': ('openeuler', 'el')`

RedHat系列：vi +8057 /usr/bin/cephadm

Debian系列:   vi +7929 /usr/bin/cephadm

```
sudo cephadm bootstrap --mon-ip 192.168.116.137
--allow-fqdn-hostname
```

**进入**

```
sudo cephadm shell
```

**设置副本数**

这里使用的是单机节点，就设置为1，如果后续扩展到了3节点及其以上的集群，就可以设置为3

```
ceph config set global osd_pool_default_size 1
```

**查看状态**

```
ceph status
```



## 添加OSD

```
ceph orch device ls
ceph orch daemon add osd <hostname>:<device>
ceph orch daemon add osd service01.ateng.local:/dev/vdb
ceph osd status
```



## 访问 Dashboard

查看地址

```
[ceph: root@ateng ~]# ceph mgr services
{
    "dashboard": "https://192.168.116.137:8443/",
    "prometheus": "http://192.168.116.137:9283/"
}
```

新增用户

```
echo "Kongyu@123" > kongyu.password
ceph dashboard ac-user-create kongyu -i kongyu.password administrator
```

修改密码

```
echo "Kongyu@123" > kongyu.password
ceph dashboard ac-user-set-password kongyu -i kongyu.password
```



## 使用 CephFS（Ceph 文件系统）

**创建文件系统**

```
ceph fs volume create myfs
ceph fs ls
```

### 使用 内核客户端（推荐生产环境）

获取账号

```
ceph auth get-key client.admin
echo "" > admin.secret
chmod 600  admin.secret
```

查看mon地址

```
[ceph: root@ateng /]# ceph mon dump
epoch 1
fsid 84e25a00-2c89-11f0-82f7-000c2940a584
last_changed 2025-05-09T03:57:51.449049+0000
created 2025-05-09T03:57:51.449049+0000
min_mon_release 17 (quincy)
election_strategy: 1
0: [v2:192.168.116.137:3300/0,v1:192.168.116.137:6789/0] mon.ateng
dumped monmap epoch 1
```

挂载

```

sudo mount -t ceph 192.168.116.137:6789:/ /mnt/mycephfs -o name=admin,secretfile=admin.secret

```

### 使用 FUSE 客户端（更通用）

**挂载（使用内核或 FUSE）**

安装 ceph-fuse（客户端工具）

```
sudo dnf -y install ceph-fuse
```

获取账号

```
ceph auth get client.admin
cat > client.admin <<"EOF"
[client.admin]
        key = AQA+fR1ognuALhAAAsg5s9dBlSEiiSwOI2dgxw==
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"
EOF
chmod 600 client.admin
```

创建挂载点并挂载

```
sudo mkdir /mnt/myfs
sudo ceph-fuse -n client.admin /mnt/myfs

sudo ceph-fuse -n client.admin -m 192.168.116.137:6789 --keyring ceph.client.admin.keyring /mnt/myfs

```



## 新增节点

拷贝秘钥

```
ssh-copy-id -f -i /etc/ceph/ceph.pub root@192.168.116.128
```

添加节点

```
ceph orch host add centos 192.168.116.128 --labels _admin
```

查看主机列表

```
ceph orch host ls
```

查看主机状态

```
[root@ateng ~]# ceph cephadm check-host centos
centos (None) ok
docker (/usr/bin/docker) is present
systemctl is present
lvcreate is present
Unit chronyd.service is enabled and running
Hostname "centos" matches what is expected.
Host looks OK
```



```
部署 OSD（存储服务）
bash
# 列出可用设备
ceph orch device ls --host <新主机名>

# 为特定设备创建 OSD
ceph orch daemon add osd <新主机名>:<设备路径>  # 例如 /dev/sdb

# 或者自动使用所有可用设备
ceph orch apply osd --all-available-devices --host=<新主机名>
部署 MON（监控服务）
bash
ceph orch apply mon --placement="<现有mon节点>,<新主机名>"
部署 MDS（CephFS 元数据服务）
bash
ceph orch apply mds <fs-name> --placement="<新主机名>"
部署 RGW（对象网关服务）
bash
ceph orch apply rgw <realm-name> <zone-name> --placement="<新主机名>"
5. 验证部署
bash
# 查看服务部署状态
ceph orch ps
ceph -s
ceph osd tree

# 检查新节点的健康状况
ceph health detail
```

