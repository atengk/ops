# 硬盘管理



## 分区格式化

### fdisk命令

**两种分区方式的对比**

| **特性**         | **GPT分区表**                 | **MBR分区表（扩展+逻辑分区）**                               |
| ---------------- | ----------------------------- | ------------------------------------------------------------ |
| **分区表类型**   | GPT                           | MBR                                                          |
| **分区数量限制** | 支持128个主分区               | 最多4个主分区，其中1个可为扩展分区，扩展分区内可有多个逻辑分区 |
| **存储容量支持** | 最大18EB                      | 最大2TB                                                      |
| **适用设备**     | UEFI启动的现代设备            | 传统BIOS设备                                                 |
| **安全性**       | 分区表有冗余备份，支持CRC校验 | 分区表无冗余备份，易受损坏                                   |
| **操作复杂性**   | 简单，直接创建分区            | 较复杂，需要先创建扩展分区再添加逻辑分区                     |

#### GPT分区表

**创建分区**

g → n → 回车 → 回车 → +10G → w

```
fdisk /dev/sdb
```

![image-20241219211608853](./assets/image-20241219211608853.png)



**刷新分区表**

```
partprobe /dev/sdb
```

**查看分区**

```
lsblk -f /dev/sdb
```

![image-20241219211812085](./assets/image-20241219211812085.png)



#### MBR分区表（扩展+逻辑分区）

**创建分区**

n → e → 回车 → 回车 → 回车 → n → l → 回车 → +10G → w

```
fdisk /dev/sdb
```

![image-20241219211907947](./assets/image-20241219211907947.png)

**刷新分区表**

```
partprobe /dev/sdb
```

**查看分区**

```
lsblk /dev/sdb
```

![image-20241219211944135](./assets/image-20241219211944135.png)

### parted命令

parted 是 Linux 系统中常用的磁盘分区工具，特别适合操作 GPT 和 MBR 分区表的大容量磁盘（超过 2TB）。相比 fdisk，parted 支持更大的磁盘、更现代化的分区表，并且可以以交互式或非交互式方式操作。

#### 交互模式

**使用parted进入磁盘**

```
parted /dev/sdb
```

**新建磁盘标签类型为GPT**

```
(parted) mklabel gpt
```

**创建分区**

```
## mkpart 分区名称 起始区域 结束区域，创建20G分区
(parted) mkpart part1 0% 20%
## 创建剩余空间
(parted) mkpart part2 20% 100%
```

**显示分区表**

```
(parted) p
```

![image-20241219222102009](./assets/image-20241219222102009.png)

**退出**

```
(parted) q
```

**刷新分区表**

```
partprobe /dev/sdb
```

**查看分区**

```
lsblk /dev/sdb
```

![image-20241219222152710](./assets/image-20241219222152710.png)

#### 非交互模式

**新建磁盘标签类型为GPT**

```
parted /dev/sdb mklabel gpt
```

**创建分区**

```
## mkpart 分区名称 起始区域 结束区域，创建20G分区
parted /dev/sdb mkpart part1 0% 20%
## 创建剩余空间
parted /dev/sdb mkpart part2 20% 100%
```

**刷新分区表**

```
partprobe /dev/sdb
```

**查看分区**

```
lsblk /dev/sdb
```

![image-20241219222311870](./assets/image-20241219222311870.png)

### 使用磁盘

#### 格式化磁盘

**格式化为xfs文件系统格式**

```
mkfs.xfs -f /dev/sdb1
```

**查看分区**

```
lsblk -f /dev/sdb
```

![image-20241219222439121](./assets/image-20241219222439121.png)

#### 挂载磁盘

**临时挂载**

```
mount /dev/sdb1 /mnt
```

**开机自动挂载**

```
echo "/dev/sdb1 /mnt xfs defaults,nofail 0 0" >> /etc/fstab
```

**查看挂载信息**

```
df -hT /mnt
```

![image-20241219222545829](./assets/image-20241219222545829.png)

### 其他磁盘操作

**使用blkdiscard命令清除磁盘**

```
blkdiscard /dev/sdb
```

**使用dd命令清除磁盘**

```
dd if=/dev/zero of="/dev/sdb" bs=1M count=100 oflag=direct,dsync
```

**挂载NTFS格式硬盘U盘**

安装NTFS软件包

```
yum -y install ntfs-3g
```

挂载NTFS磁盘或U盘

```
mount -t ntfs-3g /dev/sdc1 /mnt
```

**识别新添加的磁盘**
一般情况下虚拟机中添加新的磁盘，不重启是无法识别。用下面的命令不用重启也可以识别新添加的磁盘

```
scsi_host="$(ls /sys/class/scsi_host/)"
for host in ${scsi_host}
do
    echo "/sys/class/scsi_host/${host}/scan"
    echo "" > /sys/class/scsi_host/${host}/scan
done
```

**/etc/fstab文件详解**

```
/etc/fstab下面分为6个字段：
1. 要挂载的设备（可以使用LABEL、UUID、设备文件）
2. 挂载点
3. 文件系统类型
4. 挂载选项（defaults使用默认挂载选线，如需同时指明，则：defaults,acl）
5. 转储频率
    0: 从不备份
    1: 每天备份
    2: 每隔一天备份
6. 自检次序
    0: 不自检
    1: 首先自检，通常只用于根文件系统
    2: 次级自检
```



## LVM管理

LVM（Logical Volume Manager）是一种用于磁盘分区管理的工具，允许用户创建、调整和管理逻辑卷。通过LVM，可以将多个物理磁盘合并为一个逻辑卷组（VG），然后从中划分出逻辑卷（LV）。LVM支持动态扩展、缩减和快照等功能，使磁盘管理更加灵活和高效，适用于需要频繁调整磁盘空间的场景。

### 安装lvm2

**安装lvm2**

```
yum install lvm2 -y
```

**准备分区**

```
lsblk /dev/sdb
```

![image-20241219223721370](./assets/image-20241219223721370.png)



### 物理卷PV

**创建**

```
[root@kongyu01 ~]# pvcreate -f /dev/sdb[1-3]
  Physical volume "/dev/sdb1" successfully created.
  Physical volume "/dev/sdb2" successfully created.
  Physical volume "/dev/sdb3" successfully created.
```

**查看**

使用pvdisplay命令查看

```
[root@kongyu01 ~]# pvdisplay /dev/sdb[1-3]
```

使用pvs命令查看

```
[root@kongyu01 ~]# pvs /dev/sdb[1-3]
  PV         VG Fmt  Attr PSize  PFree
  /dev/sdb1     lvm2 ---  10.00g 10.00g
  /dev/sdb2     lvm2 ---  10.00g 10.00g
  /dev/sdb3     lvm2 ---  10.00g 10.00g
```

使用pvscan命令查看

```
[root@kongyu01 ~]# pvscan
  PV /dev/sda2   VG centos          lvm2 [<99.00 GiB / 4.00 MiB free]
  PV /dev/sdb2                      lvm2 [10.00 GiB]
  PV /dev/sdb3                      lvm2 [10.00 GiB]
  PV /dev/sdb1                      lvm2 [10.00 GiB]
  Total: 4 [<129.00 GiB] / in use: 1 [<99.00 GiB] / in no VG: 3 [30.00 GiB]
```

**删除**

```
[root@kongyu01 ~]# pvremove -f /dev/sdb[1-3]
  Labels on physical volume "/dev/sdb1" successfully wiped.
  Labels on physical volume "/dev/sdb2" successfully wiped.
  Labels on physical volume "/dev/sdb3" successfully wiped.
```



### 卷组VG

**创建**

```
[root@kongyu01 ~]# vgcreate volumes01 /dev/sdb[1-2]
  Volume group "volumes01" successfully created
```

**查看**

使用vgdisplay命令查看

```
[root@kongyu01 ~]# vgdisplay volumes01
```

使用vgs命令查看

```
[root@kongyu01 ~]# vgs volumes01
  VG        #PV #LV #SN Attr   VSize  VFree
  volumes01   2   0   0 wz--n- 19.99g 19.99g
```

使用vgscan命令查看

```
[root@kongyu01 ~]# vgscan
  Reading volume groups from cache.
  Found volume group "centos" using metadata type lvm2
  Found volume group "volumes01" using metadata type lvm2
```

**重命名**

```
[root@kongyu01 ~]# vgrename volumes01 volumes02
  Volume group "volumes01" successfully renamed to "volumes02"
```

**增缩**

扩容VG

```
[root@kongyu01 ~]# vgextend volumes01 /dev/sdb3
  Volume group "volumes01" successfully extended
```

缩容VG

```
[root@kongyu01 ~]# vgreduce volumes01 /dev/sdb3
  Removed "/dev/sdb3" from volume group "volumes01"
```

**删除**

```
[root@kongyu01 ~]# vgremove volumes01
  Volume group "volumes01" successfully removed
```



### 逻辑卷LV

**创建**
创建5G的LV

```
[root@kongyu01 ~]# lvcreate -L 5G -n data01 volumes01
  Logical volume "data01" created.
```

创建剩余所有容量的LV

```
[root@kongyu01 ~]# lvcreate -l 100%FREE -n data02 volumes01
  Logical volume "data02" created.
```

**查看**
使用vgdisplay命令查看

```
[root@kongyu01 ~]# lvdisplay volumes01
```

使用vgs命令查看

```
[root@kongyu01 ~]# lvs volumes01
  LV     VG        Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  data01 volumes01 -wi-a---- 5.00g
  data02 volumes01 -wi-a----14.99g
```

使用vgscan命令查看

```
[root@kongyu01 ~]# lvscan
  ACTIVE            '/dev/volumes01/data01' [5.00 GiB] inherit
  ACTIVE            '/dev/volumes01/data02' [14.99 GiB] inherit
  ACTIVE            '/dev/centos/root' [<91.12 GiB] inherit
  ACTIVE            '/dev/centos/swap' [<7.88 GiB] inherit
```

查看lvm卷

```
[root@kongyu01 ~]# lsblk /dev/sdb
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sdb                    8:16   0  100G  0 disk
├─sdb1                 8:17   0   10G  0 part
│ ├─volumes01-data01 253:2    0    5G  0 lvm
│ └─volumes01-data02 253:3    0   15G  0 lvm
├─sdb2                 8:18   0   10G  0 part
│ └─volumes01-data02 253:3    0   15G  0 lvm
└─sdb3                 8:19   0   10G  0 part
```

**重命名**

```
[root@kongyu01 ~]# lvrename volumes01 data02 data03
  Renamed "data02" to "data03" in volume group "volumes01"
```

**扩容**

挂载LV

```
## xfs
mkfs.xfs -f /dev/volumes01/data01
mount /dev/volumes01/data01 /mnt
df -hT /mnt

## ext4
mkfs.ext4 /dev/volumes01/data01
mount /dev/volumes01/data01 /mnt
df -hT /mnt
```

手动扩容

ext4文件系统扩容使用"resize2fs 逻辑卷名称"，xfs文件系统扩容使用"xfs_growfs 逻辑卷名称"

```
[root@kongyu01 ~]# lvextend -L 6G /dev/volumes01/data01
  Size of logical volume volumes01/data01 changed from 5.00 GiB (1280 extents) to 6.00 GiB (1536 extents).
  Logical volume volumes01/data01 successfully resized.
## ext4: resize2fs /dev/volumes01/data01
## xfs: xfs_growfs /dev/volumes01/data01
```

自动扩容
当逻辑卷已经被格式化后，使用 -r 选项使文件系统自动变化容量

```
## -L 容量变化的大小，-r 使文件系统自动变化容量
lvextend -L 6G -r /dev/volumes01/data01
## 扩容使用剩余所有空间
lvextend -l +100%FREE -r /dev/volumes01/data01
## 扩容6GB
lvextend -L +6G -r /dev/volumes01/data01
```

**缩容**

xfs格式不支持缩容，ext4支持缩容。逻辑卷组的缩小不支持在线缩减，所以在缩减之前要取消挂载。

手动缩容

先取消挂载设备、再检查磁盘、更新逻辑卷信息、调整大小，最后重新挂载

```
umount /dev/volumes01/data01
e2fsck -f /dev/volumes01/data01
resize2fs /dev/volumes01/data01 4G
lvreduce -L 4G /dev/volumes01/data01
mount /dev/volumes01/data01 /mnt
df -hT /mnt
```

自动缩容

当逻辑卷已经被格式化后，使用 -r 选项使文件系统自动变化容量。

```
## -L 容量变化的大小，-r 使文件系统自动扩容
[root@kongyu01 ~]# lvreduce -L 4G -r /dev/volumes01/data01
Do you want to unmount "/mnt" ? [Y|n] y
fsck from util-linux 2.23.2
/dev/mapper/volumes01-data01: 12/327680 files (0.0% non-contiguous), 59487/1310720 blocks
resize2fs 1.42.9 (28-Dec-2013)
Resizing the filesystem on /dev/mapper/volumes01-data01 to 1048576 (4k) blocks.
The filesystem on /dev/mapper/volumes01-data01 is now 1048576 blocks long.

  Size of logical volume volumes01/data01 changed from 5.00 GiB (1280 extents) to 4.00 GiB (1024 extents).
  Logical volume volumes01/data01 successfully resized.
```

**快照**

创建快照

```
[root@kongyu01 ~]# lvcreate -L 5G -s -n snap01 /dev/volumes01/data01
  Logical volume "data01-snap" created.  
```

还原快照
还原快照后会自动删除该快照

```
[root@kongyu01 ~]# umount /dev/volumes01/data01
[root@kongyu01 ~]# lvconvert --merge /dev/volumes01/snap01
  Merging of volume volumes01/snap01 started.
  volumes01/data01: Merged: 100.00%
```

**删除**

```
[root@kongyu01 ~]# lvremove -f /dev/volumes01/data01
  Logical volume "data01" successfully removed
```



## 软件RAID

