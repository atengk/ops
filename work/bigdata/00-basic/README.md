# 基础配置

## 配置网卡

> 根据实际环境配置每个节点

```
# vi /etc/sysconfig/network-scripts/ifcfg-ens32
DEVICE="ens33"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR="192.168.1.131"
PREFIX="24"
GATEWAY="192.168.1.1"
DNS1="114.114.114.114"
# systemctl restart network
```

## 修改主机名和hosts

> 每个节点修改相应的主机名和配置hosts

```
hostnamectl set-hostname bigdata01
cat >> /etc/hosts <<EOF
## BigData Cluster Hosts
192.168.1.131 bigdata01
192.168.1.132 bigdata02
192.168.1.133 bigdata03
## BigData Cluster Hosts
EOF
```

## 关闭防火墙以及selinux

```
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
```

## 设置时区时间

```
timedatectl set-timezone Asia/Shanghai
clock -w
timedatectl set-local-rtc 1
sed -i "/^server/d" /etc/chrony.conf
sed -i "3i server ntp.aliyun.com iburst" /etc/chrony.conf
systemctl restart chronyd
chronyc sources
```

## 硬盘挂载

**分区**

新建磁盘标签类型为GPT

```
parted /dev/sdb mklabel gpt
```

创建分区

```
parted /dev/sdb mkpart part1 0% 20%
parted /dev/sdb mkpart part2 20% 100%
```

刷新分区表

```
partprobe /dev/sdb
```

查看分区

```
lsblk /dev/sdb
```

**创建LVM**

安装lvm2

```
yum install lvm2 -y
```

创建物理卷PV

```
pvcreate -f /dev/sdb[1-3]
```

创建卷组VG

```
vgcreate volumes /dev/sdb[1-2]
```

创建逻辑卷LV 

```
lvcreate -L 5G -n data01 volumes
lvcreate -l 100%FREE -n data02 volumes
```

格式化并挂载

```
mkfs.xfs -f /dev/volumes01/data01
mount /dev/volumes01/data01 /mnt
df -hT /mnt
```

开机自动挂载

```
cat >> /etc/fstab <<EOF
/dev/volumes01/data01 /mnt xfs defaults,nofail 0 2
EOF
```

## 关闭swap分区

```
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
```

## 配置内核参数

```
cat >> /etc/sysctl.d/99-bigdata.conf <<EOF
vm.max_map_count = 2621440
fs.file-max = 655360
vm.swappiness = 0
EOF
sysctl -f /etc/sysctl.d/99-bigdata.conf
```

## 关闭透明大页

```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

## 设置limits限制

limits.conf

```
cat > /etc/security/limits.d/99-bigdata.conf <<EOF 
admin soft nofile 655360
admin hard nofile 655360
admin soft nproc 163840
admin hard nproc 163840
admin soft core 0
admin hard core 0
EOF
```

system.conf

> 修改system.conf后需要重启系统

```
cat << EOF >> /etc/systemd/system.conf
[Manager]
DefaultTimeoutStartSec=120s
DefaultTimeoutStopSec=60s
DefaultRestartSec=30s
DefaultLimitNOFILE=655360
DefaultLimitNPROC=163840
CPUAffinity=auto
DefaultLimitCORE=0
DefaultLimitMEMLOCK=infinity
DefaultTasksMax=90%
DefaultEnvironmentFile=/etc/default/environment
EOF
```

## 配置journald服务

> journald 是 systemd 管理的系统日志服务，用于收集、存储和管理系统的日志信息。它负责记录系统的各种事件、错误和消息，以便系统管理员进行故障排除和监控。

```
mkdir -p /var/log/journal /etc/systemd/journald.conf.d
cat << EOF > /etc/systemd/journald.conf.d/99-prophet.conf
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
# 同步间隔时间为5分钟，Journal将缓冲日志并在一次性写入磁盘
SyncIntervalSec=5m
# 限制日志的写入速率为每30秒不超过1000条
RateLimitInterval=30s
RateLimitBurst=10000
# 最大占用空间为10G，一旦达到此限制，较早的日志将被删除
SystemMaxUse=10G
# 单个日志文件的最大大小为200M，达到此大小时会切换到新的日志文件
SystemMaxFileSize=500M
# 日志保留时间为100天，超过此时间的日志将被删除
MaxRetentionSec=100d
# 不将日志转发到syslog
ForwardToSyslog=no
EOF
systemctl restart systemd-journald
```

## 创建服务用户以及目录

```
## 创建服务用户
groupadd -g 1001 ateng
useradd -u 1001 -g ateng -m -s /bin/bash admin
echo Admin@123 | passwd --stdin admin
## 创建目录
mkdir -p /usr/local/software /data/service
chown admin:ateng /usr/local/software /data/service
chmod 755 /data
```

## 配置sudo用户

> 用户 "admin" 可以以任何用户身份，在任何主机上执行任何命令，并且在执行 sudo 命令时无需输入密码

```
echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ateng-admin
chmod 440 /etc/sudoers.d/ateng-admin
```

## 优化SSH服务

```
## 不解析IP地址
sed -i -e 's/#UseDNS yes/UseDNS no/g' \
    -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' \
    /etc/ssh/sshd_config
## 取消主机公钥确认
sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g' /etc/ssh/ssh_config
systemctl restart sshd
```

## 配置免秘钥

> 切换到**admin**用户进行免秘钥配置

```
su admin
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -C "2385569970@qq.com"
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
## 分发秘钥
scp -r ~/.ssh bigdata01:~
scp -r ~/.ssh bigdata02:~
scp -r ~/.ssh bigdata03:~
```

## 配置命令自动补全

```
sudo yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
```

## 安装软件

```
sudo yum -y install net-tools rsync tar
```

