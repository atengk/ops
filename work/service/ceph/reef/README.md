# Ceph

Ceph 是一个开源的分布式存储系统，支持对象存储、块存储和文件系统三种接口，具有高可用性、高扩展性和强一致性。它通过 CRUSH 算法实现去中心化数据分布，无需专用硬件即可构建大规模可靠存储集群，广泛应用于云计算和大数据场景。

- [官网文档](https://docs.ceph.com/en/latest/releases/)
- [安装文档](https://docs.ceph.com/en/latest/cephadm/install/#cephadm-deploying-new-cluster)

- [Github](https://github.com/ceph/ceph/tree/quincy/src/cephadm)

## 服务概览

### Ceph 服务的描述

| 服务名称                         | 角色与作用             | 说明                                                         |
| -------------------------------- | ---------------------- | ------------------------------------------------------------ |
| **MON（Monitor）**               | 集群管理和状态维护     | 负责维护集群的健康状态、监控OSD、管理集群map（如OSDMap、PGMap等）和仲裁功能。至少部署3个以实现高可用。 |
| **OSD（Object Storage Daemon）** | 存储数据的核心组件     | 每个OSD负责存储数据、处理数据复制、恢复、回填、心跳检测等，集群中的主要存储单元。 |
| **MGR（Manager）**               | 集群监控与管理扩展功能 | 提供集群监控、性能计量、Web UI接口（如Dashboard）以及用于插件的基础架构。 |
| **MDS（Metadata Server）**       | 管理CephFS元数据       | 专门为CephFS设计，负责文件系统的元数据（如目录结构、权限等），不存储实际文件数据。 |
| **RGW（RADOS Gateway）**         | 对象网关服务           | 提供兼容S3/Swift的RESTful接口，实现Ceph对象存储的Web访问。   |
| **NFS Ganesha**                  | NFS协议访问Ceph        | 提供通过NFSv3/v4协议访问CephFS或RBD的能力，通过Ganesha服务实现。 |

------

### Ceph 提供的存储接口

| 接口类型                      | 描述                                   | 使用场景                                     | 依赖服务                           |
| ----------------------------- | -------------------------------------- | -------------------------------------------- | ---------------------------------- |
| **CephFS**                    | 分布式文件系统接口，支持POSIX语义      | 适合高性能计算、共享文件系统、传统文件访问   | MDS、MON、OSD                      |
| **RBD（RADOS Block Device）** | 块设备接口，支持快照、克隆、精简配置等 | 虚拟机镜像存储、数据库存储等高性能块设备需求 | MON、OSD                           |
| **RGW（RADOS Gateway）**      | 对象存储接口，兼容S3和Swift API        | 云存储服务、大数据、备份归档等对象存储场景   | MON、OSD、RGW                      |
| **NFS（Ganesha NFS）**        | 提供标准NFS协议访问Ceph数据            | 与传统NFS客户端兼容的访问方式                | Ganesha、CephFS 或 RGW（通过导出） |



## 前置条件

- 基础配置，安装文档参考：[链接](/work/service/00-basic/)
- 需要 Python3，安装文档参考：[链接](/work/service/python/v3.13.3/)，系统已存在可以忽略
- 需要 Docker，安装文档参考：[链接](/work/docker/deploy/v27.3.1/)，系统已存在可以忽略

版本说明

| Ceph 版本号 | 对应版本名称           |
| ----------- | ---------------------- |
| 19.x        | Squid                  |
| 18.x        | Reef *（文档当前版本） |
| 17.x        | Quincy                 |
| 16.x        | Pacific                |

服务节点

| IP            | 主机名                | 说明       |
| ------------- | --------------------- | ---------- |
| 10.244.250.10 | service01 | 第一个节点 |
| 10.244.250.20 | service02 | 新增节点   |
| 10.244.250.30 | service03 | 新增节点   |



## 基础配置

**安装依赖**

```
sudo yum install -y curl chrony lvm2
```

**时间同步**

配置时间同步，详情参考时间同步文档：[链接](/work/service/chrony/)

```
sudo tee /etc/chrony.conf <<EOF
server ntp.aliyun.com iburst
server cn.ntp.org.cn iburst
driftfile /var/lib/chrony/drift
rtcsync
makestep 1.0 3
logdir /var/log/chrony
EOF
sudo systemctl enable --now chronyd
```

**安装cephadm**

```
curl --silent --remote-name https://raw.githubusercontent.com/ceph/ceph/reef/src/cephadm/cephadm.py
chmod +x cephadm.py
sudo mv cephadm.py /usr/bin/cephadm
```

**拉取镜像**

```
images="quay.io/ceph/ceph:v18
quay.io/ceph/ceph-grafana:9.4.7
quay.io/prometheus/prometheus:v2.43.0
quay.io/prometheus/alertmanager:v0.25.0
quay.io/prometheus/node-exporter:v1.5.0"
for image in $images
do
    docker pull $image
done
docker save $images | gzip -c > images-ceph_v18.tar.gz
```

**检查节点**

确认容器引擎（如 podman 或 docker）、lvm、chronyd 等是否正常。

```
cephadm check-host
```



## 初始化集群

**初始化ceph**

如果操作系统不支持，可以修改 `cephadm` 文件将操作系统加入进去，以 OpenEuler 为例：`'openeuler': ('openeuler', 'el')`

RedHat系列：vi +8057 /usr/bin/cephadm

Debian系列:   vi +7929 /usr/bin/cephadm

```
sudo cephadm bootstrap \
    --mon-ip 10.244.250.10 \
    --skip-mon-network \
    --cluster-network 10.244.250.0/24
```

- `--mon-ip 10.244.250.10`: 指定用于部署初始 MON（监视器）守护进程的 IP 地址，这个 IP 应该是本机的、集群节点之间可达的地址。
- `--skip-mon-network`: 不自动检测并设置 `public_network`。会将 `mon-ip` 所在的子网作为 `public_network` 使用。适用于你不想让 Ceph 自动猜测网络，手动控制配置的情况。
- `--cluster-network 10.244.250.0/24`: 指定 Ceph 集群内部用于 OSD 之间复制数据的网络（即 `cluster_network`）。这有助于把客户端访问流量（`public_network`）和集群内部流量隔离，提高性能和安全。

**配置public_network**

客户端和集群组件之间的通信（如 MON、MGR、RGW 与客户端）

```
ceph config set mon public_network 10.244.250.0/24
ceph config get mon public_network
ceph orch restart mon
```

**进入ceph shell**

```
sudo cephadm shell
```

**查看集群状态**

```
ceph status
```



## 新增节点

**拷贝秘钥**

```
ssh-copy-id -f -i /etc/ceph/ceph.pub root@service02
ssh-copy-id -f -i /etc/ceph/ceph.pub root@service03
```

**添加节点**

```
ceph orch host add service02 --labels _admin
ceph orch host add service03 --labels _admin
```

- `--labels _admin`：设置为管理节点

**查看主机列表**

```
[root@service01 ~]# ceph orch host ls
HOST       ADDR           LABELS  STATUS  
service01  10.244.250.10  _admin          
service02  10.244.250.20  _admin          
service03  10.244.250.30  _admin          
3 hosts in cluster
```

**查看主机状态**

```
[root@service01 ~]# ceph cephadm check-host service02
service02 (None) ok
docker (/usr/bin/docker) is present
systemctl is present
lvcreate is present
Unit chronyd.service is enabled and running
Hostname "service02" matches what is expected.
Host looks OK
[root@service01 ~]# ceph cephadm check-host service03
service03 (None) ok
docker (/usr/bin/docker) is present
systemctl is present
lvcreate is present
Unit chronyd.service is enabled and running
Hostname "service03" matches what is expected.
Host looks OK
```



## 创建OSD

**查看设备**

```
ceph orch device ls
```

**创建osd**

格式：`ceph orch daemon add osd <hostname>:<device>`

```
ceph orch daemon add osd service01:/dev/vdb
ceph orch daemon add osd service02:/dev/vdb
ceph orch daemon add osd service03:/dev/vdb
```

**查看状态**

```
[root@service01 ~]# ceph osd status
ID  HOST        USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE      
 0  service01   290M  99.7G      0        0       0        0   exists,up  
 1  service02   290M  99.7G      0        0       0        0   exists,up  
 2  service03   690M  99.3G      0        0       0        0   exists,up  
```

**查看pool信息**

```
[root@service01 ~]# ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    300 GiB  299 GiB  873 MiB   873 MiB       0.28
TOTAL  300 GiB  299 GiB  873 MiB   873 MiB       0.28
 
--- POOLS ---
POOL  ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr   1    1  449 KiB        2  1.3 MiB      0     95 GiB
```

**查看集群状态**

```
[root@service01 ~]# ceph status
  cluster:
    id:     551eb19a-2d8f-11f0-a391-8a34cfb79f78
    health: HEALTH_OK
 
  services:
    mon: 1 daemons, quorum service01 (age 16m)
    mgr: service01.puprig(active, since 14m), standbys: service02.qwmhwl
    osd: 3 osds: 3 up (since 35s), 3 in (since 54s)
 
  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 449 KiB
    usage:   873 MiB used, 299 GiB / 300 GiB avail
    pgs:     1 active+clean
```



## 访问 Dashboard

**查看地址**

```
[ceph: root@ateng ~]# ceph mgr services
{
    "dashboard": "https://10.244.250.10:8443/",
    "prometheus": "http://10.244.250.10:9283/"
}
```

**创建目录**

```
mkdir -p /data/ceph/password
```

**修改管理员密码**

```
echo "Admin@123" > /data/ceph/password/admin.password
ceph dashboard ac-user-set-password admin -i /data/ceph/password/admin.password
```

**新增用户**

```
echo "Kongyu@123" > /data/ceph/password/kongyu.password
ceph dashboard ac-user-create kongyu -i /data/ceph/password/kongyu.password administrator
```



## 使用文件系统

### 创建 CephFS

**创建文件系统**

```
ceph fs volume create myfs
```

**查看文件系统**

```
ceph fs ls
```

### 使用 CephFS

**获取secret**

```
[root@service01 ~]# ceph auth get-key client.admin
AQCyJB9oN+bXGBAA0XKlug8bauPy4rD7vaUv6w==
```

**查看mon地址**

```
[root@service01 ~]# ceph auth get-key client.admin
AQCyJB9oN+bXGBAA0XKlug8bauPy4rD7vaUv6w==[root@service01 ~]# 
[root@service01 ~]# ceph mon dump
epoch 1
fsid 29e09146-2d86-11f0-a1c7-8a34cfb79f78
last_changed 2025-05-10T10:04:34.839846+0000
created 2025-05-10T10:04:34.839846+0000
min_mon_release 17 (quincy)
election_strategy: 1
0: [v2:10.244.250.10:3300/0,v1:10.244.250.10:6789/0] mon.service01
```

**安装ceph客户端工具**

```
sudo yum -y install ceph-common
```

**创建秘钥**

```
mkdir -p /data/ceph/secret
echo "AQCyJB9oN+bXGBAA0XKlug8bauPy4rD7vaUv6w==" > /data/ceph/secret/admin.secret
chmod 600 /data/ceph/secret/admin.secret
```

**挂载ceph文件系统**

,fsname=cephfs1

```
sudo mkdir -p /mnt/ceph-fs
sudo mount -t ceph service01:6789:/ /mnt/ceph-fs -o name=admin,secretfile=/data/ceph/secret/admin.secret
```

**查看挂载**

```
[root@service02 ~]# df -hT /mnt/ceph-fs
Filesystem           Type  Size  Used Avail Use% Mounted on
10.244.250.10:6789:/ ceph   95G     0   95G   0% /mnt/ceph-fs
```

**取消挂载**

```
sudo umount /mnt/ceph-fs
```



## 使用块设备

### 创建 RBD

**创建块存储池（pool）**

128 是 PG（Placement Groups）数量，可按集群大小调整。

```
ceph osd pool create rbdpool 128
```

**启用 RBD 功能**

```
rbd pool init -p rbdpool
```

**创建 RBD 镜像（块设备）**

创建一个 10GB 的块设备（10240 MB）

```
rbd create myimage --size 10240 --pool rbdpool
```

**安装客户端工具**

```
sudo yum install ceph-common -y
```

**创建 Ceph 配置文件和认证 keyring**

需要把 Ceph 管理节点上的配置和 keyring 拷贝到客户端：

```
scp /etc/ceph/ceph.conf user@client:/etc/ceph/
scp /etc/ceph/ceph.client.admin.keyring user@client:/etc/ceph/
```

### 使用 RBD

**映射 RBD 到本地设备**

通常会显示 /dev/rbd0

```
rbd map myimage --pool rbdpool --name client.admin
```

**格式化和挂载块设备**

```
mkfs.ext4 /dev/rbd0
mkdir /mnt/rbdtest
mount /dev/rbd0 /mnt/rbdtest
```

**查看挂载**

```
[root@service01 ~]# df -hT /mnt/rbdtest/
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/rbd0      ext4  9.8G   24K  9.3G   1% /mnt/rbdtest
```

**卸载和取消映射**

```
umount /mnt/rbdtest
rbd unmap /dev/rbd0
```



## 使用NFS共享文件

### 创建 NFS

**查看集群主机**

```
ceph orch host ls
```

**查看 CephFS**

```
[root@service01 ~]# ceph fs ls 
name: myfs, metadata pool: cephfs.myfs.meta, data pools: [cephfs.myfs.data ]
```

**创建 NFS Ganesha 集群**

这里 `my-nfs` 是 Ganesha 集群名称，`service01` 是你希望运行 NFS 的主机。

```
ceph orch apply nfs my-nfs --placement="service01,service02,service03"
```

**查看运行情况**

```
[root@service01 ~]# ceph orch ps --daemon-type nfs
NAME                                   HOST            PORTS   STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
nfs.my-nfs.0.1.service01.xpkatq   service01  *:2049  running (8m)      8m ago   8m    41.0M        -  4.4      259b35566514  bb264f67b87e  
nfs.my-nfs.1.1.service03.opviwg   service03  *:2049  running (8m)      8m ago   8m    41.2M        -  4.4      259b35566514  9db27d2e11d1  
nfs.my-nfs.2.12.service02.zyuqgy  service02  *:2049  running (11s)     4s ago  11s    47.7M        -  4.4      259b35566514  cee8c56f337e  
```

**创建导出目录**

```
ceph nfs export create cephfs my-nfs /nfs/myfs myfs /
```

- `my-nfs`：你创建的 NFS Ganesha 集群名。
- `/nfs/myfs`：NFS 客户端访问的伪路径（pseudo path）。
- `myfs`：CephFS 文件系统的名字。
- `/`：实际 CephFS 中导出的路径（如根目录）。

### 查看信息

**查看导出配置**

```
[root@service01 ~]# ceph nfs export ls my-nfs
[
  "/nfs/myfs"
]
```

**查看导出地址**

```
[root@service01 ~]# ceph nfs cluster info my-nfs
{
    "my-nfs": {
        "virtual_ip": null,
        "backend": [
            {
                "hostname": "service01",
                "ip": "10.244.250.10",
                "port": 2049
            },
            {
                "hostname": "service03",
                "ip": "10.244.250.30",
                "port": 2049
            }
        ]
    }
}
```

### 使用 NFS

**安装NFS客户端工具**

```
sudo yum -y install nfs-utils
```

**挂载NFS**

```
mkdir /mnt/ceph-nfs
mount -t nfs -o vers=4 service01:/nfs/myfs /mnt/ceph-nfs
```

**查看挂载**

```
[root@service01 ~]# df -hT /mnt/ceph-nfs/
Filesystem               Type  Size  Used Avail Use% Mounted on
service01:/nfs/myfs nfs4   95G     0   95G   0% /mnt/ceph-nfs
```

**取消挂载**

```
umount /mnt/ceph-nfs/
```



## 使用对象存储

### 创建RGW

**创建RGW**

格式：`ceph orch apply rgw <instance-name> --placement="<主机名>[,...]"`

```
ceph orch apply rgw default --placement="service01,service02,service03"
```

**查看运行情况**

```
[root@service01 ~]# ceph orch ps --daemon-type rgw
NAME                               HOST            PORTS  STATUS        REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
rgw.default.service01.rizmsp  service01  *:80   running (2m)     2m ago   2m    10.8M        -  17.2.8   259b35566514  e4babfed73f8  
rgw.default.service02.cnduxx  service02  *:80   running (2m)     2m ago   2m    9432k        -  17.2.8   259b35566514  7b37f84ebf99  
rgw.default.service03.pjohfh  service03  *:80   running (2m)     2m ago   2m    10.8M        -  17.2.8   259b35566514  f4adb624ea0e  
```

**创建访问用户**

```
radosgw-admin user create --uid=testuser --display-name="Test User"
```

**查看用户信息**

```
[root@service01 ~]# radosgw-admin user info --uid=testuser
{
    "user_id": "testuser",
    "display_name": "Test User",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "testuser",
            "access_key": "3P5G5RMU30KU1B35JJDK",
            "secret_key": "v5wjWiCyshLxJEFTlaqfosLlialChmhLVNGDcl7D"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

### 使用RGW

**使用客户端工具连接**

```
mcli config host add ceph-rgw http://10.244.250.10 3P5G5RMU30KU1B35JJDK v5wjWiCyshLxJEFTlaqfosLlialChmhLVNGDcl7D --api s3v4
```

**上传文件**

```
mcli mb ceph-rgw/ateng
mcli cp README.md ceph-rgw/ateng
```

**查看文件**

```
[root@server02 quincy]# mcli ls ceph-rgw/ateng
[2025-05-10 16:26:28 CST]  14KiB STANDARD README.md
```



## 创建集群

### 查看集群主机

```
[root@service01 ~]# ceph orch host ls
HOST                   ADDR           LABELS  STATUS  
service01  10.244.250.10  _admin          
service02  10.244.250.20  _admin          
service03  10.244.250.30  _admin          
3 hosts in cluster
```

### 添加MON

**添加MON**

```
ceph orch daemon add mon service02
ceph orch daemon add mon service02
```

**查看运行情况**

```
[root@service01 ~]# ceph orch ps --daemon-type mon
NAME           HOST       PORTS  STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
mon.service01  service01         running (14m)     5m ago  49m    43.1M    2048M  17.2.8   259b35566514  4265ac78b7ea  
mon.service02  service02         running (79s)    73s ago  79s    27.6M    2048M  17.2.8   259b35566514  e8efd35339ae  
mon.service03  service03         running (71s)    46s ago  71s    32.7M    2048M  17.2.8   259b35566514  67a0cae818e7 
```

### 添加MGR

**创建MGR**

```
ceph orch apply mgr --placement="service01,service02,service03"
```

**查看运行情况**

```
[root@service01 ~]# ceph orch ps --daemon-type mgr
NAME                  HOST                   PORTS             STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
mgr.service01.dohmno  service01  *:9283,8765,8443  running (54m)    97s ago  54m     442M        -  17.2.8   259b35566514  e910f664caa4  
mgr.service02.olslaz  service02  *:8443,9283       running (44m)    30s ago  44m     391M        -  17.2.8   259b35566514  57b469e272c5  
mgr.service03.askrim  service03  *:8443,9283       running (9s)      3s ago   9s     172M        -  17.2.8   259b35566514  049eceb786eb  
```

### 添加MDS

**查看 CephFS**

```
[root@service01 ~]# ceph fs ls 
name: myfs, metadata pool: cephfs.myfs.meta, data pools: [cephfs.myfs.data ]
```

**查看运行情况**

创建了fs默认就有一个 MDS 守护进程

```
[root@service01 ~]# ceph orch ps --daemon-type mds
NAME                            HOST            PORTS  STATUS        REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
mds.myfs.service01.beshsk  service01         running (2m)     2m ago   2m    13.9M        -  17.2.8   259b35566514  2e563f98831f  
```

**添加mds**

一个 Ceph 文件系统（FS）最少需要部署一个 MDS 守护进程

格式：`ceph orch apply mds <fs-name> --placement="<主机名>[,...]"`

```
ceph orch apply mds myfs --placement="service01,service02,service03"
```

**查看运行情况**

创建了fs默认就有一个 MDS 守护进程

```
[root@service01 ~]# ceph orch ps --daemon-type mds
NAME                       HOST                   PORTS  STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
mds.myfs.service01.keymak  service01         running (52m)    11s ago  52m    24.4M        -  17.2.8   259b35566514  f3adc823901c  
mds.myfs.service02.qfridx  service02         running (46m)   106s ago  46m    22.9M        -  17.2.8   259b35566514  cb4bde69ee59  
mds.myfs.service03.jhclqc  service03         running (8s)      2s ago   9s    12.3M        -  17.2.8   259b35566514  72c684ab6a02  
```

**查看状态**

```
[root@service01 ~]# ceph mds stat
myfs:1 {0=myfs.service01.beshsk=up:active} 2 up:standby
```



## 查看集群

在使用 Ceph 分布式存储系统时，可以通过命令行工具 `ceph` 来查看集群的各种状态和信息。下面是一些常用的 Ceph 集群查看命令，适用于管理员日常排查与维护。

------

📋 基本集群状态

| 命令                       | 说明                                            |
| -------------------------- | ----------------------------------------------- |
| `ceph -s` 或 `ceph status` | 查看集群的整体状态（健康状态、OSD、MON、PG 等） |
| `ceph health`              | 显示集群健康状态（HEALTH_OK / WARN / ERR）      |
| `ceph df`                  | 查看集群存储使用情况（总容量、已用、可用）      |
| `ceph osd df`              | 查看各个 OSD 的容量使用情况                     |
| `ceph osd pool stats`      | 查看各个池的读写速率和延迟信息                  |

------

🧠 监控组件（MON/MGR）

| 命令            | 说明                               |
| --------------- | ---------------------------------- |
| `ceph mon stat` | 查看 MON 节点的数量和状态          |
| `ceph mgr stat` | 查看当前活动的 MGR（管理守护进程） |

------

💾 OSD 相关命令

| 命令                   | 说明                                 |
| ---------------------- | ------------------------------------ |
| `ceph osd stat`        | 查看 OSD 总数和 up/down 状态         |
| `ceph osd tree`        | 查看 OSD 的拓扑结构（host、rack 等） |
| `ceph osd crush tree`  | 查看 CRUSH 规则下的 OSD 结构         |
| `ceph osd perf`        | 查看 OSD 的延迟性能数据              |
| `ceph osd utilization` | 查看每个 OSD 的利用率                |

------

📦 PG（Placement Group）相关

| 命令                     | 说明                            |
| ------------------------ | ------------------------------- |
| `ceph pg stat`           | 显示 PG 状态（active+clean 等） |
| `ceph pg dump`           | 导出所有 PG 的详细信息          |
| `ceph pg dump pgs_brief` | 简要展示 PG 状态（推荐）        |

------

🏊 Pool（存储池）相关

| 命令                                | 说明                 |
| ----------------------------------- | -------------------- |
| `ceph osd lspools`                  | 列出所有存储池       |
| `ceph osd pool ls detail`           | 查看所有池的详细信息 |
| `ceph osd pool get <pool-name> all` | 查看指定池的全部参数 |

------

🧪 其他常用命令

| 命令                                      | 说明                              |
| ----------------------------------------- | --------------------------------- |
| `ceph fs status`                          | 查看 CephFS 文件系统状态          |
| `ceph mds stat`                           | 查看元数据服务器（MDS）状态       |
| `ceph versions`                           | 查看集群中各组件的版本            |
| `ceph quorum_status --format json-pretty` | 查看 MON 的一致性状态（适合调试） |



## 删除集群

**获取集群的 FSID**

```
[root@service01 ~]# ceph fsid
80d01902-2d47-11f0-863e-8a34cfb79f78
```

**卸载集群**

每个节点都要执行

```
[root@service01 ~]# cephadm rm-cluster --fsid 29e09146-2d86-11f0-a1c7-8a34cfb79f78 --force --zap-osds
```

- `--force`：强制删除集群，通常用于集群状态不稳定时。
- `--keep-logs`：保留日志文件。
- `--zap-osds`：删除所有 OSD 数据。
